# How to use generics in your Java programs

### Generics make your code more flexible and easier to read, and they help you avoid ClassCastExceptions at runtime. Get started with this introduction to using generics with the Java Collections Framework.

Introduced in Java 5, generics enhance the type safety of your code and make it easier to read. This helps you avoid runtime errors like the `ClassCastException`, which happens when you try to cast objects to incompatible types.

In this tutorial, you’ll learn about generics and see three examples of using them with the Java Collections Framework. I’ll also introduce raw types and discuss the instances when you might choose to use raw types rather than generics, along with the risks of doing so.

## Generics in Java programming

-   Why use generics?
-   How to use generics for type safety
-   Generics in the Java Collections Framework
-   Examples of generic types in Java
-   Raw types vs. generics

## Why use generics?

Generics are commonly used in the Java Collections Framework with `java.util.List`, `java.util.Set`, and `java.util.Map`. They also appear in other parts of Java, like `java.lang.Class`, `java.lang.Comparable`, and `java.lang.ThreadLocal`.

Before generics, Java code often lacked type safety. Here’s an example of Java code before generics:

```csharp
List integerList = new ArrayList();
  
integerList.add(1);
integerList.add(2);
integerList.add(3);

for (Object element : integerList) {
      Integer num = (Integer) element; 
      System.out.println(num);
 }

```

```csharp
integerList.add("Hello");

```

## Using generics for type safety

To solve the problem above and avoid `ClassCastException`s, we can use generics to specify the _type of objects_ a list may contain. We don’t need to make a class cast in that case, which makes the code safer and easier to understand:

```csharp
List<Integer> integerList = new ArrayList<>();

integerList.add(1);
integerList.add(2);
integerList.add(3);

for (Integer num : integerList) {
     System.out.println(num);
}

```

## Generics in the Java Collections Framework

Generics are integrated into Java Collections to provide compile-time type checking and to eliminate the need for explicit type casting. When you use a collection with generics, you specify the type of elements that the collection can hold. The Java compiler uses this specification to ensure that you do not accidentally insert an incompatible object into the collection, thus reducing bugs and improving code readability.

To illustrate how generics are used in the Java Collections Framework, let’s look at some examples.

### List and ArrayList with generics

In the above example, we already briefly explored a simpler way to use the `ArrayList`. Now, let’s explore this concept a bit further by seeing how the `List` interface is declared:

```csharp
public interface List<E> extends SequencedCollection<E> { … }

```

Now let’s see how to replace the variable `E` with the type we want for our `List`. In the following code, we replace the `<E>` variable with `<String>`:

```csharp
List<String> list = new ArrayList<>();
list.add("Java");
list.add("Challengers");


```

### Set and HashSet with generics

The `Set` interface is similar to the `List`:

```csharp
public interface Set<E> extends Collection<E> { … }

```

```csharp
Set<Double> doubles = new HashSet<>();
doubles.add(1.5);
doubles.add(2.5);


double sum = 0.0;
for (double d : doubles) {
    sum += d;
}

```

### Map and HashMap with generics

We can declare as many generic types as we want. In the example of a `Map`, which is a key value data structure, we have `K` for key and `V` for value:

```csharp
public interface Map<K, V> { … }

```

```go
Map<String, Integer> map = new HashMap<>();
map.put("Duke", 30);
map.put("Juggy", 25);


```

## Examples of using generic types in Java

Now let’s look at some examples that will demonstrate further how to declare and use generic types in Java.

### Using generics with objects of any type

We can declare a generic type in any class we create. It doesn’t need to be a collection type. In the following code example, we declare the generic type `E` to manipulate any element within the `Box` class. Notice in the code below that we declare the generic type _after the class name_. Only then we can use the generic type `E` as an attribute, constructor, method parameter, and method return type:

