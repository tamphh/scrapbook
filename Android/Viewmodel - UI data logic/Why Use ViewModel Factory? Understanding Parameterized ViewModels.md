# Why Use ViewModel Factory? Understanding Parameterized ViewModels
The ViewModel architecture component simplifies UI data management in Android applications, allowing data persistence across configuration changes. But what when your ViewModel requires custom parameters for initialization? Here’s where ViewModel Factories come into play.

## Why Use ViewModel Factories?

-   **Custom Initialization:** ViewModels often require specific data during their creation. ViewModel Factories allow you to inject these dependencies (e.g., an item ID, network service instance) into the ViewModel’s constructor, enhancing flexibility and data management.
-   **Dependency Injection (DI):** When your ViewModel relies on other components (repositories, network services), a Factory facilitates cleaner DI practices. You can inject these dependencies into the ViewModel, promoting separation of concerns and testability.
-   **Handling Configuration Changes:** ViewModels survive configuration changes like screen rotations, but their data needs to remain consistent. A Factory helps recreate the ViewModel with the same parameters after a configuration change, ensuring seamless user experience.

## Creating a ViewModel Factory

To create a ViewModel Factory, follow these steps:

### 1.  **Define Your ViewModel:** Create a ViewModel class (e.g., `MyViewModel`) with the necessary constructor parameters:

```kotlin
class MyViewModel(val itemId: Long, private val repository: MyRepository) : ViewModel() {
    // ...
}
```

### **2\. Implement the Factory:** Create a class (e.g., `MyViewModelFactory`) that extends `ViewModelProvider.Factory`:

```kotlin
class MyViewModelFactory(private val itemId: Long, private val repository: MyRepository) : ViewModelProvider.Factory {
    override fun <T> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(MyViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return MyViewModel(itemId, repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
```

-   The `create` method takes the `modelClass` parameter and returns an instance of that class.
-   We check if the requested class is assignable to `MyViewModel`.
-   If so, we create a new `MyViewModel` instance using the provided `itemId` and `repository`.
-   Otherwise, throw an `IllegalArgumentException`.

### 3\. **Use the Factory:** When creating your ViewModel instance, use the Factory to pass any necessary data:

```kotlin
val myViewModel = ViewModelProvider(this, MyViewModelFactory(itemId, repository)).get(MyViewModel::class.java)
```

-   Pass the `Activity` or `Fragment` instance and your factory (`MyViewModelFactory`) to `ViewModelProvider`.
-   Call `get` with the ViewModel class (`MyViewModel::class.java`) to retrieve the properly initialized instance.

## **Creating a ViewModel Factory with an Example**

Let’s consider a simple counter app demonstrating how to use a ViewModel Factory. We want to initialize the counter with a specific starting value retrieved from a preference or passed as an argument.

### 1.  **Define the ViewModel:** Create a `MainViewModel` class with a constructor parameter for the initial value.

```kotlin
package com.dilip.viewmodelfactoryexample

import androidx.lifecycle.ViewModel

class MainViewModel(val initialValue: Int) : ViewModel() {

    var count: Int = initialValue  // using MainViewModelFactory

    fun increment() {
        count++
    }
}
```

### 2\. **Implement the Factory:** Create a `MainViewModelFactory` class that extends `ViewModelProvider.Factory`:

```kotlin
package com.dilip.viewmodelfactoryexample

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider

class MainViewModelFactory(val counter: Int) : ViewModelProvider.Factory {

    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        return MainViewModel(counter) as T

    }
}
```

-   The `create` method takes the `modelClass` parameter and returns an instance of that class.
-   We check if the requested class is assignable to `MainViewModel`.
-   If so, we create a new `MainViewModel` instance using the provided `counter` value.
-   Otherwise, throw an `IllegalArgumentException`.

### **3\. Use the Factory in the Activity:**

```kotlin
package com.dilip.viewmodelfactoryexample

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider

class MainActivity : AppCompatActivity() {

    private lateinit var textCounter: TextView
    private lateinit var mainViewModel: MainViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Initialize the ViewModel with initial value 5 using MainViewModelFactory
        mainViewModel = ViewModelProvider(this, MainViewModelFactory(5)).get(MainViewModel::class.java)

        textCounter = findViewById(R.id.textCounter)  // Find the TextView in the layout

        setText() // Set the initial text value based on ViewModel data
    }

    // Called when the "Increment" button is clicked
    fun increment(view: View) {
        mainViewModel.increment() // Increment the count in the ViewModel

        setText() // Update the TextView to reflect the new count
    }

    // Update the TextView with the current count from the ViewModel
    private fun setText() {
        textCounter.text = mainViewModel.count.toString()
    }
}
```

-   Pass the `Activity` instance and your factory (`MainViewModelFactory`) to `ViewModelProvider`.
-   Call `get` with the ViewModel class (`MainViewModel::class.java`) to retrieve the properly initialized instance.

### **4\.** activity\_main **layout:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:id="@+id/main"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

    <TextView
        android:id="@+id/textCounter"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="0"
        android:textSize="30sp"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintVertical_bias="0.441" />

    <Button
        android:id="@+id/button"
        android:onClick="increment"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="+"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintHorizontal_bias="0.498"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@+id/textCounter"
        app:layout_constraintVertical_bias="0.085"
        tools:ignore="OnClick" />

</androidx.constraintlayout.widget.ConstraintLayout>
```

## **Benefits of Using ViewModel Factories**

-   **Improved Maintainability:** By separating ViewModel creation logic from your activity or fragment code, you enhance code organization and testability.
-   **Flexible Data Management:** You gain more control over ViewModel initialization with custom parameters, making data management more adaptable to different scenarios.
-   **Enhanced Dependency Injection:** ViewModel Factories facilitate a clean approach to inject dependencies into your ViewModel, promoting separation of concerns and testability.

## **In Conclusion**

ViewModel Factories helps you to create ViewModels with custom parameters, making it a more flexible and maintainable ViewModel architecture in your Android applications. By using ViewModel Factories effectively, you can simplify data management, improve separation of concerns, and enhance overall code quality.

source: https://medium.com/@dilip2882/why-use-viewmodel-factory-understanding-parameterized-viewmodels-2dbfcf92a11d
