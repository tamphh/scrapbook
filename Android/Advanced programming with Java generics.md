# Advanced programming with Java generics

Take your coding to the next level by learning advanced programming with generics. Here's how to use generic methods with type inference, type parameters, and wildcards in your Java programs.

Generics in Java enhance the type safety of your code and make it easier to read. In my last article, I [introduced the general concepts of generics and showed examples from the Java Collections Framework](https://www.infoworld.com/article/3490016/how-to-use-generics-in-your-java-programs.html). You also learned how to use generics to avoid runtime errors like the `ClassCastException`.

This article goes into more advanced concepts. I introduce sophisticated type constraints and operations that enhance type safety and flexibility, along with key concepts such as bounded type parameters, which restrict the types used with generics and wildcards and allow method parameters to accept varying types. You’ll also see examples of how to use type erasure for backward compatibility and enable generic methods for type inference.

## Generic type inference

_Type inference_, introduced in Java 7, allows the Java compiler to automatically determine or infer the types of parameters and return types based on method arguments and the target type. This feature simplifies your code by reducing the verbosity of generics usage.

When you use generics, you often specify the type inside angle brackets. For example, when creating a list of strings, you would specify the type as follows:

```javascript
List<String> myList = new ArrayList<String>();

```

```javascript
List<String> myList = new ArrayList<>();

```

Type inference helps make your code cleaner and easier to read. It also reduces the chance of errors from specifying generic types, which makes working with generics easier. Type inference is particularly useful in complex operations involving generics nested within generics.

Type inference became increasingly useful in Java 8 and later, where it extended to [lambda expressions](https://www.infoworld.com/article/2264197/get-started-with-lambda-expressions.html) and method arguments. This allows for even more concise and readable code without losing the safety and benefits of generics.

## Bounded and unbounded type parameters

In Java, you can use _bounds_ to limit the types that a type parameter can accept. While _bounded type parameters_ restrict the types that can be used with a generic class or method to those that fulfill certain conditions, _unbounded type parameters_ offer broader flexibility by allowing any type to be used. Both are beneficial.

### Unbounded type parameters

An _unbounded type parameter_ has no explicit constraints placed on the type of object it can accept. It is simply declared with a type parameter, usually represented by single uppercase letters like E, T, K, or V. An unbounded type parameter can represent any _non-primitive_ type (since Java generics do not support primitive types directly).

Consider the generic `Set<E>` interface from the Java Collections Framework:

```javascript
Set<String> stringSet = new HashSet<>();
Set<Employee> employeeSet = new HashSet<>();
Set<Customer> customerSet = new HashSet<>();

```

### Characteristics and implications of unbounded type parameters

1.  **Maximum flexibility**: Unbounded generics are completely type-agnostic, meaning they can hold any type of object. They are ideal for collections or utilities that do not require specific operations dependent on the type, such as adding, removing, and accessing elements in a list or set.

-   **Type safety**: Although an unbounded generic can hold any type, it still provides type safety compared to raw types like a plain `List` or `Set` without generics. For example, once you declare a `Set<String>`, you can only add strings to this set, which prevents runtime type errors.

-   **Errors**: Because the type of the elements is not guaranteed, operations that depend on specific methods of the elements are not possible without casting, which can lead to errors if not handled carefully.

### Bounded type parameters

A _bounded type parameter_ is a generic type parameter that specifies a boundary for the types it can accept. This is done using the extends keyword for classes and interfaces. This keyword effectively says that the type parameter must be a subtype of a specified class or interface.

The following example demonstrates an effective use of a bounded type parameter:

```typescript
public class NumericOperations {
    
    public static <T extends Number> double square(T number) {
        return number.doubleValue() * number.doubleValue();
    }

    public static void main(String[] args) {
        System.out.println("Square of 5: " + square(5));
        System.out.println("Square of 7.5: " + square(7.5));
    }
}

```

-   **Class definition**: `NumericOperations` is a simple Java class containing a static method square.
-   **Generic method**: `square` is a static method defined with a generic type T that is bounded by the `Number` class. This means T can be any class that extends `Number` (like `Integer`, `Double`, `Float`, and so on).
-   **Method operation**: The method calculates the square of the given number by converting it to a double (using `doubleValue()`) and then multiplying it by itself.
-   **Usage in main method**: The `square` method is called with different types of numeric values (`int` and `double`) that are autoboxed to `Integer` and `Double`, demonstrating its flexibility.

### When to use bounded type parameters

Bounded-type parameters are particularly useful in several scenarios:

-   **Enhancing type safety**: By restricting the types that can be used as arguments, you ensure the methods or classes only operate on types guaranteed to support the necessary operations or methods, thus preventing runtime errors.
-   **Writing reusable code**: Bounded type parameters allow you to write more generalized yet safe code that can operate on a family of types. You can write a single method or class that works on any type that meets the bound condition.
-   **Implementing algorithms**: For algorithms that only make sense for certain types (like numerical operations and comparison operations), bounded generics ensure the algorithm is not misused with incompatible types.

## A generic method with multiple bounds

You’ve learned about bounded and unbounded type parameters, so now let’s look at an example. The following generic method requires its parameter to be both a certain type of animal and capable of performing specific actions.

In the example below, we want to ensure that any type passed to our generic method is a subclass of `Animal` and implements the `Walker` interface.

```typescript
class Animal {
    void eat() {
        System.out.println("Eating...");
    }
}

interface Walker {
    void walk();
}

class Dog extends Animal implements Walker {
    @Override
    public void walk() {
        System.out.println("Dog walking...");
    }
}

class Environment {
    public static <T extends Animal & Walker> void simulate(T creature) {
        creature.eat();
        creature.walk();
    }
    
    public static void main(String[] args) {
        Dog myDog = new Dog();
        simulate(myDog);
    }
}

```

-   **Animal class**: This is the _class bound_: The type parameter must be a subclass of `Animal`.
-   **Walker interface**: This is the _interface bound_: The type parameter must also implement the `Walker` interface.
-   **Dog class**: This class qualifies as it extends `Animal` and implements `Walker`.
-   **Simulate method**: This generic method in the `Environment` class accepts a generic parameter, T, that extends `Animal` and implements `Walker`.

Using multiple bounds (T extends `Animal` and `Walker`) ensures the simulated method can work with any animal that walks. In this example, we see how bounded generic types leverage polymorphism and ensure type safety.

## Wildcards in generics

In Java, a wildcard generic type is represented with the question mark (`?`) symbol and used to denote an unknown type. Wildcards are particularly useful when writing methods that operate on objects of generic classes. Still, you don’t need to specify or care about the exact object type.

### When to use wildcards in Java

Wildcards are used when the exact type of the collection elements is unknown or when the method needs to be generalized to handle multiple object types. Wildcards add flexibility to method parameters, allowing a method to operate on collections of various types.

Wildcards are particularly useful for creating methods that are more adaptable and reusable across different types of collections. A wildcard allows a method to accept collections of any type, reducing the need for multiple method implementations or excessive method overloading based on different collection types.

As an example, consider a simple method, `displayList`, designed to print elements from any type of `List`:

```typescript
import java.util.List;

public class Demo {
    public static void main(String[] args) {
        List<String> colors = List.of("Red", "Blue", "Green", "Yellow");
        List<Integer> numbers = List.of(10, 20, 30);

        displayList(colors);
        displayList(numbers);
    }

     static void displayList(List<?> list) {
        for (Object item : list) {
            System.out.print(item + " "); 
        }
        System.out.println(); 
    }
}

```

```undefined
Red Blue Green Yellow 
10 20 30 

```

-   **List creation**: Lists are created using `List.of()`, which provides a concise and immutable way to initialize the list with predefined elements.
-   **displayList method**: This method accepts a list with elements of any type (`List<?>`). Using a wildcard (`?`) allows the method to handle lists containing objects of any type.

This output confirms that the `displayList` method effectively prints elements from both string and integer lists, showcasing the versatility of wildcards.

### Lower-bound wildcards

To declare a lower-bound wildcard, you use the `? _super T_` syntax, where `T` is the type that serves as the lower bound. This means that the generic type can accept `T` or any of its superclasses (including `Object`, the superclass of all classes).

Let’s consider a method that processes a list by adding elements. The method should accept lists of a given type or any of its superclasses. Here’s how you might define such a method:

```typescript
public void addElements(List<? super Integer> list) {
    list.add(10);  
}

```

### Benefits of lower-bound wildcards

Flexibility and compatibility are the main benefits of using lower-bound wildcards:

-   **Flexibility**: A lower-bound wildcard allows methods to work with arguments of different types while still enforcing type safety. This is particularly useful for operations that put elements into a collection.
-   **Compatibility**: Functions that use lower-bound wildcards can operate on a broader range of data types, enhancing API flexibility.

Lower-bound wildcards are particularly useful in scenarios where data is being added to a collection rather than read from it. For example, consider a function designed to add a fixed set of elements to any kind of numeric list:

```typescript
public void addToNumericList(List<? super Number> list) {
    list.add(Integer.valueOf(5));
    list.add(Double.valueOf(5.5));
}

```

So, why not use `List<Object>` instead of a wildcard? The reason is flexibility: If we have the `displayList` method configured to receive a `List<Object>`, we will _only_ be able to pass a `List<Object>`. For example, if we tried passing a `List<String>`, considering the `String` type is an `Object`, we would receive a compilation error:

```typescript
List<String> stringList = Arrays.asList("hello", "world");
displayList(stringList); 

public void displayList(List<Object> list) {
    System.out.println(list);
}

```

## Key differences between type parameters and wildcards

You’ve learned about both type parameters and wildcards, two advanced elements in Java generics. Understanding how these elements are different will help you know when to use each of them:

-   **Flexibility vs. specificity**: Wildcards offer more flexibility for methods that operate on various objects without specifying a particular type. Type parameters demand specific types and enforce consistency within the use of the class or method where they are defined.
-   **Read vs. write**: Typically, you use `? extends Type` when you only need to read from a structure because the items will all be instances of `Type` or its subtypes. `? super Type` is used when you need to write to a structure, ensuring that the structure can hold items of type `Type` or any type that is a superclass of `Type`. Type parameters `T` are used when both operations are required or when operations depend on each other.
-   **Scope**: Wildcards are generally used for broader operations in a limited scope (like a single method), while type parameters define a type that can be used throughout a class or a method, providing more extensive code reuse.

## Key differences between upper and lower bounds

Now that we know more about type parameters and wildcards, let’s explore the differences between upper bounds and lower bounds.

`List<? super Animal>` is an example of a lower-bound list. It is a _lower-bound_ because `Animal` is the lowest or _least specific_ class you can use. You can use `Animal` or any type that is a superclass of `Animal` (such as `Object`) to effectively go upward in the class hierarchy to more general types.

-   Conceptually, lower bounds set a floor, or a minimum level of generality. You can’t go any lower in generality than this limit.

-   The purpose of the lower bound in this example is to allow the list to accept assignments of `Animal` and any of its subtypes. A lower bound is used when you want to add objects into a list.

-   A lower-bound list is often used when you are writing to the list because you can safely add an `Animal` or any subtype of `Animal` (e.g., Dog or Cat) to the list, knowing that whatever the actual list type is, it can hold items of type `Animal` or more generic types (like `Object`).

-   When you retrieve an item from such a list, all you know is that it is at least an `Object` (the most general type in Java), because the specific type parameter could be any superclass of `Animal`. As such, you must explicitly cast it if you need to treat it as an `Animal` or any other specific type.

Now let’s look at an upper-bound list: `List<? extends Animal>`. In this case, `Animal` is the highest or most specific class in the hierarchy that you can use. You can use `Animal` itself or any class that is a subtype of `Animal` (like `Dog` or `Cat`), but you cannot use anything more general than `Animal`.

-   Think of upper bounds as setting a ceiling on how specific the types in your collection can be. You can’t go higher than this limit.

-   The purpose of the upper-bound limit is to allow the list to accept assignments of `Animal` or any superclass of `Animal`, but you can only retrieve items from it as `Animal` or its subtypes.

-   This type of list is primarily used when you are reading from the list and not modifying it. You can safely read from it knowing that everything you retrieve can be treated as an `Animal` or more specific types (`Dog` or `Cat`); still, you cannot know the exact subtype.

-   You cannot add items to an upper-bound list (except for null, which matches any reference type) because you do not know what specific subtype of `Animal` the list is meant to hold. Adding an `Animal` could violate the list’s type integrity if, for example, the list was `List<Cat>`.

### Writing bounded lists

When writing lower- and upper-bound lists, remember this:

-   `List<? super Animal>` (lower bound) can add `Animal` and its subtypes.

-   `List<? extends Animal>` (upper bound) cannot add `Animal` or any subtype (except null).

### Reading bounded lists

When reading lower- and upper-bound lists, remember this:

-   `List<? super Animal>`: Items retrieved from a lower-bound list are of an indeterminate type up to `Object`. Casting is required for this item to be used as `Animal`.

-   `List<? extends Animal>`: Items retrieved are known to be at least `Animal`, so no casting is needed to treat them as `Animal`.

### An example of upper- and lower-bound lists

Imagine you have a method to add an `Animal` to a list and another method to process animals from a list:

```javascript
void addAnimal(List<? super Animal> animals, Animal animal) {
    animals.add(animal); 
}

Animal getAnimal(List<? extends Animal> animals, int index) {
    return animals.get(index); 
}

```

-   `addAnimal` can accept a `List<Animal>`, `List<Object>`, etc., because they can all hold an `Animal`.
-   `getAnimal` can work with `List<Animal>`, `List<Dog>`, etc., safely returning `Animal` or any subtype without risking a `ClassCastException`.

This shows how Java generics use the `extends` and `super` keywords to control what operations are safe regarding reading and writing, aligning with the intended operations of your code.

## Conclusion

Knowing how to apply advanced concepts of generics will help you create robust components and Java APIs. Let’s recap the most important points of this article.

### Bounded type parameters

You learned that bounded type parameters limit the allowable types in generics to specific subclasses or interfaces, enhancing type safety and functionality.

### Wildcards

Use wildcards (`? extends` and `? super`) to allow generic methods to handle parameters of varying types, adding flexibility while managing covariance and contravariance. In generics, wildcards enable methods to work with collections of unknown types. This feature is crucial for handling variance in method parameters.

### Type erasure

This advanced feature enables backward compatibility by removing generic type information at runtime, which leads to generic details not being maintained post-compilation.

### Generic methods and type inference

Type inference reduces verbosity in your code, allowing the compiler to deduce types from context and simplify code, especially from Java 7 onwards.

### Multiple bounds in Java generics

Use multiple bounds to enforce multiple type conditions (e.g., `<T extends Animal & Walker>`). Ensuring parameters meet all the specified requirements promotes functional and type safety.

### Lower bounds

These support write operations by allowing additions of (in our example) `Animal` and its subtypes. Retrieves items recognized as `Object`, requiring casting for specific uses due to the general nature of lower bounds.

### Upper bounds

These facilitate read operations, ensuring all retrieved items are at least (in our example) `Animal`, eliminating the need for casting. Restricts additions (except for null) to maintain type integrity, highlighting the restrictive nature of upper bounds.

source: https://www.infoworld.com/article/3595651/advanced-programming-with-java-generics.html
