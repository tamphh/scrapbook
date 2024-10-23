# The best way to load data in ViewModels

\*According to me and my skill level in 2024.

Simplicity is key. Sadly, it is also one of the hardest things to achieve in software development. I will take you on a journey to my 2024 way of loading data into view models. For all my friends that have gold-fish like attention spans: Here is a link to the [repository](https://github.com/joost-klitsie/DataLoadingExample) containing the whole thing with a working example using Jetpack Compose.

![](https://miro.medium.com/v2/resize:fit:875/1*D-KtMUuaVqT2OA3tvc8Ueg.jpeg)

## The problem with loading data

> _“There are many ways to peel a banana, but sometimes it’s more fun to use a pogo stick!” — Copilot_

Loading data seems like a straightforward problem: A view model is often used as a simple container that fetches some data, then it maps that data into a view state and then exposes the result through some observable object. Great you think? I think so too! It is an easy problem to solve, right up until things get more complex.

We expect mobile applications to react to changes in a fast and snappy way. Modern UI frameworks have amazing tooling to deal with animations and magically make items appear/change/disappear as to how a certain piece of data changes over time. Data can change by receiving it through a simple network call, or perhaps through a socket event, notification or simple user input. One of the issues we have to solve, is that mobile phones possibly have shite internet connectivity. Therefore, relying on blindly implementing happy-path-only solutions is something we will leave to the web developers. Instead, we will look at a proper solution to make sure the UI will always be up to date. Let’s take a look at the following not so great example:

```kotlin
sealed interface ViewState {
  data class Success(val text: String, val counter: Int): ViewState
  data object Loading: ViewState
  data object Failure: ViewState
}

class ViewStateMapper {

  fun map(dataResult: Result<Data>): ViewState {
    val data = dataResult.getOrElse { exception ->
      println(exception)
      return ViewState.Failure
    }
    return mapSuccess(data)
  }

  fun mapSuccess(data: Data) = ViewState.Success(
    text = data.someText,
    counter = data.counter,
  )

}


class MyViewModel(
  private val fetchDataUseCase: FetchDataUseCase,
  private val observeDataUseCase: ObserveDataUseCase,
  private val viewStateMapper: ViewStateMapper,
): ViewModel() {

  private val _viewState = MutableStateFlow<ViewState>(ViewState.Loading)
  val viewState = _viewState.asStateFlow()

  init {
    coroutineScope.launch {
      val dataResult = fetchDataUseCase.run()
      _viewState.update { viewStateMapper.map(dataResult) }
      dataResult.onSuccess {
        observeDataUseCase.run().collect { newData ->
          _viewState.update { viewStateMapper.map(newData) }
        }
      }
    }
  }

}
```

This code will approximately provide you with the following functionality:

1.  You get a view in some kind of loading state
2.  You load the data
3.  If the data failed to load, you get a failure state
4.  If the data successfully loaded, you get the successful view state
5.  We observe on data changes and update the view state accordingly

This code looks simple enough, but it is lacking! What if I want to retry to load the data? What if I want to refresh the data? Let’s quickly solve that problem by updating the view model!

```kotlin
class MyViewModel(/*Dependencies*/): ViewModel() {

  private val _viewState = MutableStateFlow<ViewState>(ViewState.Loading)
  val viewState = _viewState.asStateFlow()

  init {
    refreshData()
  }

  fun refreshData() {
    _viewState.update { ViewState.Loading }
    coroutineScope.launch {
      val dataResult = fetchDataUseCase.run()
      _viewState.update { viewStateMapper.map(dataResult) }
      dataResult.onSuccess {
        observeDataUseCase.run().collect { newData ->
          _viewState.update { viewStateMapper.map(newData) }
        }
      }
    }
  }

}
```

Great! Now we have a `refreshData` function! It does all the things it did before, but it is accessible from the outside! Sadly, as you may notice, this piece of code will start the refresh process as many times as you call the `refreshData` function. Also, every time you would refresh the data successfully, you also add another observeDataUseCase collection and every update may trigger multiple times. We can do our best and solve this with a “wonderful thing” called side effects:

```kotlin
class MyViewModel(/*Dependencies*/): ViewModel() {

  private val _viewState = MutableStateFlow<ViewState>(ViewState.Loading)
  private var refreshJob: Job // Store the refreshing of data into this job
  val viewState = _viewState.asStateFlow()

  init {
    refreshJob = refreshData()
  }

  fun refresh() {
    if (_viewState.value is ViewState.Loading) {
      return
    }
    refreshJob.cancel()
    _viewState.update { ViewState.Loading }
    refreshJob = refreshData()
  }

  private fun refreshData() = coroutineScope.launch {
      val dataResult = fetchDataUseCase.run()
      _viewState.update { viewStateMapper.map(dataResult) }
      dataResult.onSuccess {
        observeDataUseCase.run().collect { newData ->
          _viewState.update { viewStateMapper.map(newData) }
        }
      }
    }
  }

}
```

I have added a bunch of lines and managed to fix the biggest issues. But “great”, now we have a refreshJob that we now have to handle and certainly shouldn’t forget to cancel and reassign. And then there are still more things that wouldn’t sit right with modern UI’s: every time you refresh, the whole screen goes into a ViewState.Loading state! What about pull to refresh? Also, what about the data that I already have in memory? Oh crap, it would be so nice to actually display the actual screen directly if the data is already there in memory! That means more dependencies I have to inject into my view model, as well as a bunch of added complexity to manage the state:

```kotlin
class MyViewModel(
  private val fetchDataFromMemoryUseCase: FetchDataFromMemoryUseCase,
  private val fetchDataUseCase: FetchDataUseCase,
  private val observeDataUseCase: ObserveDataUseCase,
  private val viewStateMapper: ViewStateMapper,
): ViewModel() {

  private val _viewState = MutableStateFlow<ViewState>(
    fetchDataFromMemoryUseCase.run().map { data ->
      viewStateMapper.mapSuccess(data)
    } ?: ViewState.Loading
  )
  private var refreshJob: Job // Store the refreshing of data into this job
  val viewState = _viewState.asStateFlow()

  init {
    refreshJob = if (_viewState.value is ViewState.Success) {
      coroutineScope.launch { observeData() }
    } else {
      refreshData()
    }
  }

  fun refresh() {
    if (_viewState.value is ViewState.Loading) {
      return
    }
    refreshJob.cancel()
    _viewState.update { ViewState.Loading }
    refreshJob = refreshData()
  }

  private fun refreshData() = coroutineScope.launch {
      val dataResult = fetchDataUseCase.run()
      _viewState.update { viewStateMapper.map(dataResult) }
      dataResult.onSuccess {
        observeData()
      }
    }
  }

  private fun observeData() {
    observeDataUseCase.run().collect { newData ->
      _viewState.update { viewStateMapper.map(newData) }
    }
  }

}
```

Now, this code probably runs fine, but all this complexity just to load some data? Hell, I wouldn’t want to be the person to write unit tests for this. Unit testing things can be hard enough without side effects and view models. This view model does not even have any real functionality linked to it, other than displaying data! But before we could call a real function on it, we already have to write a bunch of test cases to assert the initial data state, loading state, initial refresh, observing, no concurrent refreshing etc.. And it doesn’t even pull to refresh… Luckily, it can be worse! What if we have to first fetch data with type x so that we can use that to fetch data with type y? It will become a big mess in your view model.

![](https://miro.medium.com/v2/resize:fit:875/1*l4IvD5E5Rg9SmE_3sa8q4A.jpeg)

## Please, get to the darn point!

No! We need more context. This article is not just to poop out some code, it is a journey. I hear you thinking: But Joost, how about a sealed interface that contains a Loading/Success/Failure types? We could just expose like a Flow<LoadingResult> from our repository when we load data? Possible have a use case that just returns a flow of data and does all kinds of magic inside and then take the load off the view model? Then we can have stuff like:

```kotlin
class DataRepository(private val dataNetworkSource: DataNetworkSource) {

  fun fetchData: Flow<LoadingResult<Data>> = flow {
    emit(LoadingResult.Loading)
    dataNetworkSource.fetchData().onSuccess { data ->
      emit(LoadingResult(data))
    }.onFailure { exception ->
      emit(LoadingResult.Failure(exception)
    }
  }

}
```

This piece of code is like making love with your spouse: even if it feels right, it’s still wrong! Repeat after me: Your domain layer does not give a single shit about your presentation layer! The concept of somehow exposing a loading state does not make sense: It is like driving in a car with the word “CAR” written on the side: Yeah, we know. We are gonna load data, get over it. We do not need a whole flow to load exactly one thing asynchronously as there is a much simpler tool for that: a suspend function. Our domain layer should expose simple objects without too many logic under the hood:

```kotlin
class DataRepository(/* Dependencies */) {

  fun fetchDataFromMemory(): Result<Data> = memoryCache.getData()
  suspend fun fetchData: Result<Data> = dataNetworkSource.fetchData()
  fun observeData(): Flow<Data> = database.observeData()

}
```

## But I really like the concept of loading result!

Luckily, me too! But we only need it later on, right in our presentation layer! Anything before that either can be a simple object, or be wrapped into a Kotlin.Result class. Let’s define a simple sealed interface called LoadingResult. Let us think for a minute what we want it to do. We want it to be able to hold 3 different states: Loading, Success and Failure. We also want to be able to see whether we are loading data or not, so without further ado, lets make the class:

```kotlin
sealed interface LoadingResult<out T> {
  val isLoading: Boolean

  data class Success<T>(
    val value: T, 
    override val isLoading: Boolean = false,
  ) : LoadingResult<T>

  data class Failure(
    val throwable: Throwable, 
    override val isLoading: Boolean = false,
  ) : LoadingResult<Nothing>

  data object Loading: LoadingResult<Nothing> {
    override val isLoading: Boolean = true
  }
}

fun <T> loading(): LoadingResult<T> = LoadingResult.Loading

fun <T> loadingSuccess(
  value: T,
): LoadingResult<T> = LoadingResult.Success(value)

fun <T> loadingFailure(
  throwable: Throwable,
): LoadingResult<T> = LoadingResult.Failure(throwable)

fun <T> Result<T>.toLoadingResult() = fold(
   onSuccess = { loadingSuccess(it) }, 
   onFailure = { loadingFailure(it) },
)

fun <T,R> LoadingResult<T>.map(
  block: (T) -> R,
): LoadingResult<R> = when(this) {
  is LoadingResult.Success -> LoadingResult.Success(block(value), isLoading)
  is LoadingResult.Failure -> LoadingResult.Failure(throwable, isLoading)
  is LoadingResult.Loading -> LoadingResult.Loading
}

fun <T> LoadingResult<T>.toLoading(): LoadingResult<T> = when(this) {
  is LoadingResult.Success -> copy(isLoading = true)
  is LoadingResult.Failure -> copy(isLoading = true)
  is LoadingResult.Loading -> LoadingResult.Loading
}
```

You can see I even took the time to write some extension functions. What are they all about you may ask? I think Mr. Mouse can answer that for you:

![](https://miro.medium.com/v2/resize:fit:850/1*3qyspezHY62iqGvXHP6xuQ.jpeg)


All you need to know, is that we now have a class that can hold a state, as well as indicate whether we are loading data or not. Together with the power of the Kotlin Result class we can do some mighty things!

## Let’s load some data!

Wouldn’t it be great if our view model could hold a certain data state that in itself can tell the view model to load data? I hear you thinking: A value that triggers work: That sounds like an awesome way to do some accidental perpetual work and ruin everything! However, with the power of using our brains, we should be able to make this work perfectly fine.

These are the rules:

-   If possible, we want to load data from memory and display it to the user without delay as soon as the user enters the screen
-   If no data is available, we want to display a loading screen
-   If loading data fails, we want to handle it gracefully and offer retry logic
-   Once data is loaded successfully and displayed to the user, we want the user to be able said data and inform them of any mishaps

Even though it sounds like an awful lot of work, I am sure we can condense this into 1 simple function. Let’s get started! As mentioned before, we want to create a data stream that in itself will trigger updates. Let’s create a new interface to hold our data loader. We will iterate over the problem until we find the right solution. The first version will be rather simple: We set up our frame and make a function return a flow of input data.

```kotlin
sealed interface DataLoader<T> {

  fun loadAndObserveData(
    initialData: LoadingResult<T>,
  ) : Flow<LoadingResult<T>>

}

// public api to instantiate a data loader.
fun <T> DataLoader(): DataLoader<T> = DefaultDataLoader()

private class DefaultDataLoader<T>: DataLoader<T> {

  override fun loadAndObserveData(
    initialData: LoadingResult<T>,
  ): Flow<LoadingResult<T>> = flow {
    // Whatever happens, emit the current result
    emit(initialData)
  }

}
```

I can hear you thinking: why is that a sealed interface with a private implementation, what the hell is even that? Well, it is a thing I picked up from scouring the Kotlin and Jetpack Compose source code! In there you will often find files exposing a public interface, while hiding implementation in an internal or private class and offering a function for easy instantiation. It could be a standalone method, but this is a nice way to offer a simple interface while hiding implementation details. We only want one and only one behavior here, and as it is an interface and not a method, we will have a much easier time mocking the behavior. Also, this allows us to extend the interface later on. Which we will do right about ….. now:

```kotlin
sealed interface DataLoader<T> {

  fun loadAndObserveData(
    initialData: LoadingResult<T>,
    observeData: (T) -> Flow<T>,
    fetchData: suspend (LoadingResult<T>) -> Result<T>,
  ) : Flow<LoadingResult<T>>

}

// public api to instantiate a data loader.
fun <T> DataLoader(): DataLoader<T> = DefaultDataLoader()

private class DefaultDataLoader<T>: DataLoader<T> {

  override fun loadAndObserveData(
    initialData: LoadingResult<T>,
    observeData: (T) -> Flow<T>,
    fetchData: suspend (LoadingResult<T>) -> Result<T>,
  ): Flow<LoadingResult<T>> = flow {
    // Little helper method to observe the data and map it to a LoadingResult
    val observe: (T) -> Flow<LoadingResult<T>> = { value -> 
      observeData(value).map { loadingSuccess(it) } 
    }
    // Whatever happens, emit the current result
    emit(initialData)
    when {
      // If the current result is loading, we fetch the data and emit the result
      initialData.isLoading -> {
        val newResult = fetchData(initialData)
        emit(newResult.toLoadingResult())
        // If the fetching is successful, we observe the data and emit it
        newResult.onSuccess { value -> emitAll(observe(value)) }
      }
    
      // If the current result is successful, we simply observe and emit the data changes
      initialData is LoadingResult.Success -> emitAll(observe(initialData.value))
      else -> {
        // Nothing to do in case of failure and not loading
      }
    }
  }
  
}
```

The core concept here:

-   Input the initial state. This is supposed to be any state that is a loading result. For example, if you pass in loading(), you will turn the data loader into a loading state and it will start fetching data.
-   The observe data parameter. This parameter is to produce a flow of data that will be emitted once the data has been successfully loaded
-   The fetchData parameter. This is a lambda which we use to fetch data asynchronously, using a simple suspend function. This lambda is only invoked if the data loader is in a loading state! That means, if the isLoading on the initialData returns true, we invoke fetch data. If the fetch data was successful, we also start observing on possible data changes.

Anyway, let’s put it to the test!

```kotlin
val dataLoader = DataLoader<Int>()

dataLoader.loadAndObserveData(
  initialData = loading(),
  observeData = { flowOf(2,3) },
  fetchData = { success(1) },
).collect {
  println(it)
  /* Prints:
  Loading
  Success(value = 1, isLoading = false),
  Success(value = 2, isLoading = false),
  Success(value = 3, isLoading = false),
  */
}

dataLoader.loadAndObserveData(
  initialData = loadingFailure(Exception()),
  observeData = { flowOf(2,3) },
  fetchData = { success(1) },
).collect {
  println(it)
  /* Prints:
  Failure(throwable=java.lang.Exception, isLoading = false)
  */
}

dataLoader.loadAndObserveData(
  initialData = loadingFailure(Exception(), isLoading = true),
  observeData = { flowOf(2,3) },
  fetchData = { success(1) },
).collect {
  println(it)
  /* Prints:
  Failure(throwable=java.lang.Exception, isLoading = true)
  Success(value = 1, isLoading = false),
  Success(value = 2, isLoading = false),
  Success(value = 3, isLoading = false),
  */
}

dataLoader.loadAndObserveData(
  initialData = loadingSuccess(1),
  observeData = { flowOf(2,3) },
  fetchData = { success(5) },
).collect {
  println(it)
  /* Prints:
  Success(value = 1, isLoading = false),
  Success(value = 2, isLoading = false),
  Success(value = 3, isLoading = false),
  */
}

dataLoader.loadAndObserveData(
  initialData = loadingSuccess(1, isLoading = true),
  observeData = { flowOf(2,3) },
  fetchData = { success(5) },
).collect {
  println(it)
  /* Prints:
  Success(value = 1, isLoading = true),
  Success(value = 5, isLoading = false),
  Success(value = 2, isLoading = false),
  Success(value = 3, isLoading = false),
  */
}

dataLoader.loadAndObserveData(
  initialData = loading(),
  observeData = { flowOf(2,3) },
  fetchData = { failure(Exception()) },
).collect {
  println(it)
  /* Prints:
  Loading
  Failure(throwable=java.lang.Exception, isLoading = false)
  */
}
```

As you can see, it will fetch data if `isLoading` is true, and if the results are in a success state, it will observe on data changes. So, how about those refreshes? How about gracefully recovering from failure? How about states instead of flows? Calm down! I can only do one thing at a time.

We are talking about a reactive stream of data. How do you influence such a declared data structure? It is not like I have data stored in a bunch of fields and I can make a mess with side effects. For some inspiration. we can have a look at Jetpack Compose: you will find that helper objects can be used to influence behavior of a composed view. If we look at how we can bring a view into focus, we can simply add a FocusRequester to a modifier and request focus using this modifier:

```kotlin
@Composable
fun Something(/*params*/) {
  val focusRequester = remember { FocusRequester() }
  LaunchedEffect(event) { // Some event trigger
    if (event == Event.RequestFocus) {
      focusRequester.requestFocus()
    }
  }
  TextField(
    modifier = Modifier
      .focusRequester(focusRequester),
    value = value,
    onValueChange = onValueChanged,
  )
}
```

You can see here, that even though our UI is in a declarative style, we can use a simple helper to influence the behavior of our functionally created UI. All we need to do, is instantiate a helper class and hook it into the logic! Knowing this, we can implement a class that can act as a trigger for a refresh and for the heck of it, we call it RefreshTrigger. In this case, we only expose a single method and hide all the implementation details. For my needs, it is crucial that nobody goes around and implements their own versions that will not be compatible with my data loader later on. The concept of the refresh trigger is simple: Any time you hit `refresh`, we simply emit a Unit on a shared flow.

```kotlin
/* Data loader class will be in the same file so it can access private parts */

sealed fun interface RefreshTrigger {
  suspend fun refresh()
}

fun RefreshTrigger(): RefreshTrigger = DefaultRefreshTrigger()

private class DefaultRefreshTrigger: RefreshTrigger {

  private val _refreshEvent = MutableSharedFlow<Unit>()
  val refreshEvent = _refreshEvent.asSharedFlow()

  override suspend fun refresh() {
    _refreshEvent.send(Unit)
  }

}
```

After making our trigger, we only need our data loader to react to these refresh events! It will be simple enough to pass it as a nullable argument to our `loadAndObserveData(..)` function we have defined before. The only tricky part is: How the hell will some shared flow emitting a Unit help us here to reload a bunch of data? If you remember, our load and observe data function triggers work based on the input state. We give it an initial state, and then it goes to town on that. So… How about we change the input state, based on our refresh trigger? As you saw before, our loadAndObserveData was basically a flow. What if, we could restart that flow with different inputs? What if, we can do that easily by mapping the event flow into another flow? Kotlin has an amazing coroutine library that offers methods like flatMapLatest. It will map a flow to another flow and flatten it, just as how you can flat map a list of lists.

```kotlin
val flow1 = flow {
  emit(1)
  delay(10)
  emit(2)
  delay(10)
  emit(3)
}
flow1.flatMapLatest { number ->
  flow {
    emit("...")
    emit("number: $number")
    emit("...")
  }
}.collect {
  /* Collects:
  "..."
  "number: 1"
  "..."
  "..."
  "number: 2"
  "..."
  "..."
  "number: 3"
  "..."
  */
}
```

Lets look how we could use similar logic to trigger a refresh of data. The following example should give you the right picture: Every time the refreshEvent emits a new value, we start to load data and then observe.

```kotlin
fun simplifiedExample(
  val refreshEvent: Flow<Unit>,
  val loadData: suspend () -> Int,
  val observeData: Flow<Int>,
): Flow<Int> {
  refreshEvent.flatMapLatest {
    flow { // Any time refreshEvent emits a value, this flow is recreated
      emit(loadData())
      emitAll(observeData())
    }
  }
}
```

You may notice: The work will be blocked until the first refresh event is triggered. We can easily fix this by emitting our own event at start by ourselves!

```kotlin
fun flatMapExample(
  val refreshEvent: Flow<Unit>,
  val loadData: suspend () -> Int,
  val observeData: Flow<Int>,
): Flow<Int> {
  flow {
    emit(Unit) // <- first emit an element to get the show on the road
    emitAll(refreshEvent) // <- afterwards emit any refresh event
  }.flatMapLatest {
    flow {
      emit(loadData())
      emitAll(observeData())
    }
  }
}
```

So knowing this, we can do some magic! Finally, we got to the magic part. We will start off by adding our refresh trigger to the original interface, and we can even make it optional. After that, we take the original function of the implementation and make it private, because the contents are still valid, it just needs some extra sauce on top.

```kotlin
sealed interface DataLoader<T> {

  fun loadAndObserveData(
    initialData: LoadingResult<T>,
    refreshTrigger: RefreshTrigger? = null,
    observeData: (T) -> Flow<T>,
    fetchData: suspend (LoadingResult<T>) -> Result<T>,
  ) : Flow<LoadingResult<T>>

}

private class DefaultDataLoader<T>: DataLoader<T> {

  override fun loadAndObserveData(
    initialData: LoadingResult<T>,
    refreshTrigger: RefreshTrigger? = null,
    observeData: (T) -> Flow<T>,
    fetchData: suspend (LoadingResult<T>) -> Result<T>,
  ) : Flow<LoadingResult<T>> = TODO("Patience my friend...")

  private fun loadAndObserveData(
    result: LoadingResult<T>,
    observeData: (T) -> Flow<T>,
    fetchData: suspend (LoadingResult<T>) -> Result<T>,
  ): Flow<LoadingResult<T>> = flow {
    // Little helper method to observe the data and map it to a LoadingResult
    val observe: (T) -> Flow<LoadingResult<T>> = { value -> 
      observeData(value).map { loadingSuccess(it) } 
    }
    // Whatever happens, emit the current result
    emit(result)
    when {
      // If the current result is loading, we fetch the data and emit the result
      initialData.isLoading -> {
        val newResult = fetchData(result)
        emit(newResult.toLoadingResult())
        // If the fetching is successful, we observe the data and emit it
        newResult.onSuccess { value -> emitAll(observe(value)) }
      }
    
      // If the current result is successful, we simply observe and emit the data changes
      result is LoadingResult.Success -> emitAll(observe(result.value))
      else -> {
        // Nothing to do in case of failure and not loading
      }
    }
  }
  
}
```

Then, we implement the new `loadAndObserveData` function where we will `flatMap` the refresh events into a new stream of data loading! The magic sauce we add, is that instead of using a Unit to start refreshing the data, we keep track of our last emitted value. Every time we trigger a refresh, we turn the last emitted value into a loading state (with our amazing `LoadingResult.toLoading()` extension function) and use that as an input for the `loadAndObserveData` method we defined earlier!

```kotlin
override fun loadAndObserveData(
  refreshTrigger: RefreshTrigger?,
  initialData: LoadingResult<T>,
  observeData: (T) -> Flow<T>,
  fetchData: suspend (LoadingResult<T>) -> Result<T>,
): Flow<LoadingResult<T>> {
  val refreshEventFlow = refreshTrigger.asInstance<DefaultRefreshTrigger>()?.refreshEvent ?: emptyFlow()

  // We store the latest emitted value in the lastValue
  var lastValue = initialData
  
  return flow {
    // Emit the initial data. This will make sure we start all the work 
    // as soon as this flow is collected
    emit(lastValue)
    // Every time we collect a refresh event, we should emit the last
    // value with the isLoading flag turned to true
    refreshEventFlow.collect {
      // Make sure we do not emit if we are already in a loading state
      if (!lastValue.isLoading) {
        emit(lastValue.toLoading())
      }
    }
  }
    .flatMapLatest { currentResult -> 
      // We simply use the good old loadAndObserveData function we already made
      loadAndObserveData(currentResult, observeData, fetchData) 
    }
    // No need to emit similar values, so make them distinct
    .distinctUntilChanged() 
    // Store latest value into lastValue so we can reuse it for the next
    // refresh trigger
    .onEach { lastValue = it }
}

private fun loadAndObserveData(
  result: LoadingResult<T>,
  observeData: (T) -> Flow<T>,
  fetchData: suspend (LoadingResult<T>) -> Result<T>,
): Flow<LoadingResult<T>> = flow {
  // Little helper method to observe the data and map it to a LoadingResult
  val observe: (T) -> Flow<LoadingResult<T>> = { value -> 
    observeData(value).map { loadingSuccess(it) } 
  }
  // Whatever happens, emit the current result
  emit(result)
  when {
    // If the current result is loading, we fetch the data and emit the result
    initialData.isLoading -> {
      val newResult = fetchData(result)
      emit(newResult.toLoadingResult())
      // If the fetching is successful, we observe the data and emit it
      newResult.onSuccess { value -> emitAll(observe(value)) }
    }
  
    // If the current result is successful, we simply observe and emit the data changes
    result is LoadingResult.Success -> emitAll(observe(result.value))
    else -> {
      // Nothing to do in case of failure and not loading
    }
  }
}
```

This is amazing. But we are not there yet! UI’s are build on states, but all I got is this lousy flow. Wait a minute, what is that? Is it a bird, is it a plane? No, it is StateFlow Man!

![](https://miro.medium.com/v2/resize:fit:875/1*NiFTeXE_fp8Uk4wZyHDTgA.jpeg)

Here I was pondering over the idea to write extension functions instead of adding functionality to our interface. But for mocking reasons, I decided it is easier to understand and mock the functionality if I add the following function with a default implementation to the interface:

```kotlin
sealed interface DataLoader<T> {

  fun loadAndObserveDataAsState(
    coroutineScope: CoroutineScope,
    initialData: LoadingResult<T>,
    refreshTrigger: RefreshTrigger? = null,
    observeData: (T) -> Flow<T>,
    fetchData: suspend (LoadingResult<T>) -> Result<T>,
  ): StateFlow<LoadingResult<T>> = loadAndObserveData(
    initialData = initialData,
    refreshTrigger = refreshTrigger,
    observeData = observeData,
    fetchData = fetchData,
  ).stateIn(
    scope = coroutineScope,
    started = SharingStarted.WhileSubscribed(),
    initialValue = initialData,
  )

  fun loadAndObserveData(
    initialData: LoadingResult<T>,
    refreshTrigger: RefreshTrigger? = null,
    observeData: (T) -> Flow<T>,
    fetchData: suspend (LoadingResult<T>) -> Result<T>,
  ): Flow<LoadingResult<T>>

}
```

It is unbearably simple: We add a Coroutine scope and simply convert the flow returned by our original function into a state flow. Problem solved! How to use it? It is simple! You can directly instantiate the data loader in your view model, or you can write a helper class for that. In this helper class, you can bundle any dependencies related to loading of data, keeping your view model clean. In the following example we add 3 data loading dependencies, but you can mix/match them however you see fit!

```kotlin
interface ExampleDataLoader {

  fun loadAndObserveData(
    coroutineScope: CoroutineScope,
    refreshTrigger: RefreshTrigger,
    onRefreshFailure: (Throwable) -> Unit,
  ): StateFlow<LoadingResult<Int>>

}

internal class DefaultExampleDataLoader(
  private val fetchIntFromMemoryUseCase: FetchIntFromMemoryUseCase = FetchIntFromMemoryUseCase,
  private val fetchIntUseCase: FetchIntUseCase = FetchIntUseCase,
  private val observeIntUseCase: ObserveIntUseCase = ObserveIntUseCase,
  private val dataLoader: DataLoader<Int> = DataLoader(),
) : ExampleDataLoader {

  override fun loadAndObserveData(
    coroutineScope: CoroutineScope,
    refreshTrigger: RefreshTrigger,
  ) = dataLoader.loadAndObserveDataAsState(
    coroutineScope = coroutineScope,
    refreshTrigger = refreshTrigger,
    initialData = fetchIntFromMemoryUseCase.fetchInt().fold(
      onSuccess = { loadingSuccess(it) },
      onFailure = { loading() },
    ),
    observeData = { observeIntUseCase.observeInt() },
    fetchData = { fetchIntUseCase.fetchInt() },
  )

}
```

In this case, your view model will be very clean. You wrapped all those loading dependencies into a helper class, and all that is left is to map the data into an actual state. Notice how we do not start up any work in the view model in some init method? Notice how the data loading is bound to the view model scope? Notice we can still refresh our data easily? We simply map one state into another! No if’s, no else’s, no checks or added logic, resulting in a shear lack of side effects!

```kotlin
class ExampleViewModel(
  exampleDataLoader: ExampleDataLoader = DefaultExampleDataLoader(),
  private val exampleDataMapper: ExampleDataMapper = ExampleDataMapper,
  private val refreshTrigger: RefreshTrigger = RefreshTrigger(),
) : ViewModel() {

  private val data = exampleDataLoader.loadAndObserveData(
    coroutineScope = viewModelScope,
    refreshTrigger = refreshTrigger,
  )
  
  val screenState = data.map { exampleDataMapper.map(it) }.stateIn(
    scope = viewModelScope,
    started = SharingStarted.WhileSubscribed(),
    initialValue = exampleDataMapper.map(data.value),
  )
  
  fun refresh() {
    viewModelScope.launch {
      refreshTrigger.refresh()
    }
  }

}
```

Now, I was kind enough to create an example project. It even displays a random number for you and it shows how to display such a nice LoadingResult object in your UI! You can find the link right here:

In this example project, I added an extra behavior to our DataLoader where we can recover gracefully from refresh failures. This extra behavior was implemented by simply adding a new function and I did not have to make any changes to the original implementation. This new method allows us to add a new parameter with a callback that is invoked when data is displayed but refreshing it fails. Also, in that case it will simply display the old value it already had loaded instead of jumping to an failure screen. All this is done by encapsulating this behavior in the fetchData lambda, after which this method simply calls the original loadAndObserveData method.

```kotlin
fun loadAndObserveData(
  refreshTrigger: RefreshTrigger? = null,
  initialData: LoadingResult<T> = loading(),
  observeData: (T) -> Flow<T> = { emptyFlow() },
  fetchData: suspend (LoadingResult<T>) -> Result<T>,
  onRefreshFailure: (Throwable) -> Unit,
): Flow<LoadingResult<T>> = loadAndObserveData(
  refreshTrigger = refreshTrigger,
  initialData = initialData,
  observeData = observeData,
  fetchData = { oldValue: LoadingResult<T> ->
    // Try to reuse old value if the new value is a failure.
    fetchData(oldValue).fold(
      onSuccess = { success(it) },
      onFailure = { exception ->
        if (oldValue is LoadingResult.Success) {
          // If we successfully recover the old value, we call the onRefreshFailure callback
          onRefreshFailure(exception)
          success(oldValue.value)
        } else {
          failure(exception)
        }
      }
    )
  },
)
```

This results in some nice and user friendly behavior, where we can display in memory data directly, load data, refresh data and gracefully handle errors.

![](https://miro.medium.com/v2/resize:fit:338/1*1-GD3_Uakg3K0ZLMgO7GpQ.gif)

Directly loaded with data, no loading spinner! If refresh fails, we show a snackbar.

![](https://miro.medium.com/v2/resize:fit:338/1*q-agzm-1hyeOhlLsn4x8Pw.gif)

Loading necessary at first. If refresh fails, we show a snackbar.

![](https://miro.medium.com/v2/resize:fit:338/1*M6ugHt2wiVTJks5kCYDLSg.gif)

Failure to load data can be recovered gracefully.

The data loader is very friendly to extension and you can combine different sources of data as how you see fit, making it reusable for all your data loading needs! I hope you enjoyed this article. I think it is time for a good old “That’s all folks”! I am hungry, I am thirsty, it is time to say goodbye!

source: https://proandroiddev.com/the-best-way-to-load-data-in-viewmodels-a112ced54e07
