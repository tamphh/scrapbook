# ActivityLifecycleCallbacks — a blind spot in public API

Ever since I was a child, I liked to read instructions and manuals. Even now, as an adult, I’m still amazed at how carelessly people treat them, thinking they already know everything yet only using one or two modes and functions out of dozens! How many of you use the Keep Warm feature of your microwave ovens? It’s available in almost every model now.

Recently, I decided to read the documentation for various Android framework classes, skimming through the main ones such as View, Activity, Fragment, Application. My interest was piqued by the [Application.registerActivityLifecycleCallbacks()](https://developer.android.com/reference/android/app/Application.html#registerActivityLifecycleCallbacks(android.app.Application.ActivityLifecycleCallbacks)) method and the [ActivityLifecycleCallbacks](https://developer.android.com/reference/android/app/Application.ActivityLifecycleCallbacks.html) interface. The Internet didn’t have any better usage examples other than logging of the Activity life cycle. I started experimenting with it myself, and now Yandex.Money actively uses it for solving a whole range of tasks related to outside management of the Activity objects.

## What is ActivityLifecycleCallbacks?

Take a look at this interface. This is what it looked like when it appeared in API 14:

```java
public interface ActivityLifecycleCallbacks {
   void onActivityCreated(Activity activity, Bundle savedInstanceState);
   void onActivityStarted(Activity activity);
   void onActivityResumed(Activity activity);
   void onActivityPaused(Activity activity);
   void onActivityStopped(Activity activity);
   void onActivitySaveInstanceState(Activity activity, Bundle outState);
   void onActivityDestroyed(Activity activity);
}
```

Starting with API 29, a few more methods were added:

```java
public interface ActivityLifecycleCallbacks {
   default void onActivityPreCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) { }
   void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState);
   default void onActivityPostCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) { }
   default void onActivityPreStarted(@NonNull Activity activity) { }
   void onActivityStarted(@NonNull Activity activity);
   default void onActivityPostStarted(@NonNull Activity activity) { }
   default void onActivityPreResumed(@NonNull Activity activity) { }
   void onActivityResumed(@NonNull Activity activity);
   default void onActivityPostResumed(@NonNull Activity activity) { }
   default void onActivityPrePaused(@NonNull Activity activity) { }
   void onActivityPaused(@NonNull Activity activity);
   default void onActivityPostPaused(@NonNull Activity activity) { }
   default void onActivityPreStopped(@NonNull Activity activity) { }
   void onActivityStopped(@NonNull Activity activity);
   default void onActivityPostStopped(@NonNull Activity activity) { }
   default void onActivityPreSaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) { }
   void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState);
   default void onActivityPostSaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) { }
   default void onActivityPreDestroyed(@NonNull Activity activity) { }
   void onActivityDestroyed(@NonNull Activity activity);
   default void onActivityPostDestroyed(@NonNull Activity activity) { }
}
```

Maybe people pay so little attention to this interface because it only debuted in Android 4.0 ICS, which is a shame as it provides a very interesting tool that allows managing all Activity objects from the outside. More on that later, first, we’ll take a closer look at the methods.

Each method displays a similar Activity lifecycle method, and you can call it when the method is triggered by any Activity in the app. That is, if the app starts with MainActivity, then the first call we receive will be ActivityLifecycleCallback.onActivityCreated(MainActivity, null).

Great, but how does it work?

No magic here: Activity report on their state by themselves. Here’s a piece of code from Activity.onCreate():

```java
   Parcelable p = savedInstanceState.getParcelable(FRAGMENTS_TAG);
   mFragments.restoreAllState(p, mLastNonConfigurationInstances != null
           ? mLastNonConfigurationInstances.fragments : null);
}
mFragments.dispatchCreate();
getApplication().dispatchActivityCreated(this, savedInstanceState);
if (mVoiceInteractor != null) {
```

This looks like as if we did BaseActivity ourselves, except our friends from Android not only did it for us, but also obliged everyone to use it. Really good of them, isn’t it? In API 29, these methods work in almost the same way, but their Pre and Post copies are called before and after specific methods. The process is probably now controlled by ActivityManager, but this is just my guess since I didn’t go into the source deep enough to find out.

## How to make ActivityLifecycleCallbacks work?

Like all callbacks, first it needs to be registered. We register all ActivityLifecycleCallbacks in Application.onCreate(), and this gives us information about all Activity objects and the managing rights.

```kotlin
class MyApplication : Application() {
   override fun onCreate() {
       super.onCreate()
       registerActivityLifecycleCallbacks(MyCallbacks())
   }
}
```

Short aside: from API 29 on, ActivityLifecycleCallbacks can also be registered from within Activity. This will be a local callback that only works for this Activity. That’s it. You can find all this by simply searching for “ActivityLifecycleCallbacks”. The results will include many examples of logging the Activity lifecycle, but does that actually interest you? Activity has a lot of public methods (about 400), and all of them can be used for a lot of interesting and useful things.

What can I do with this?  
Whatever you want. Dynamically change the theme in all Activity objects in the app? Sure: the setTheme() method is public, which means you can call it from ActivityLifecycleCallback:

```kotlin
class ThemeCallback(@StyleRes val myTheme: Int) : ActivityLifecycleCallbacks {
   override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
       activity.setTheme(myTheme)
   }
}
```

**Try this ONLY at home**  
Some Activity objects from the connected libraries can use their custom themes. Therefore, check the package or any other attribute determining that the theme of this Activity can be safely changed. Here’s how we check the package (in Kotlin-way ツ):

```kotlin
class ThemeCallback(@StyleRes val myTheme: Int) : ActivityLifecycleCallbacks {
   override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
       activity
           .takeIf { it.javaClass.name.startsWith("my.cool.application") }
           ?.setTheme(myTheme)
   }
}
```

Not working? You may have forgotten to `register` ThemeCallback in `Application` or `Application in AndroidManifest`.

Want another interesting example? You can show messages for any Activity in the app.

```kotlin
class DialogCallback(val dialogFragment: DialogFragment) : ActivityLifecycleCallbacks {
   override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
       (activity as? AppCompatActivity)
           ?.supportFragmentManager
           ?.also { fragmentManager ->
               if (fragmentManager.findFragmentByTag(dialogFragment.javaClass.name) == null) {
                   dialogFragment.show(fragmentManager, dialogFragment.javaClass.name)
               }
           }
   }
}
```

**Try this ONLY at home**  
Of course, we don’t show messages on every screen: our users would definitely not appreciate this, though sometimes it can be useful to show something like this on some specific screens.

Here’s another case: what if we need to run Activity? Simple: Activity.startActivity() and go. What if we need to wait for the result after calling Activity.startActivityForResult()? I’ve got a recipe:

```kotlin
class StartingActivityCallback : ActivityLifecycleCallbacks {
   private val requestCode = 1
   override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
       (activity as? AppCompatActivity)?.supportFragmentManager ?.also { fragmentManager ->
               val startingFragment = findOrCreateFragment(fragmentManager)

               startingFragment.listener = { requestCode, resultCode, data ->
                   if (requestCode == this.requestCode) {
                       // handle response here
                   }
               }

               // start Activity inside StartingFragment
           }
   }

   private fun findOrCreateFragment(fragmentManager: FragmentManager): StartingFragment {
       return fragmentManager.findFragmentByTag(StartingFragment::class.java.name) as StartingFragment?
           ?: StartingFragment().apply {
               fragmentManager
                   .beginTransaction()
                   .add(this, StartingFragment::class.java.name)
                   .commit()
           }
   }
}
```

In the example, we simply dropped Fragment that starts Activity and gets the result, then delegates the processing to us.

Let’s complicate the examples. Up until now, we only used methods provided in Activity. What if we add our own? Suppose we want to send analytics about an opened screen. Let’s remember that our screens have their own names. How do we solve this? Simple! Create a Screen interface that can provide the screen name:

```kotlin
interface Screen {
   val screenName: String
}
```

Now we implement it in the required Activity:

```kotlin
class NamedActivity : Activity(), Screen {
   override val screenName: String  = "First screen"
}
```

After that we set off the special ActivityLifecycleCallback on such Activity objects:

```kotlin

class AnalytiscActivityCallback(val sendAnalytics: (String) -> Unit) : ActivityLifecycleCallbacks {
   override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
       (activity as? Screen)?.screenName?.let(sendAnalytics)
   }
}
```

See? We just check the interface and, if it’s been implemented, send analytics.

Let’s go over it once again. What if we need to process some more parameters? Extend the interface:

```kotlin
interface ScreenWithParameters : Screen {
   val parameters: Map<String, String>
}
```

Implement:

```kotlin
class NamedActivity : Activity(), ScreenWithParameters {
   override val screenName: String = "First screen"
   override val parameters: Map<String, String> = mapOf("key" to "value")
}
```

Send:

```kotlin
class AnalytiscActivityCallback(
   val sendAnalytics: (String, Map<String, String>?) -> Unit
) : ActivityLifecycleCallbacks {
   override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
       (activity as? Screen)?.screenName?.let {
           sendAnalytics(it, (activity as? ScreenWithParameters)?.parameters)
       }
   }
}
```

Still, too easy. Everything we did so far was to bring us to the actual interesting topic: native dependency injection. Yes, we have Dagger, Koin, Guice, Kodein, and others, but they’re redundant for small projects. I’ve got a solution, though… Guess what?

Let’s say we have a tool, something like this:

```kotlin
class CoolToolImpl {
   val extraInfo = "i am dependency"
}
```

Hide it with interface (as any grown-up programmers would do):

```kotlin
interface CoolTool {
   val extraInfo: String
}

class CoolToolImpl : CoolTool {
   override val extraInfo = "i am dependency"
}
```

Now, a bit of street magic from ActivityLifecycleCallbacks: we create an interface for injecting this dependency, implement it in the required Activity objects, then find and inject the CoolToolImpl implementation using ActivityLifecycleCallbacks.

Don’t forget to test InjectingLifecycleCallbacks in your Application, now, launch it. Everything’s working!  
Don’t forget to test:

```kotlin

interface RequireCoolTool {
   var coolTool: CoolTool
}

class CoolToolActivity : Activity(), RequireCoolTool {
   override lateinit var coolTool: CoolTool
}

class InjectingLifecycleCallbacks : ActivityLifecycleCallbacks {
   override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
       (activity as? RequireCoolTool)?.coolTool = CoolToolImpl()
   }
}
```

This approach wouldn’t scale well on large projects, so I’m not going to take away anybody’s DI frameworks. It’d be way better to combine efforts and work in synergy. Let’s see the example of Dagger2. If you have some basic Activity in the project that does something like \`AndroidInjection.inject(this)\`, then it’s time to throw it away. Instead, do the following:

1.  inject DispatchingAndroidInjector to Application using the instruction;
2.  create ActivityLifecycleCallbacks, that calls DispatchingAndroidInjector.maybeInject() for each Activity;
3.  register ActivityLifecycleCallbacks in Application.


```kotlin
class MyApplication : Application() {
   @Inject lateinit var dispatchingAndroidInjector: DispatchingAndroidInjector<Any>

   override fun onCreate() {
       super.onCreate()
       DaggerYourApplicationComponent.create().inject(this);
       registerActivityLifecycleCallbacks(InjectingLifecycleCallbacks(dispatchingAndroidInjector))
   }
}

class InjectingLifecycleCallbacks(
   val dispatchingAndroidInjector: DispatchingAndroidInjector<Any>
) : ActivityLifecycleCallbacks {
   override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
       dispatchingAndroidInjector.maybeInject(activity)
   }
}
```

Same effect can be achieved with other DI frameworks. Try some and post your results in the comments.

## Let’s summarize

ActivityLifecycleCallbacks is an underrated, powerful tool. Try one of [these examples](https://github.com/yandex-money/android-activitylifecyclecallbacks-example), and let them help you in your projects the same way they help Yandex.Money make our apps better.

source: https://medium.com/yoomoney-eng/activitylifecyclecallbacks-a-blind-spot-in-public-api-6ea522fbf546
