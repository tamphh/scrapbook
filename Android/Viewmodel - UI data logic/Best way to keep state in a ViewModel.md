# Best way to keep state in a ViewModel

I am going to add the same disclaimer as with my previous story marked as “The best…”: It is according to me! Awhile back, I wrote [an article](https://proandroiddev.com/the-best-way-to-load-data-in-viewmodels-a112ced54e07) on how to load data in a ViewModel. Today, we will see the best practices on how to handle state and events in a ViewModel. If you combine the two articles, you will have a powerful foundation to build your application on.

## The problem of side effects

As always, let’s start with the problem we are trying to solve: side effects. Side effects are nasty buggers, sometimes more avoidable than other times. Side effects can lead to unwanted and unpredictable states, and they complicate testing as you will have to push your class under testing through a path of interactions to get it into the right state. You always have to take good care of them, as they can cause edge cases as the outcome of using side effects may be surprising.

## The problem of truth

Often, you will have to decide what your source of truth is. In ViewModel land, there are 2 sources of truth: either the ViewModel, or not the ViewModel. More often than not, the source of truth is not the ViewModel. So how do we decide where we keep the original information? I like to keep it separating in the following:

1.  If we display data, we use data directly from the source, often the repository.
2.  If we edit data, we copy the data into the ViewModel and the ViewModel becomes the source of truth.

![](https://miro.medium.com/v2/resize:fit:1400/1*Gpc2CQL6OYoRCdQZ0IHNXA.jpeg)

Android mascot battling bugs created by side-effects, by [Copilot](https://www.bing.com/chat)

## Displaying data

So let’s set up the premise for the first case where we simply display data.

-   We reuse the concept of [data loader, found here](https://proandroiddev.com/the-best-way-to-load-data-in-viewmodels-a112ced54e07)
-   We use Kotlin’s [Result](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin/-result/) class to load data
-   We use a [LoadingResult](https://github.com/joost-klitsie/DataLoadingExample/blob/master/app/src/main/java/com/klitsie/dataloading/LoadingResult.kt) described [here](https://proandroiddev.com/the-best-way-to-load-data-in-viewmodels-a112ced54e07) to display loading and failure states in the UI
-   We use the function mapState I explained [here](https://medium.com/@joostklitsie/livedata-is-dead-long-live-stateflow-ecd7e03b1777).
-   We abstract away mapping the data to a view state in a mapper

```kotlin
@Stable
class DetailsViewModel(
  private val fetchDataUseCase: FetchDataUseCase,
  private val observeDataUseCase: ObserveDataUseCase,
  private val mapper: SomeViewStateMapper,
  dataLoader: DataLoader<SomeData>  = DataLoader(),
  private val refreshTrigger: RefreshTrigger = RefreshTrigger(),
) : ViewModel {

 private val someData = dataLoader.loadAndObserveDataAsState(
   coroutineScope = viewModelScope,
   refreshTrigger = refreshTrigger,
   observeData = { observeDataUseCase.run() },
   fetchData = { fetchDataUseCase.run() },
 )

 val viewState = someData.mapState(
   coroutineScope,
   mapper::map,
 )

}

@Immutable
data class SomeViewState(
  val title: String, // should be translatable, this is just an example
  val body: String, // should be translatable, this is just an example
  val lastUpdated: String, // should be translatable, this is just an example
)

class SomeViewStateMapper {
  
  fun map(
    result: LoadingResult<SomeData>,
  ): LoadingResult<SomeViewState> = result.map { data ->
    val minutesSinceLastUpdate = (Clock.System.now() - data.lastUpdate).minutes
    SomeViewState(
      title = "Welcome ${data.username}",
      body = data.content,
      lastUpdated = "Last updated $minutesSinceLastUpdate ago",
    )
  }

}

fun <T, R> StateFlow<T>.mapState(
  scope: CoroutineScope,
  started: SharingStarted = SharingStarted.Eagerly,
  map: (T) -> R,
) = mapLatest { map(it) }.stateIn(scope, started, map(value))
```

As you can see, this is a simple example. It is quite easy to test the ViewModel itself, as we don’t care about the mapping and we don’t care about the loading logic from the ViewModel tests. All we need to do is verify if certain functions are called and we can make it return a mock. The mapper will have a dedicated test class, where we simply have input->output tests, and the DataLoader should already have its own dedicated tests without any ViewModel dependency.

## Raw state

You can notice that the ViewModel loads raw data, an object called SomeData, with some use cases. We store the raw data into its own field, called someData. I do expect you to come up with your own and better names ;). This field is representing the source of truth: It is the raw data which in itself we cannot directly display on the screen, as that would be user unfriendly. We use a dedicated mapper to map our data into the view state, which we store in a state as a public field that an actual view, like a Composable function, can collect. We separate the raw data from the view state, as often we can have the case where we can have multiple data inputs for a view state.

## Multiple inputs for ViewState

Lets update the example a bit. As [in this article](https://medium.com/@joostklitsie/livedata-is-dead-long-live-stateflow-ecd7e03b1777) (implementation detailed below) we can also combine states with a simple extension function. Now you are supposedly able to see exactly why we kept our raw state separate from the view state:

```kotlin
@Stable
class DetailsViewModel(
  private val fetchDataUseCase: FetchDataUseCase,
  private val observeDataUseCase: ObserveDataUseCase,
  private val observeUserUseCase: ObserveUserUseCase,
  initialUser: User, // <-- initial user injected into the view model
  private val mapper: SomeViewStateMapper,
  dataLoader: DataLoader<SomeData>  = DataLoader(),
  private val refreshTrigger: RefreshTrigger = RefreshTrigger(),
) : ViewModel() {

  private val someData = dataLoader.loadAndObserveDataAsState(
    coroutineScope = viewModelScope,
    refreshTrigger = refreshTrigger,
    observeData = { observeDataUseCase.run() },
    fetchData = { fetchDataUseCase.run() },
  )

  private val user = observeUserUseCase.stateIn(
    scope = viewModelScope,
    sharingStarted = SharingStarted.WhileSubscribed(),
    initialValue = initialUser,
  )

  val viewState = combineToState(
    coroutineScope,
    someData,
    user,
  ) { someData, user ->
    mapper.map(someData, user)
  }

}

fun <T1, T2, R> combineToState(
  scope: CoroutineScope,
  flow1: StateFlow<T1>,
  flow2: StateFlow<T2>,
  started: SharingStarted = SharingStarted.WhileSubscribed(),
  map: (T1, T2) -> R,
) = combine(flow1, flow2) { value1, value2 ->
  value1 to value2
}.mapLatest { (value1, value2) ->
  map(value1, value2)
}.stateIn(scope, started, map(flow1.value, flow2.value))
```

Now you can see that whenever a user changes or some data is changing, the mapper will be invoked and our view state is automatically updated. No if statements, no result checking, the ViewModel is hooking up everything to each other and not imposing logic. If you have more states, you can simply add new combineToState functions that take more parameters, just like the Flow’s combine function works.

## Separate event handling

I like to keep my events separate. I see in many examples that events are somehow wrapped inside view states. I used to do this as well. However, in our case that would be weird: Our view state is mapped inside a LoadingState. That would mean we would only have events if the data was successfully loaded, OR we would wrap the whole thing into some kind of mega state:

```kotlin
data class SuperViewState( // Not a good name, I know :)
  val viewState: LoadingState<ViewState>,
  val event: SomeEvent? = null,
)

data class ViewState(..)
```

I noticed I was just passing the event into the mapper and then adding it to a field without adding any logic on top. This is useless, it is much easier to do have the following:

```kotlin
sealed interface SomeEvent {

  data object Close: SomeEvent
  data class OpenSomethingElse(val id: SomethingElseId)

}

@Stable
class DetailsViewModel(
  /* Dependencies */
) : ViewModel() {

  private val someData = dataLoader.loadAndObserveDataAsState(
    coroutineScope = viewModelScope,
    refreshTrigger = refreshTrigger,
    observeData = { observeDataUseCase.run() },
    fetchData = { fetchDataUseCase.run() },
  )

  private val user = observeUserUseCase.stateIn(
    scope = viewModelScope,
    sharingStarted = SharingStarted.WhileSubscribed(),
    initialValue = user,
  )

  private val _event = MutableStateFlow<SomeEvent?>(null)

  val viewState = combineToState(
    coroutineScope,
    someData,
    user,
  ) { someData, user ->
    mapper.map(someData, user)
  }

  val event = _event.asStateFlow()

  fun onClose() {
    _event.update { SomeEvent.Close }
  }

  fun onSomethingElsePressed(id: SomethingElseId) {
    _event.update { SomeEvent.OpenSomethingElse(id) }
  }

  fun onConsumeEvent {
    _event.update { null }
  }

}
```

If we have a simple composable, event handling is simple. You collect the events just like how you would collect the view state:

```kotlin
@Composable
fun ExampleScreen(
  onClose: () -> Unit,
  openSomethingElse: (SomethingElseId) -> Unit,
  modifier: Modifier = Modifier,
  viewModel: DetailsViewModel = viewModel(),
) {
  val viewState by viewModel.viewState.collectAsState()
  val event by viewModel.event.collectAsState()
  LaunchedEffect(event) {
    when (val someEvent = event) {
      null -> return@LaunchedEffect
      SomeEvent.Close -> onClose()
      SomeEvent.OpenSomethingElse -> openSomethingElse(someEvent.id)
    }
    viewModel.consumeEvent()
  }
  // Rest of content
}
```

## Editing data

So now we can display data, lets create a view model that can support us when we are editing data. Now as mentioned before, we will turn the ViewModel into the source of truth for this one. We can do that in two ways: We can either pass the initial data into the constructor, or we can fetch the initial data. Both options have pros and cons, which we will discover.

## Injecting data into ViewModel

This is the easiest: You inject the original data and we are good to go! No loading logic, no problems.

```kotlin
@Stable
class EditUserViewModel(
  initiaUser: User,
  private val updateUserUseCase: UpdateUserUseCase,
  private val mapper: EditUserViewStateMapper,
): ViewModel() {

  private val user = MutableStateFlow(initiaUser)
  private val errors = MutableStateFlow<Map<UserField, String>>(emptyMap())
  private val isLoading = MutableStateFlow(false)

  val viewState = combineState(
    scope = viewModelScope,
    user,
    errors,
    isLoading,
    map = mapper::map
  )

  fun onFirstNameChanged(firstName: String) {
    if (isLoading.value) return
    user.update { it.copy(firstName = firstName) } 
    errors.update { it - UserField.FirstName }
  }

  fun onLastNameChanged(lastName: String) {
    if (isLoading.value) return
    user.update { it.copy(lastName = lastName) }
    errors.update { it - UserField.LastName }
  }

  fun onTitleChanged(title: String) {
    if (isLoading.value) return
    user.update { it.copy(title = title) }
    errors.update { it - UserField.Title}
  }

  fun onSubmit() {
    if (isLoading.value) return
    isLoading.update { true }
    viewModelScope.launch {
      updateUserUseCase.run(user.value).onSuccess {
        // close screen with event
      }.onFailure {
        // handle errors, input errors or network errors or whatever
      }
    }.invokeOnCompletion { isLoading.update { false } }
  }

}
```

## Disadvantage of injecting data

You need to get the user and pass it around. This means that you will probably have to somehow make sure you can use a navigation framework that is able to pass in navigation destinations that contains a certain User object within the destinations’ route. In my project we have gotten around this by turning objects into JSON. Newer versions of the Android Navigation libraries luckily do allow you to pass objects as navigation arguments.

However, solving navigation is one thing: Solving outdated objects is another. If your app gets destroyed and you restart it a week later, chances are that you initialize the screen with the 1 week old data, possibly overriding newer updates once you hit the save button!

## Fetching data in the ViewModel

Another way to load the data is to first fetch the data from within the ViewModel, handle loading and errors as well and then allow for the data to be overridden. I will not give the example here, but you can imagine that the view model will have multiple problems to overcome. Whenever a method is called, we first need to verify that the data is loaded and we can actually make some changes. We also need to make sure the screen displays loading and errors properly. It would be annoying to handle loading data, as well as adjusting data inside the same ViewModel. However, we will always be sure that the user is updating up to date information, and we will have no trouble with our navigation graphs.

## Or… Combining the fetching and injecting

We could also have two ViewModels: one for fetching the data, and one for editing it! You can easily nest the two and be quite happy.

```kotlin
@Stable
class LoadUserViewModel(
  private val userId: UserId,
  private val fetchUserUseCase: FetchUserUseCase,
  dataLoader: DataLoader<User> = DataLoader(),
  private val refreshTrigger: RefreshTrigger,
): ViewModel() {

  val userResult = dataLoader.loadAndObserveDataAsState(
    coroutineScope = viewModelScope,
    refreshTrigger = refreshTrigger,
    fetchData = { fetchUserUseCase.run(userId) },
  )

  fun onRefresh() {
    viewModelScope.launch { refreshTrigger.refresh() }
  }

}

// inside NavHost
// ...
  composable("user/edit/{userId}") { navBackStackEntry ->
    EditUserScreen(
      viewModel = viewModel {
        // Obviously, use your own injection framework to inject
        // view model with the userId param
        LoadUserViewModel(userId = /* get userId from navBackStackEntry */)
      },
      onClose = navHostController::popBackStack
    )
  }
// ...

@Composable
fun EditUserScreen(
  modifier: Modifier = Modifier,
  viewModel: LoadUserViewModel,
  onClose: () -> Unit,
) {
  val userResult by viewModel.userResult.collectAsState()
  LoadingResultScreen(
    modifier = modifier,
    onRefresh = viewModel::refresh,
    loadingResult = userResult,
  ) { user, _->
    EditUser(
      viewModel = viewModel {
        // Obviously, use your own injection framework to inject
        // the view model with the initial user param
        EditUserViewModel(initiaUser = user)
      },
      onClose = onClose,
    )
  }
}

@Composable
fun EditUser(
  viewModel: EditUserViewModel,
  onClose: () -> Unit,
) {
  val viewState by viewModel.viewState.collectAsState()
  // all the components to edit your events and user object here
}
```

In this case, we wrap the edit user screen into a screen component which has a ViewModel that can load data and display loading/failure/success states. Both the ViewModels will have the same scope and live and die together. Also, you can scope them to their Composable: I have written how you can scope view models to custom composable scopes in [this article](https://proandroiddev.com/composable-scoped-viewmodel-an-interesting-experiment-b982b86d84cd).

## Show me some gifs!

Putting it all together, here are some amazing gifs based purely on the code and concepts written in this article!

![](https://miro.medium.com/v2/resize:fit:800/1*BNgKDjKcXsU_ukXrhYA0jA.gif)

Promoting myself to senior

As you can see, we have screens that can load data themselves and handle validation and updates reactively without relying too much on side effects! As soon as we update the user in the editing, the first screen is automatically updated as well with the data from the application’s state. All the ViewModels used are easy to test: They don’t rely on side effects and all the state objects can be injected in one way or the other into the constructor.

I hope you liked this article. Let me know what you think in the comments! And as always: if you like what you see, put those digital hands together. Joost out.

source: https://proandroiddev.com/best-way-to-keep-state-in-a-viewmodel-d8334712265