```csharp
public class Box<E> {
    
    private E content;

    public Box(E content)  {  this.content = content; }
    public E getContent() { return content;  }
    public void setContent(E content) { this.content = content;  }

    public static void main(String[] args) {
        
        Box<Integer> integerBox = new Box<>(123);
        System.out.println("Integer Box contains: " + integerBox.getContent());

        
        Box<String> stringBox = new Box<>("Hello World");
        stringBox.setContent("Java Challengers");
        System.out.println("String Box contains: " + stringBox.getContent());
    }
}

```

```rust
Integer Box contains: 123
String Box contains: Java Challengers

```

-   The class `Box` uses the type parameter `E` as a placeholder for the object the box will hold. This allows `Box` to be used with any object type.
-   The constructor initializes a new instance of the `Box` class with the provided content. Type `E` ensures that the constructor can accept any object type defined when the instance is created, maintaining type safety.
-   `getContent` returns the box’s current content. Returning type `E` ensures that it conforms to the generic type specified when the instance was created, providing the correct type without the need for casting.
-   `setContent` updates the content of the box with the new content. Using type `E` as the parameter ensures that only an object of the correct type can be set as the new content, ensuring type safety throughout the use of the instance.
-   In the main method, two `Box` objects are created: `integerBox` holds an `Integer`, and `stringBox` holds a `String`.
-   Each `Box` instance operates on its specific data type, demonstrating the power of generics for type safety.

This example showcases the basic implementation and usage of generics in Java, highlighting how to create and manipulate objects of any type in a type-safe manner.

### Using generics with different data types

We can declare as many types as we want as a generic type. In the following `Pair` class, we can add the generic values `<K, V>`. If we wanted to add even more generic types, we could add `<K, V, V1, V2, V3>`, and so on. The code would compile without issues.

Let’s see the `Pair` class with the pair values `<K, V>`:

```typescript
class Pair {
    private K key;
    private V value;

    public Pair(K key, V value) {
        this.key = key;
        this.value = value;
    }

    public K getKey() {
        return key;
    }

    public V getValue() {
        return value;
    }

    public void setKey(K key) {
        this.key = key;
    }
    public void setValue(V value) {
        this.value = value;
    }
}

public class GenericsDemo {
    public static void main(String[] args) {
        Pair<String, Integer> person = new Pair<>("Duke", 30);

        System.out.println("Name: " + person.getKey());
        System.out.println("Age: " + person.getValue());

        person.setValue(31);
        System.out.println("Updated Age: " + person.getValue());
    }
}

```

```yaml
Name: Duke
Age: 30
Updated Age: 31

```

-   The generic class `Pair<K, V>` has two type parameters: `K` (for key) and `V` (for value), making it versatile for any data type.
-   Constructors and methods in the `Pair` class use these type parameters, which allows for strong type-checking.
-   A `Pair` object is created to hold a `String` (a person’s name) and an `Integer` (their age).
-   Accessors (`getKey` and `getValue`) and mutators (`setKey` and `setValue`) manipulate and retrieve the data from the `Pair`.
-   The `Pair` class can store and manage related information without being tied to specific data types. This demonstrates the power and flexibility of generics.

This example shows how generics can create reusable and type-safe components with different data types, enhancing code reusability and maintainability.

Let’s look at one more example.

### Declaring a generic type within a method

It’s possible to declare a generic type directly within a method. It isn’t required to declare the generic type at a class level. So, if we needed a generic type only for a method, we could do that by declaring the generic type before the return type of the method signature:

```typescript
public class GenericMethodDemo {

    
    public static <T> void printArray(T[] array) {
        for (T element : array) {
            System.out.print(element + " ");
        }
        System.out.println();
    }

    public static void main(String[] args) {
        
        Integer[] intArray = {1, 2, 3, 4};
        printArray(intArray);

        
        String[] stringArray = {"Java", "Challengers"};
        printArray(stringArray);
    }
}

```

```undefined
1 2 3 4 
Java Challengers 

```

