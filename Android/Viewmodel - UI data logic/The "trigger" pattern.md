# The "trigger" pattern

Reactive programming and the observable pattern are everywhere nowadays. It is so omnipresent that it's hard to find a library which does not use it or enforce it.

It is even more so in the Android ecosystem where Google first released their [`LiveData`](https://developer.android.com/topic/libraries/architecture/livedata) library in [2017](https://android-developers.googleblog.com/2017/11/announcing-architecture-components-10.html) and is now more and more supporting Kotlin's [Flow](https://developer.android.com/kotlin/flow) in most of their libraries.

In this article, I would like to shed some light on a pattern which I first encountered in [Google's GitHub Browser Sample](https://github.com/android/architecture-components-samples/tree/master/GithubBrowserSample) which I call the **trigger pattern**. It's been mentioned [here](https://medium.com/androiddevelopers/viewmodels-and-livedata-patterns-antipatterns-21efaef74a54) and [there](https://bladecoder.medium.com/to-implement-a-manual-refresh-without-modifying-your-existing-livedata-logic-i-suggest-that-your-7db1b8414c0e) on the web but without a proper explanation.

## What is the Trigger pattern?

The idea is to use an `observable` source to trigger a chain of calls which will result in the state you want your observer to have.

The Trigger pattern takes advantage of the Observable pattern, it allows you to chain operations to create the state of your `observable`s

Here is an example with `Flow`s:

```kotlin
interface Repository {
   suspend fun retrieveSomeInfoForId(id: String): Result<Info>
}

private val trigger = MutableSharedFlow<String>(replay = 1)
val state: Flow<Result<Info>> = trigger.mapLatest { id -> 
    repository.retrieveSomeInfoForId(id) 
}
```

_You can see a real example in [Google's GitHub Browser Sample's ViewModel](https://github.com/android/architecture-components-samples/blob/master/GithubBrowserSample/app/src/main/java/com/android/example/github/ui/user/UserViewModel.kt)_

## So what does it do exactly?

Everytime you push something inside `trigger` (E.g.: `trigger.emit("123")`) this will execute `repository.retrieveSomeInfoForId` and each values emitted by the `Flow` returned by `retrieveSomeInfoForId` will be emitted by `state` as well.

## How is that useful?

Let's take an example of something you might have seen in some code bases where we have a screen that display some information about an `id` it received as a parameter:

```kotlin
interface Repository {
   suspend fun retrieveSomeInfoForId(id: String): Result<Info>
}

private val _info = MutableSharedFlow<Result<Info>>(replay = 1)
val info: Flow<Result<Info>> = _info

fun loadInfo(id: String) = viewModelScope.launch {
    _info.emit(repository.retrieveSomeInfoForId(id))
}
```

And now, consider what would happen if you call `loadInfo`  twice, each time with a different `id`. What if the second call finishes quicker than the first one?  
And what if you want to do something with the info and push the result in a different `Flow`?

```kotlin
interface Repository {
   suspend fun retrieveSomeInfoForId(id: String): Result<Info>
   suspend fun getSimilarNames(info: Info): List<String>
}

private val _info = MutableSharedFlow<Result<Info>>(replay = 1)
val info: Flow<Result<Info>> = _info

private val _similarNames = MutableSharedFlow<List<String>>(replay = 1)
val similarNames: Flow<List<String>> = _similarNames

fun loadInfo(id: String) = viewModelScope.launch {
    val result = repository.retrieveSomeInfoForId(id)
    _info.emit(result)
    _similarNames.emit(emptyList())
    result.onSuccess {
       _similarNames.emit(repository.getSimilarNames(it))
    }
}
```

Again, if you call `loadInfo` twice, you could get into some inconsistent states and now the logic of fetching similar names is entangled with the logic of retrieving the `Info`.

## How could we make this code better?

With the trigger pattern, of course! Let's rewrite it and see how this would look like:

```kotlin
interface Repository {
   suspend fun retrieveSomeInfoForId(id: String): Result<Info>
   suspend fun getSimilarNames(info: Info): List<String>
}

private val id = MutableSharedFlow<String>(replay = 1)

val info: Flow<Result<Info>> = id.mapLatest { id ->
    repository.retrieveSomeInfoForId(id)
}

val similarNames: Flow<List<String>> = info.transformLatest { result ->
    emit(emptyList())
    result.onSuccess {
       emit(repository.getSimilarNames(it))
    }
}

fun loadInfo(id: String) = viewModelScope.launch {
    this.id.emit(id)
}
```

Let's look a little bit closer at what happens here. We call `loadInfo` which launches a coroutine to emit into the trigger (the `MutableSharedFlow` called `id`) the id of the resource to load.  
This, in turns, launches the transformation of `info` to retrieve the information we are looking for.  
When `info` emits, it will also launch the transformation of `similarNames`.

As you can see, the code is not all cramped up into one method anymore. Also, each new `emit` will cancel the previous transformations, without the need for us to keep a reference to them and canceling them when receiving a new `id`, thanks to the `mapLatest` and `transformLatest` methods. This makes this less error prone.

## After thoughts

## New subscribers and resubscribes

This post is focusing on the concept of emitting a value into an `observable` which then 'triggers' some logic into other `observable`s. Yet you may have noticed that those `observable`s would execute their transformation multiple times when some new subscriber subscribed. It's often not what we want. In that case, it's a good idea to use [shareIn](https://kotlinlang.org/api/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines.flow/share-in.html) and [stateIn](https://kotlinlang.org/api/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines.flow/state-in.html) but I will not go into details about those as there are already plenty of good articles about `SharedFlow`s and `StateFlow`s.

## `emit` and the execution order

It is important to note that using this method, calling `loadInfo(id: String)` another time won't cancel the previous unfinished coroutines (the lambda in `viewModelScope.launch`, I.e. the call to `emit`). Therefore, the order of the calls to `emit` into the trigger is important. When using `viewModelScope.launch`, you are actually using the `Dispatchers.Main.immediate` so the coroutines will be queued and it will not be a problem, unless you suspend before the call to `emit`. This problem is also present with the code we have improved but it is far less likely to append with the trigger pattern as we tend to not have any logic into the "triggering" methods.

source: https://androiddev.blog/the-trigger-pattern/

## LiveData example:
```kotlin
class Page1ViewModel : ViewModel() {
    private val loadTrigger = MutableLiveData(Unit)

    fun refresh() {
        loadTrigger.value = Unit
    }

    val textResult: LiveData<String> = loadTrigger.switchMap {
        loadData()
    }

    private fun loadData(): LiveData<String> {
        // Load data here and return it in a new LiveData instance
    }
}
```
