![](https://miro.medium.com/v2/resize:fit:700/1*C2Euk2Dc9H3Pyf7I9WY3cw.png)
Clean Architecture Logic and Separation of Each Modules

# Clean Architecture: Simplified and In-Depth Guide

Clean Architecture is a software design philosophy that emphasizes the separation of concerns, making it easier to manage, test, and maintain complex software systems. It organizes the code into layers, each with distinct responsibilities and dependencies, and is designed to be independent of frameworks, user interfaces, databases, and external agencies

## Introduction

Clean Architecture, introduced by **Robert C. Martin** (Uncle Bob), is a software design philosophy that emphasizes separation of concerns, making code easier to understand, maintain, and test. This architecture is particularly useful for complex systems, as it divides the application into layers with distinct responsibilities and dependencies, allowing for better scalability and adaptability to changes. Core Principles of Clean Architecture

![](https://miro.medium.com/v2/resize:fit:610/1*ojdeI_krveR7ay_6t2nubA.png)

## Core Principles of Clean Architecture

1.  **Separation of Concerns**: Different concerns (e.g., UI, business logic, data access) are isolated into distinct layers.
2.  **Independence of Frameworks**: The core logic of the application does not depend on external frameworks, making it easier to swap frameworks or upgrade them without affecting the core logic.
3.  **Testability**: The separation of concerns allows each layer to be tested independently.
4.  **Flexibility and Maintainability**: By organizing the code into layers, the system can adapt to changes more easily, and maintenance becomes less cumbersome.
5.  **Dependency Rule**: Dependencies should point inward, towards the core of the application. Outer layers depend on inner layers, but inner layers are independent of outer layers.

![](https://miro.medium.com/v2/resize:fit:700/1*6g0n5TNuiCs1OI76tsBzFA.jpeg)

Layers of Clean Architecture and flow

## Layers of Clean Architecture

## Data Layer

The Data layer is responsible for handling data from external sources, such as databases, web services, or device sensors. It consists of the following subdivisions:

-   **Data Sources**: Contains classes responsible for fetching data from various sources, such as REST APIs, local storage, or databases.
-   **Models**: Defines the data models used throughout the application.
-   **Repository**: Acts as an abstraction layer over data sources, providing a clean API for accessing and managing data.

## Domain Layer

The Domain layer contains the core business logic and rules of the application. It is independent of any external dependencies and consists of the following subdivisions:

-   **Entities**: Represent core business objects with their properties and behaviors.
-   **Use Cases**: Contains application-specific business rules and logic, orchestrating interactions between entities and data sources.
-   **Repository Interfaces**: Defines interfaces for repositories used to access data, decoupling the domain layer from specific data sources.

## Presentation Layer

The Presentation layer is responsible for handling user interface logic and interactions. It consists of the following subdivisions:

-   **BLoC (Business Logic Component):** Manages the application’s state and business logic, often based on the BLoC pattern.
-   **Pages**: Represents individual screens or views in the application, typically implemented as Flutter widgets.
-   **Widgets**: Reusable UI components used across multiple screens or pages.
-   **UI Controllers**: Handle user inputs and events, coordinating with BLoCs and other components to update the UI.

![](https://miro.medium.com/v2/resize:fit:700/1*gnFY_Ycfo6nvtV3jIgNmjw.png)

Layers and Connection of Clean Architecture

## Data Layer

In Flutter Clean Architecture, the data layer is responsible for managing the app’s data sources and providing data to the domain layer. It typically includes several key subparts: repositories, data sources (both remote and local), models (or entities), and data mappers. Each of these components has a specific role in ensuring data is retrieved, processed, and made available to other layers of the application in a clean and organized manner.

## Subparts of the Data Layer and Their Functions

## Repositories

-   **Function**: Repositories act as intermediaries between the domain layer and data sources (remote or local). They abstract the complexities of data access, providing a simple API for the domain layer to retrieve or persist data.
-   **Example**: A `UserRepository` might have methods like `getUserById(int id)` or `createUser(User user)`.
-   **Domain Repository Interface**: The domain layer defines repository interfaces. These interfaces declare the operations that the domain layer requires without specifying how these operations should be carried out. This ensures that the domain layer remains agnostic of the actual data retrieval mechanisms.

```dart
// UserRepository abstract class in domain Repository folder
abstract class UserRepository {
  Future<User> getUserById(int id);
  Future<void> createUser(User user);
}
```

-   **Data Repository Implementation**: The data layer provides concrete implementations of the domain repository interfaces. These implementations handle the actual data operations, such as fetching from a network or storing in a database

```dart
// UserRepository Implementation in data Repository folder
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<User> getUserById(int id) async {
    ...
  }

  @override
  Future<void> createUser(User user) async {
    ...
}
```

> **Dependency Inversion Principle**
> 
> The domain layer depends on abstractions (repository interfaces) rather than concrete implementations. This adheres to the dependency inversion principle, which is a core tenet of clean architecture.

By depending on abstractions (repository interfaces) rather than concrete implementations, the domain layer remains clean, focused, and unaffected by changes in data access strategies. This adherence to the Dependency Inversion Principle ensures that high-level business rules are decoupled from low-level data operations, resulting in a flexible, maintainable, and testable architecture.

## Data Source

-   Data sources are responsible for the actual data retrieval or storage. Typically, there are two main types: remote data sources (for fetching data from network or APIs) and local data sources (for accessing data from local databases or cache).

There are two types of Data Sources:-

1.  **Remote Data Source:** A remote data source deals with fetching data from external APIs or services over the network. It encapsulates the logic for making HTTP requests, handling responses, and transforming raw data into usable application models.
2.  **Local Data Source:** A local data source manages data stored locally on the device, typically in databases, shared preferences, or local files. It handles CRUD (Create, Read, Update, Delete) operations and provides an abstraction over the underlying storage mechanisms.

Data sources are interfaces that define contracts for accessing data from different sources, such as remote APIs, local databases, or device sensors. These interfaces serve as blueprints for implementing concrete data source classes that interact with specific data providers.

**Abstract Data Source**

-   An abstract data source is an interface that declares methods for performing data access operations. It typically represents a specific type of data source, such as a remote API client or a local database handler. Abstract data sources define the contract that concrete implementations must adhere to.

```dart
abstract class DataSource {
  // Declare abstract methods for data access operations
  Future<DataType> fetchData();
  Future<void> saveData(DataType data);
  Future<void> deleteData(DataType data);
}
```

In this abstract data source example, `DataSource` defines three abstract methods: `fetchData()`, `saveData()`, and `deleteData()`, which represent common CRUD operations (Create, Read, Update, Delete) for managing data. The `DataType` is a placeholder representing the type of data being accessed.

**Implementation of Data Source**

Concrete data source classes implement the methods defined in the abstract data source interface. These implementations provide actual logic for interacting with specific data providers, such as making HTTP requests to remote APIs or executing SQL queries against local databases.

```dart
class RemoteDataSource implements DataSource {
  @override
  Future<DataType> fetchData() async {
    // Implement logic to fetch data from remote API
  }

  @override
  Future<void> saveData(DataType data) async {
    // Implement logic to save data to remote API
  }

  @override
  Future<void> deleteData(DataType data) async {
    // Implement logic to delete data from remote API
  }
}
```

In this example, `RemoteDataSource` is a concrete implementation of the `DataSource` interface. It provides specific implementations for the `fetchData()`, `saveData()`, and `deleteData()` methods tailored to interact with a remote API.

Implementing concrete data sources in the context of Clean Architecture means creating classes that provide the actual mechanisms to retrieve and store data, as specified by the Abstract Classes defined in the Data Layer.

These concrete classes implement the methods defined by the interfaces, providing the details of how data is fetched from or stored to various sources (e.g., remote APIs, local databases).

## Models

**1\. Definition**

-   Models within the data layer represent the structure of the data being transferred between the various components of the application. They act as data containers that hold the information retrieved from data sources, transformed for processing, and passed between different layers of the application.
-   Models are often closely related to entities in the domain layer but may include additional properties or methods tailored to the data layer’s needs.

**2\. Purpose**

-   Models encapsulate the data retrieved from data sources, such as databases, APIs, or local storage.
-   They provide a structured representation of the data, allowing for easy manipulation and transformation within the data layer.
-   Models abstract away the details of data storage and retrieval, providing a clean interface for interacting with data sources.

**3\. Characteristics**

-   Models typically mirror the structure of the data being retrieved, with properties representing different attributes or fields.
-   They may include constructors for initializing model instances from raw data (e.g., JSON).
-   Models often implement methods for serializing and deserializing data to and from different formats, such as JSON or database records.

**4\. Responsibilities**

-   **Data Transformation**: They facilitate the conversion of raw data from data sources into structured objects that can be processed by the application.
-   **Data Validation**: Models may include validation logic to ensure the integrity and consistency of the data before processing.
-   **Data Serialization/Deserialization**: Models handle the conversion of data between its in-memory representation and external formats, such as JSON or database records.

**5\. Examples**

```dart
class UserModel {
  final int id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
```

-   In this example, `UserModel` represents a user entity with properties for `id`, `name`, and `email`.
-   It includes a constructor for creating `UserModel` instances from JSON data and a method for serializing `UserModel` instances to JSON.

**6\. Integration with Data Layer**

-   Models are used by data sources to represent the data retrieved from external sources.
-   They may be transformed into domain entities by data mappers before being passed to the domain layer.
-   Models provide a structured representation of data that can be easily manipulated and processed within the data layer, facilitating interactions with repositories and data sources.

By encapsulating data within structured models, Flutter Clean Architecture promotes separation of concerns and maintainability, allowing for easier management and manipulation of data within the application. Models play a crucial role in ensuring data integrity and consistency across different layers of the architecture.

## Domain Layer

In Flutter Clean Architecture, The Domain Layer represents the core of your application, containing business logic and rules independent of any external framework or technology. It encapsulates entities, use cases (interactors), and repositories

## Subparts of the Domain Layer and Their Functions

## Entities

Entities represent the core business objects or concepts in your application. They encapsulate the essential data and behavior that define the business domain. Entities are independent of any specific framework, database, or UI technology, making them highly reusable and decoupled from external dependencies.

![](https://miro.medium.com/v2/resize:fit:700/1*tSMbfoE5pnHIKo1sfD7iCQ.png)

Layers and connection using Entities

1.  **Characteristics**

-   **Plain Dart Classes**: Entities are typically defined as plain Dart classes without any dependencies on external libraries or frameworks.
-   **Data and Behavior**: Entities encapsulate both data (attributes or properties) and behavior (methods or functions) relevant to the domain they represent.
-   **Immutable or Mutable**: Entities can be immutable or mutable, depending on the requirements of your application. Immutability ensures that entities remain unchanged once created, promoting predictability and thread safety.
-   **Identity**: Entities often have a unique identity that distinguishes them from other entities. This identity might be represented by a unique identifier (e.g., ID or UUID) or a combination of attributes.

```dart
class Task {
  final String id;
  final String title;
  final bool completed;

  Task({required this.id, required this.title, this.completed = false});
}
```

-   `Task` is a plain Dart class representing a task in the task management application.
-   It has attributes such as `id`, `title`, and `completed`, encapsulating the data associated with a task.
-   The constructor initializes the attributes of the task.

**2\. Advantages**

-   **Isolation of Business Logic**: Entities encapsulate the business logic and rules associated with the domain objects. This ensures that the core business logic remains centralized within the domain layer, promoting maintainability and reusability
-   **Interaction with Use Cases**: Use cases (interactors) within the domain layer operate on entities to perform business operations. Use cases orchestrate the interactions between entities to achieve specific user goals or features.
-   **Testability**: Entities are independent of external dependencies, making them easier to test in isolation using unit tests.
-   **Flexibility and Evolvability**: Entities provide a flexible and evolvable foundation for the application, allowing changes to the business rules without impacting other layers.

Clean Architecture promotes the separation of concerns and the dependency rule, which states that inner layers should not depend on outer layers.

Entities in Clean Architecture adhere to these principles by encapsulating business logic and remaining isolated from external dependencies. This ensures that the core business logic remains independent, reusable, and testable, contributing to a clean and maintainable architecture

## Use Cases

**1\. Definition** : Use cases represent the specific tasks or actions that the application can perform. Each use case encapsulates a single piece of functionality that the user or system can trigger. Use cases are typically driven by user goals or system requirements.

**2\. Business Logic Encapsulation:** Use cases encapsulate the business logic of the application. They define how data is processed, transformed, and manipulated to fulfill a specific task or requirement. By encapsulating business logic, use cases promote modularity, reusability, and testability.

**3\. Single Responsibility Principle (SRP):** Each use case focuses on a single task or responsibility. This adherence to the SRP ensures that use cases remain focused, maintainable, and easy to understand. It also enables better code organization and reduces the risk of coupling between different parts of the system.

**Implementing Use Cases in Flutter Clean Architecture**

1.  **Use Case Classes**: In Flutter Clean Architecture, each use case is typically represented by a class within the domain layer. These classes define the inputs, outputs, and behavior associated with a specific task or action.
2.  **Input and Output Data Models**: Use cases define input and output data models that represent the data required for executing the task and the result produced by the task, respectively. These data models are often simple Dart classes or data transfer objects (DTOs) that encapsulate the relevant data fields.
3.  **Dependency Inversion Principle (DIP)**: Use cases depend on abstractions rather than concrete implementations of external dependencies. This adherence to the DIP allows use cases to remain decoupled from specific implementation details, such as data sources or external services. Dependencies are typically injected into use cases via constructor parameters or method arguments.
4.  **Interactors or Interactor Classes**: In some implementations, use cases are also referred to as interactors or interactor classes. These terms are often used interchangeably to describe the classes responsible for executing specific tasks within the domain layer.

```dart
// Here is usecase abstract class
abstract interface class Usecase<SucessType, Params> {
  Future<Either<Failure, SucessType>> call(Params params);
}

class NoParams {}
```

```dart
// Usecase class of UserLogin implement's Usecase in which it define the
//function inside the usecases which need to be defined or assigned

class UserLogin implements Usecase<User, UserLoginParams> {
  final AuthRepository authRepository;

  UserLogin({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(UserLoginParams params) async {
    return await authRepository.loginWithEmailPassword(
        email: params.email, password: params.password);
  }
}
// where loginWihtEmailPassword is stored inside repository of domain layer

class UserLoginParams {
  final String email;
  final String password;

  UserLoginParams({
    required this.email,
    required this.password,
  });
}
```

```dart
// Another usecase file getting currentUser;

class CurrentUser implements Usecase<User, NoParams> {
  final AuthRepository authRepository;

  CurrentUser(this.authRepository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await authRepository.currentUser();
  }
}
```

```dart
// Domain Layer Repository

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> currentUser();
}
```

Use Cases play a crucial role in maintaining a separation of concerns and enforcing architectural boundaries. They encapsulate the core business logic of the application, ensuring that it remains decoupled from external concerns such as UI or data storage mechanisms.

By adhering to the principles of Clean Architecture, Use Cases promote code maintainability, scalability, and testability, ultimately leading to a robust and flexible software design.

## Repositories

In Clean Architecture, the Repository pattern is a key component of the Domain Layer. It serves as an interface between the domain layer and the data layer (such as databases, web services, or local storage). The main purpose of the repository is to abstract the details of data access and provide a clean and consistent API for the domain layer to interact with the data.

**Characteristics**

1.  **Abstraction of Data Access**: Repositories abstract away the specific details of how data is stored or retrieved. They define a set of methods for performing CRUD (Create, Read, Update, Delete) operations on entities without exposing the underlying data sources.
2.  **Single Source of Truth**: Repositories provide a centralized location for managing data access logic. They ensure that the domain layer interacts with data in a consistent manner, regardless of the actual data source.
3.  **Encapsulation of Business Logic**: Repositories encapsulate the logic for accessing and manipulating data within the domain layer. They enforce business rules and constraints related to data access, ensuring data integrity and consistency.
4.  **Promotion of Testability**: By abstracting data access logic behind a repository interface, it becomes easier to write unit tests for the domain layer. Mock implementations can be used during testing to isolate the domain logic from external dependencies.

**Implementation**

In a Flutter application following Clean Architecture principles, the repository interfaces are defined within the domain layer. These interfaces specify the contract for data operations that the domain layer requires. The actual implementations of these repositories are provided by the data layer.

```dart
// Auth repository defined inside domain layer
abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> currentUser();
}
```

```dart
// Inside data Repositories that implements the domain Repositories
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  AuthRepositoryImpl(this.remoteDataSource, this.connectionChecker);
  @override
  Future<Either<Failure, User>> currentUser() async {
    ...
  }

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
   ...
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    ...
  }

  Future<Either<Failure, User>> _getUser(Future<User> Function() fn) async {
    ...
  }
}
```

In Clean Architecture, repositories play a crucial role in separating domain logic from data access concerns. They provide a clean and consistent interface for interacting with data, promoting modularity, testability, and maintainability in software applications. By abstracting away the specifics of data sources, repositories enable flexibility, extensibility, and scalability in the architecture.

## Presentation Layer

The presentation layer is responsible for handling the user interface and user interactions. In the context of Flutter, the presentation layer typically consists of widgets, screens, and UI components.

## Subparts of the Presentation Layer and Their Functions

## Widget

Widgets represent the building blocks of your UI in Flutter. You can organize them into reusable components such as buttons, text inputs, cards, etc. Widgets should be focused on displaying information and handling user interactions but should not contain any business logic.

## Pages

Pages are higher-level components that represent a full UI screen or page in your app. Each screen can contain multiple widgets and is responsible for arranging them to create the desired layout. Pages should delegate business logic to the corresponding use cases in the domain layer and should not contain any business logic themselves.

## Data Binding

-   **Data Binding Mechanisms**: Data binding mechanisms allow for synchronizing the UI with underlying data changes. In Flutter, this can be achieved using frameworks like Provider, Riverpod, or even the built-in setState method for state management.
-   **Two-Way Data Binding:** Depending on the framework or approach used, you may implement two-way data binding to automatically propagate UI changes back to the underlying data model.

## Dependency Injection (DI)

-   **DI in Presentation Layer**: Dependency Injection is used to provide dependencies such as use cases, repositories, or services to the presentation layer components. This promotes decoupling and makes the components easier to test.
-   **Injecting Dependencies**: Dependencies are typically injected into ViewModels, Presenters, or other UI components using DI containers or service locators.

## ViewModels or Presenters

-   **ViewModels**: In Flutter, ViewModel is a common pattern used to separate the UI logic from the UI components themselves. ViewModels contain the presentation logic and state management code. They are responsible for preparing data to be displayed by the UI and handling user interactions.
-   **Presenters**: Alternatively, you may use the Presenter pattern, which follows a similar concept but with a different name. Presenters also handle UI logic and are responsible for updating the UI based on changes in the underlying data/state

## Visual Representation of Clean Architecture

![](https://miro.medium.com/v2/resize:fit:700/1*C2Euk2Dc9H3Pyf7I9WY3cw.png)

Clean Architecture Logic and Separation of Each Modules

## Conclusion

Clean Architecture is a powerful approach to structuring your codebase, offering clear separation of concerns, enhanced maintainability, and scalability. By adhering to its principles, you ensure that your application remains adaptable to changes and easy to understand and test.

## Credits

All of the images credits are goes to their respective owners if there any please contact me i’ll mention.

source: https://medium.com/@DrunknCode/clean-architecture-simplified-and-in-depth-guide-026333c54454