A _raw type_ is essentially the name of a generic class or interface but without any type arguments. Raw types were common before generics were introduced in Java 5. Today, developers typically use raw types for compatibility with legacy code or interoperability with non-generic APIs. Even with generics, it’s good to know how to recognize and use raw types in your code.

A common example of using a raw type is declaring a `List` without a type parameter:

```java
List rawList = new ArrayList();

```

### Compiler warning when using raw types

The Java compiler sends warnings about using raw types in Java. These warnings are generated to alert developers about potential risks related to type safety when using raw types instead of generics.

When you use generics, the compiler checks the types of objects stored in collections (like `List` and `Set`), method return types, and parameters to ensure they match the declared generic types. This prevents common bugs like the runtime `ClassCastException`.

When you use a raw type, the compiler cannot perform these checks because raw types don’t specify the type of objects they’re intended to contain. As a result, the compiler issues warnings to indicate that you are bypassing the type safety mechanisms provided by generics.

### Example of a compiler warning

Here’s a simple example to illustrate how the compiler issues a warning when using raw types:

```csharp
List list = new ArrayList();  
list.add("hello");
list.add(1);

```

```csharp
Note: SomeFile.java uses unchecked or unsafe operations.
Note: Recompile with -Xlint:unchecked for details.

```

```vbnet
warning: [unchecked] unchecked call to add(E) as a member of the raw type List
    list.add("hello");
         ^
  
where E is a type-variable:
    E extends Object declared in interface List

```

### Consequences of using raw types

While raw types are helpful for backward compatibility, they have at least two significant drawbacks: loss of type safety and increased maintenance costs.

-   Loss of type safety: One of the biggest advantages of generics is type safety. By using raw types, you lose this benefit. The compiler does not check type correctness, which could lead to a `ClassCastException` at runtime.
-   Increased cost of maintenance: Code that uses raw types is harder to maintain because it lacks the clear type information that generics provide. This can lead to errors that are hard to detect until runtime.

As an example of a type safety issue, if you use `List` (a raw type) instead of the generic `List<String>`, the compiler allows you to add any object type to the list, not just strings. This can lead to runtime errors when you retrieve an item from the list and attempt to cast it to a string, but the item is actually of another type.

## What you’ve learned about generics

Generics provides type safety with great flexibility. Let’s recap the key points you’ve learned.

### What are generics and why should I use them?

-   Generics were introduced in Java 5 to improve type safety and flexibility in code.
-   The key advantage of generics is that they help you avoid runtime errors such as `ClassCastException`.
-   Generics are commonly used in the Java Collections Framework, but they can also be used with code elements such as `Class`, `Comparable`, and `ThreadLocal`.
-   Generics enhance type safety by preventing the insertion of incompatible types.

### Generics in Java Collections

-   `List` and `ArrayList`: `List<E>` allows for specifying any type `E`, ensuring the list is type-specific.
-   `Set` and `HashSet`: `Set<E>` limits elements to type `E`, promoting consistency and type safety.
-   `Map` and `HashMap`: `Map<K, V>` defines types for both keys and values, increasing type safety and clarity.

### General benefits of using generics

-   Reduce bugs by preventing the insertion of incompatible types.
-   Improve readability and maintainability by clarifying the types involved.
-   Facilitate creating and managing collections and other data structures in a type-safe manner.

## Learn more about Java Collections

-   See Rafael’s [List removeIf Wrappers Java Challenge](https://javachallengers.com/list-removeif-wrappers-java-challenge) Java challenge to learn more about the `List` interface.
-   See the [Streams Set Distinct](https://javachallengers.com/streams-set-distinct-java-challenge) Java challenge to learn more about the `Set` interface.
-   The [Map equals hashcode challenge](https://javachallengers.com/map-equals-hashcode) introduces the `Map` interface.

source: https://www.infoworld.com/article/3490016/how-to-use-generics-in-your-java-programs.html
