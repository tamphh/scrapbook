![](https://www.droidcon.com/wp-content/uploads/2024/06/1_W7un4Q57SBMIbtt3UB9fTA-600x336.webp)

Image generated with Gemini

_TLDR; Story time first — jump to the titled sections below for instructions on how to use_ _dependencyInsight_ _if you are short on time._

Recently, I needed to upgrade a dependency to a beta version (`androidx.navigation:navigation-compose`, version `2.8.0-beta02` to be exact) in my Android app and, as usually happens, this dependency version required other Jetpack Compose dependencies (transient dependencies), some of which were specified with their alpha or beta versions. Usually this is okay, we accept that an alpha or beta version of a dependency may have some issues and if we find we can wait for the stable versions and raise a bug if needed.

But, in my case I couldn’t wait, I wanted some cool new features from the new navigation library ([Type-Safe Navigation](https://medium.com/androiddevelopers/navigation-compose-meet-type-safety-e081fb3cf2f8) yay!) that I needed to ship in my app soon. The trouble was, the new alpha versions of the transient dependencies caused a crash which I did not want in my app (in my case this was `NoSuchMethodError` with `HorizontalPager`)!

When I did some digging, I found that the `HorizontalPager` constructor had changed signature in version `1.7.0-beta02` of the `androidx.compose.foundation` dependency (`HorizontalPager` is marked as an `ExperimentalAPI` so this is not altogether surprising after all) which was being included as as a transient dependency of `androidx.navigation:navigation`. The navigation library was specifying version `1.7.0-beta02` but I knew in the previous stable version, `1.6.7` my `HorizontalPager` implementation was working.

So what to do about this? Do I wait for `androidx.navigation:navigation` or `androidx.compose.foundation:foundation` to become stable and then integrate it into my app (despite the new feature I needed to ship), try and hack something with the new dependency or instead, can I make sure the stable dependency version is used?

At this point I didn’t even know which dependency was causing the transient dependency version upgrade — I had updated several other dependencies in the same piece of work so it could have been anything…

###### Viewing the Gradle dependency tree

The first thing to look at is the whole dependency tree.

The simplest way to do this is using the gradle wrapper with the `dependencies` [command](https://docs.gradle.org/current/userguide/viewing_debugging_dependencies.html#sec:listing_dependencies):

```
./gradlew :app:dependencies
```

You’ll see above that I specified the module, interestingly, if you exclude the module you won’t get the full project output, you just get the top level details (which is not usually what we want).

Instead, specifying the module will give you the list of dependencies required by that module including the transient dependencies.

If you want to get fancy, you can also add `--scan` to the `dependencies` command to produce a searchable web based report. This involves verifying your email with gradle and often I find it quicker just to view the text version. Generally I find it more convenient to output the results of the command to a file so I could then do a diff with before changes and after changes outputs (the output can grow quite long in a large project!)

`./gradlew :app:dependencies > dependencyTree.txt`

###### Understanding the dependency tree output

If you take a look at the resulting file, you will see it is massive (for a simple test Hello World app it was 7435 lines long). You can narrow this down by specifying the configuration you are interested in. For most cases you can look at: `compileClasspath` , `runtimeClasspath` ,`testCompileClasspath` , and `testRuntimeClasspath`. I needed `runtimeClasspath`, and I added the build type of `debug`:

```
./gradlew :app:dependencies --configuration debugRuntimeClasspath 
> dependencyTree.txt
```

Now my file is only 692 lines long. Much easier to use!

So now we can see all the dependencies and what transient dependencies they include. For example:

```
+--- androidx.navigation:navigation-compose:2.8.0-beta02
|    +--- androidx.activity:activity-compose:1.8.0 -&gt; 1.9.0 (*)
|    +--- androidx.compose.animation:animation:1.7.0-beta02 (*)
|    +--- androidx.compose.foundation:foundation-layout:1.7.0-beta02 (*)
|    +--- androidx.compose.runtime:runtime:1.7.0-beta02 (*)
|    +--- androidx.compose.runtime:runtime-saveable:1.7.0-beta02 (*)
|    +--- androidx.compose.ui:ui:1.7.0-beta02 (*)
|    +--- androidx.lifecycle:lifecycle-viewmodel-compose:2.6.2 -&gt; 2.8.1
|    |    \--- androidx.lifecycle:lifecycle-viewmodel-compose-android:2.8.1
|    |         +--- androidx.annotation:annotation:1.8.0 (*)
|    |         +--- androidx.compose.runtime:runtime:1.6.0 -&gt; 1.7.0-beta02 (*)
|    |         +--- androidx.compose.ui:ui:1.6.0 -&gt; 1.7.0-beta02 (*)
|    |         +--- androidx.lifecycle:lifecycle-common:2.8.1 (*)
|    |         +--- androidx.lifecycle:lifecycle-viewmodel:2.8.1 (*)
...
```

Here we can see that `androidx.navigation:navigation-compose` includes `androidx.compose.foundation:foundation-layout:1.7.0-beta02`

The gradle [documentation](https://docs.gradle.org/current/userguide/viewing_debugging_dependencies.html#sec:listing_dependencies) is pretty clear here to help understand what the annotation symbols mean with each dependency listed:

> (\*): Indicates repeated occurrences of a transitive dependency subtree. Gradle expands transitive dependency subtrees only once per project; repeat occurrences only display the root of the subtree, followed by this annotation.
> 
> (c): This element is a dependency constraint, not a dependency. Look for the matching dependency elsewhere in the tree.
> 
> (n): A dependency or dependency configuration that cannot be resolved.

But from this I can’t tell if `androidx.navigation:navigation-compose:2.8.0-beta02` is forcing `androidx.compose.foundation:foundation-layout` to use version `1.7.0-beta02`. In a large project this could also be very tedious go through every mention of the problematic library and compare them.

###### Target the dependency with `dependencyInsight`

Instead, we can use [dependencyInsight](https://docs.gradle.org/current/userguide/viewing_debugging_dependencies.html#dependency_insights) to get the specific resolution information for a dependency.

```
./gradlew :app:dependencyInsight — configuration debugRuntimeClasspath — dependency androidx.compose.foundation > dependencyInsight.txt
```

```
./gradlew :app:dependencyInsight --configuration debugRuntimeClasspath --dependency androidx.compose.foundation > dependencyInsight.txt
```

Here, again I am passing in the `configuration` and also adding the dependency I am interested in as an argument. Also sending the output the results of this to a file so I could then do a diff with the result before the changes and after the changes. There is also a web version of this as well using the `--scan` flag.

At the top of the file we get some metadata about the dependency and what versions are being requested and what version has been resolved:

```
> Task :app:dependencyInsight
androidx.compose.foundation:foundation:1.7.0-beta02
  Variant releaseRuntimeElements-published:
    | Attribute Name                                  | Provided     | Requested     |
    |-------------------------------------------------|--------------|---------------|
    | org.gradle.status                               | release      |               |
    | org.gradle.category                             | library      | library       |
    | org.gradle.usage                                | java-runtime | java-runtime  |
    | org.jetbrains.kotlin.platform.type              | androidJvm   | androidJvm    |
    | com.android.build.api.attributes.AgpVersionAttr |              | 8.6.0-alpha03 |
    | com.android.build.api.attributes.BuildTypeAttr  |              | debug         |
    | org.gradle.jvm.environment                      |              | android       |
   Selection reasons:
      - By constraint: foundation-layout is in atomic group androidx.compose.foundation
      - By constraint
      - By constraint: prevents a critical bug in Text
      - By conflict resolution: between versions 1.7.0-beta02, 1.6.7, 1.4.0 and 1.6.0
```

After this you will see the resolved version and a list of the dependencies that requested it:
```
androidx.compose.foundation:foundation:1.7.0-beta02
+--- debugRuntimeClasspath
\--- androidx.compose.foundation:foundation-layout-android:1.7.0-beta02
     +--- androidx.compose:compose-bom:2024.05.00 (requested androidx.compose.foundation:foundation-layout-android:1.6.7)
     |    \--- debugRuntimeClasspath
     \--- androidx.compose.foundation:foundation-layout:1.7.0-beta02
          +--- androidx.compose:compose-bom:2024.05.00 (requested androidx.compose.foundation:foundation-layout:1.6.7) (*)
          +--- androidx.navigation:navigation-compose:2.8.0-beta02
...
```
You will also get the selection reasons for each request. You can then search through this and find the reason why the problematic version is selected.

### Forcing a specific dependency version
Now that you know which dependency or dependencies are including the transitive version you don’t want you can then exclude it using exclude. In my example:

```
implementation(libs.compose.navigation) {
    exclude(group = "androidx.compose.foundation", module = "foundation")
    exclude(group = "androidx.compose.foundation", module = "foundation-android")
    exclude(group = "androidx.compose.foundation", module = "foundation-layout-android")
}
```

where:
```
compose-navigation = { group = "androidx.navigation", name = "navigation-compose", version.ref = "2.8.0-beta02" 
```
And don’t forget to include the desired version:

```
implementation(libs.compose.foundation)
implementation(libs.compose.foundation.layout)
```

where:
```
compose-foundation = { group = "androidx.compose.foundation", name = "foundation", version.ref = "1.6.7"}
compose-foundation-layout = { group = "androidx.compose.foundation", name = "foundation-layout-android", version.ref = "1.6.7"}
```
This is how I solved my dependency issue, obviously overriding transitive dependency versions is not something we want to do frequently (and could cause unexpected build or runtime errors) but when needed, this can be something worth trying.

This article is previously published on proandroiddev.com

If the tree is large and you already have an inkling about what library could be the cause, you can do the exclusion as outlined below and then re-run the command and diff the outputs to see what has changed.

source: https://www.droidcon.com/2024/06/12/debugging-dependencies-in-gradle/
