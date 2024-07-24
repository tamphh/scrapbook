With the arrival of Dart 3, it brings many new features to the Dart language. Features like records, pattern matching, guard clauses, logical and relational operators in switch cases, if-case statements, pattern/object destructuring, multiple returns, and many more will be added. This article aims to familiarize the readers with these upcoming features in the Dart language.

## Table of Contents

-   [Table of Contents](https://biplabdutta.com.np/posts/pattern-matching-dart/#table-of-contents)
-   [Record](https://biplabdutta.com.np/posts/pattern-matching-dart/#record)
-   [Why/When would I want to use a record? 🤔](https://biplabdutta.com.np/posts/pattern-matching-dart/#whywhen-would-i-want-to-use-a-record-)
-   [Record Type Annotations](https://biplabdutta.com.np/posts/pattern-matching-dart/#record-type-annotations)
    -   [Record with positional fields](https://biplabdutta.com.np/posts/pattern-matching-dart/#record-with-positional-fields)
    -   [Record with named fields](https://biplabdutta.com.np/posts/pattern-matching-dart/#record-with-named-fields)
    -   [Record with named and positional fields](https://biplabdutta.com.np/posts/pattern-matching-dart/#record-with-named-and-positional-fields)
-   [Destructuring](https://biplabdutta.com.np/posts/pattern-matching-dart/#destructuring)
    -   [Destructuring positional fields](https://biplabdutta.com.np/posts/pattern-matching-dart/#destructuring-positional-fields)
    -   [Destructuring named fields](https://biplabdutta.com.np/posts/pattern-matching-dart/#destructuring-named-fields)
    -   [Destructuring positional and named fields](https://biplabdutta.com.np/posts/pattern-matching-dart/#destructuring-positional-and-named-fields)
    -   [JSON Destructuring](https://biplabdutta.com.np/posts/pattern-matching-dart/#json-destructuring)
    -   [Object Destructuring](https://biplabdutta.com.np/posts/pattern-matching-dart/#object-destructuring)
-   [Guard Clauses](https://biplabdutta.com.np/posts/pattern-matching-dart/#guard-clauses)
-   [Sealed class and pattern matching](https://biplabdutta.com.np/posts/pattern-matching-dart/#sealed-class-and-pattern-matching)
-   [Logical & Relational operators in switch case](https://biplabdutta.com.np/posts/pattern-matching-dart/#logical--relational-operators-in-switch-case)
-   [If-case Statements](https://biplabdutta.com.np/posts/pattern-matching-dart/#if-case-statements)
-   [Control Flow in Argument Lists](https://biplabdutta.com.np/posts/pattern-matching-dart/#control-flow-in-argument-lists)
-   [Conclusion](https://biplabdutta.com.np/posts/pattern-matching-dart/#conclusion)
-   [Credit](https://biplabdutta.com.np/posts/pattern-matching-dart/#credit)

> _All the codes in this blog have been tested in the Dart’s master channel. You can try running the examples shown in this blog on [Dartpad](https://dartpad.dev/?channel=master) and switching the channel from stable (by defualt) to master._

Now, let us get started with the major introductions in this new segment.

## Record

**Record** is a new first-class object defined in the `dart:core` library. It is able to hold single datum or multiple data of same or different types. A record is like a list in a sense that it can hold multiple data but unlike list, a record is immutable and have value equality. To use records, wrap your data with a pair of parenthesis. For example:

```Dart
final x = (1, 2, 'a'); // Here, x is a record with the type (int, int, String)

final y = (x: 'value', 5); // Here, y is a record having the type (int, {String x}) with the first field being named and second being positional
```
> _It is important to realize that if our record contains only one positional field, then there **MUST** be a trailing comma before the closing parenthesis._

```Dart
(String) x = ('a'); // Compile-time error
(String,) y = ('a',) // 👌

final z = ('a'); // Here, z is a String type
final z = ('a',); // Here, z is a record with (String) type
```
> _The expression `()` refers to the constant empty record with no fields._

## Why/When would I want to use a record? 🤔

Imagine a situation where you’d want to bundle multiple objects into a single value. At the point of writing this article, Dart offers mainly two ways to do so. Firstly, by storing the multiple data into a list. While this is doable, if the data that are to be stored, happen to be of different types, the best you can use is a `List<dynamic>` or a `List<Object>`. This easily loses the type safety feature.

```Dart
void main() {
  final json = <String, dynamic>{
    'name': 'Neko',
    'age': 22,
  };

  final info = studentInfo(json); // info is of type `List<Object>`
  final name = info[0] as String; // Manual casting 🤮
  final age = info[1] as int; // Manual casting 🤮
}

List<Object> studentInfo(Map<String, dynamic> json) {
  return [
    json['name'] as String,
    json['age'] as int,
  ];
}
```
Another way of accomplishing our goal would be by creating a class that would contain fields that are to be stored. This is okay if the class has some responsibilty. But if it is just about storing data, then creating a new class and instantiating an object would become verbose.

```Dart
void main() {
  final json = {    
    'name': 'Neko',
    'age': 22,
  };

  final info = Student.info(json);
  final name = info.name; // Neko
  final age = info.age; // 22
}

class Student {
  final String name;
  final int age;

  Student({
    required this.name,
    required this.age,
  });

  factory Student.info(Map<String, dynamic> json) {
    return Student(
      name: json['name'] as String,
      age: json['age'] as int,
    );
  }
}
```
Thus, a new solution was proposed in the form of Records. Records bring all the goodness of existing collections (`List`, `Set`, etc) while promoting type safety and helping to obtain concise code.

```Dart
void main() {
  final json = {
    'name': 'Neko',
    'age': 22,
  };

  final info = studentInfo(json);
  final name = info.$1; // Neko
  final age = info.$2; // 22
}

(String, int) studentInfo(Map<String, dynamic> json) {
  return (
    json['name'] as String,
    json['age'] as int,
  );
}
```
> _In the above method `studentInfo()`, its return type is `(String, int)` i.e. with the arrival of Records, it is possible to return multiple values from a function/method._

It is a compile-time error if a record has any of:

-   The same field name more than once.
-   Only one positional field and no trailing comma.
-   A field named `hashCode`, `runtimeType`, `noSuchMethod` or `toString`.
-   A field name that starts with an underscore.
-   A field name that collides with the synthesized getter name of a positional field. For example: (int, $1: int) since the named field `$1` collides with the getter for the first positional field.

## Record Type Annotations

A record can either have positional or named field(s) or a combination of both.

### Record with positional fields

```Dart
(int, String) value = (1, 'a');
```
### Record with named fields

```Dart
({int i, String str}) value = (i: 1, str: 'a');
```
### Record with named and positional fields

```Dart
(int, {String str}) value1 = (5, str: 'a');

// - - - - - - - - - - - - - - - - - - - - - - - - - -

(int, {String str}) value2 = (str: 'a', 5);

// - - - - - - - - - - - - - - - - - - - - - - - - - -

(int, {String s, int i}) value3 = (s: 'data', i: 1, 5);
                        // OR
(int, {int i, String s}) value3 = (s: 'data', i: 1, 5);
```
## Destructuring

Since, a record is a collection, there has to be a way of accessing its individual field. That is known as destructuring. Once a record has been created, its fields can be accessed using getters. Every named field exposes a getter with the same name, and positional fields expose getters named `$1`, `$2`, etc.

### Destructuring positional fields

```Dart
final value = ('Neko', 22);
print(value.$1); // Neko
print(value.$2); // 22
```
Invoking `$1` on a record gives the first element of that record and so on.

> _Using `$0` on a record to obtain the first element will result in a compile-time error._

### Destructuring named fields

```Dart
final value = (name: 'Neko', age: 22);
print(value.name); // Neko
print(value.age); // 22
```
### Destructuring positional and named fields

```Dart
final value = ('Neko', age: 22, address: 'Nepal', 7);
print(value.$1); // Neko
print(value.age); // 22
print(value.address); // Nepal
print(value.$2); // 7
```
If we take a closer look at destructuring our records, it is still pretty verbose. That’s where **Patterns** come into play. With the help of patterns, we can destructure records inline.

```Dart
final (name, age) = ('Neko', 22);
print(name); // Neko
print(age); // 22

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

final (name, age, address: addr) = ('Neko', 22, address: 'Nepal');
print(name); // Neko
print(age); // 22
print(addr); // Nepal
```
In the above example, the data type for the variables `name`, `age` and `addr` is implicitly assigned by Dart. Though not necessary, we can also explicitly assign the data type for each field in the Record.

```Dart
final (String name, int age, address: String addr) = ('Neko', 22, address: 'Nepal');
print(name); // Neko
print(age); // 22
print(addr); // Nepal
```

### JSON Destructuring

In addition to records, patterns allow destructuring on JSON objects too.

```Dart
final map = {'first': 1, 'second': 2};
final {'first': a, 'second': b} = map;
print(a); // 1
print(b); // 2

// - - - - - - - - - - - - - - - - - - - - - -

final map = {
  'events': ['event-1', 'event-2']
};
final {'events': [firstEvent, secondEvent]} = map;
print(firstEvent); // event-1
print(secondEvent); // event-2
```

Most of the times, the obtained data in JSON representation is provided by the backend, and before we work on it, we need to validate if the obtained response is to our liking. Let’s consider the following JSON:

```Dart
final map = {
  'events': ['event-1', 'event-2']
};
```
If we were to validate this JSON in a traditional way. We’d have to something like this.

```Dart
final json = <String, dynamic>{
  'events': ['event-1', 'event-2']
};

if (json.length == 1 && json.containsKey('events')) {
  final events = json['events'];
  if (events != null &&
      events.isNotEmpty &&
      events is List<dynamic> &&
      events.length == 2) {
    final firstEvent = events[0] as String; // Manual type-casting 🤮
    final secondEvent = events[1] as String; // Manual type-casting 🤮

    print(firstEvent); // event-1
    print(secondEvent); // event-2
  }
}
```
This code is clearly verbose and error-prone. With the help of pattern, we can easily perform JSON validation and obtain desired result.

```Dart
final json = <String, dynamic>{
  'events': ['event-1', 'event-2']
};

switch (json) {
  case {'events': [String firstEvent, String secondEvent]}:
    print(firstEvent); // event-1
    print(secondEvent); // event-2
  default:
    throw 'Invalid JSON';
}
```
And that’s it. Patterns matches the JSON structure that we want and if it statisfies, the code inside of our case gets executed.

> _When the pattern doesn’t match the value, then it is said as the pattern refutes the value. Thus, irrefutable always match._

> _Also, in the above snippet, I didn’t add break in the switch-case explicitly. That’s because Dart 3 brings a new feature called [implicit break](https://github.com/dart-lang/language/blob/main/accepted/future-releases/0546-patterns/feature-specification.md#implicit-break)._

### Object Destructuring

Pattern Matching and destructuring is not only limited to Records and collections. We can also use the same set of tools for objects.

```Dart
abstract class Shape {}

class Rectangle extends Shape {
  Rectangle(this.length, this.breadth);

  final double length, breadth;
}

class Circle extends Shape {
  Circle(this.radius);

  final int radius;
}

void display(Shape shape) {
  switch (shape) {
    case Rectangle(length: final l, breadth: final b):
      print('Area of rectangle: ${l * b} sq. units');

    case Circle(radius: final r):
      print('Area of circle: ${22/7 * r * r} sq. units');

    default:
      print(shape);
  }
}

void main() {
  display(Rectangle(14, 2));
  display(Circle(7));
}
```
The getter names inside the switch can be omitted and inferred from the variable pattern such that the above `display()` method could be re-written as:

```Dart
void display(Shape shape) {
  switch (shape) {
    case Rectangle(:final length, :final breadth): // Inferred getter names
      print('Area of rectangle: ${length * breadth} sq. units');

    case Circle(:final radius):
      print('Area of circle: ${22 / 7 * radius * radius} sq. units');

    default:
      print(shape);
  }
}
```
## Guard Clauses

Guard clauses allow us to use arbitrary expression and see if the case should be matched. We use `when` keyword when using guard clause in switch cases.

```Dart
void main() {
  final list = <int>[1, 2];

  switch (list) {
    case [int a, int b] when a + b > 10: // Guard clause
      print('the sum is greater than 10');

    default:
      print('The sum is less than 10');
  }
}
```
> _Using guard clause is different from using `if` inside case body because if the guard is false, then the execution will continue in the next case instead of coming out of the entire switch case._

## Sealed class and pattern matching

A new addition is introduced in Dart 3 and that’s sealed class. It can be declared with the keyword sealed. Sealed classes can’t be directly constructed and are implicitly abstract.
```Dart
sealed class Shape {}
```
We can represent class hierarchies with sealed classes. The subtypes of a sealed class can be normal classes or sealed classes.

```Dart
sealed class Shape {}
class Circle extends Shape {}
sealed class Quadrilateral extends Shape {}
class Square extends Quadrilateral {}
class Rectangle extends Quadrilateral {}
```
The above class declarations can be used to visualize a class hierarchy that looks something like this.

```text
Shape       
  ├─ Circle       
  └─ Quadrilateral
        ├─ Square
        └─ Rectangle
```
> _All direct subtypes of the type must be defined in the same library where the sealed class is defined._

One advantage of having a sealed class is that the compiler is able to tell if we missed any subtype of that sealed class in the switch statement. This way, we get compile time error if our switch case isn’t exhaustive.

```Dart
sealed class Shape {}

class Square implements Shape {}
class Circle implements Shape {}
class Sphere implements Shape {}

String display(Shape shape) => switch (shape) {
      Square() => 'Square',
      Circle() => 'Circle',
      Sphere() => 'Sphere',
    };

void main() {
  print(display(Square()));
}
```

The `display()` method above could be re-written as:

```Dart
String display(Shape shape) {
  switch (shape) {
    case Square():
      return 'Square';
    case Circle():
      return 'Circle';
    case Sphere():
      return 'Sphere';
  }
}
        // OR

String display(Shape shape) {
  return switch (shape) {
    Square() => 'Square',
    Circle() => 'Circle',
    Sphere() => 'Sphere',
  };
}
```
## Logical & Relational operators in switch case

```Dart
void main() {
  int a = 5;

  display(a);
}

void display(int value) {
  switch (value) {
    case 1 || 2 || 3: // Logical Operator
      print('Top Three');

    default:
      print('Not top three');
  }
}
```

Dart 3 also supports switch expressions.

```Dart
void main() {
int obtainedMarks = 9;

final reaction = switch(obtainedMarks) {
    0 => 'Really?',
    1 || 2 || 3 => 'Call your parents',
    >= 4 && <=6 => 'Good',
    7 || 8 || 9 => 'Noice',
    10 => 'You are OP',
    _ => 'Invalid marks'
};

print(reaction); // Noice
}
```

> _The underscore in above switch expression aka wildcard acts as a default case._

## If-case Statements

Always using switch cases can be verbose. So, Dart 3 also provides us with the new if-case statements. It allows us to add a single pattern inside the if check and perform certain actions.

```Dart
void main() {
  final json = <String, dynamic>{
    'events': ['event-1', 'event-2']
  };

  if (json case {'events': [String firstEvent, String secondEvent]}) {
    print(firstEvent); // event-1
    print(secondEvent); // event-2
  } else {
    print('Invalid JSON');
  }
}
```
The above code is read as if the json follows the given pattern inside the if statement, then print firstEvent and secondEvent else print Invalid JSON.

## Control Flow in Argument Lists

> _This feature will not immediately be available in Dart 3. It is still a work being discussed.But since this feature is only possible with Records & Patterns into play, I decided to add it in this blog._

While writing Flutter code, we often write if checks inside collection literals such as inside the children property of a Row or a Column. This helps in writing clean code and avoid ugly imperative code. But sometimes, there are child widgets that need some conditional behaviour are inside named arguments and the best we can do is use ternary operator. Such as:

```Dart
ListTile(
  leading: const Icon(Icons.weekend),
  title: const Text('Hello'),
  enabled: hasNextStep,
  subtitle: hasNextStep ? const Text('Tap to advance') : null,
  onTap: hasNextStep ? () { advance(); } : null,
  trailing: hasNextStep ? null : const Icon(Icons.stop),
)
```
While it’s okay to use ternary operator as shown above for conditional behaviour, it can be made more elegant and easier with `if` inside arguments lists. Then the same code can be written as:

```Dart
ListTile(
  leading: const Icon(Icons.weekend),
  title: const Text('Hello'),
  enabled: hasNextStep,
  if(hasNextStep) ...(
    subtitle: const Text('Tap to advance'),
    onTap: advance,
  ) else ...(
    trailing: const Icon(Icons.stop),
  )
)
```
This way we can make use of `if` statement inside argument lists with spread operator like syntax.

## Conclusion

Records and Patterns bring so much new to Dart and with the addition of so many new options, Dart as a programming language will only prosper. For more depth overview on these topics, I highly encourage the readers to go through the Feature Specification on Github for [records](https://github.com/dart-lang/language/blob/main/accepted/future-releases/records/records-feature-specification.md), [patterns](https://github.com/dart-lang/language/blob/main/accepted/future-releases/0546-patterns/feature-specification.md), [sealed classes](https://github.com/dart-lang/language/blob/main/accepted/future-releases/sealed-types/feature-specification.md), etc.

If you wish to see some Flutter projects, follow me on [GitHub](https://github.com/Biplab-Dutta/). I am also active on Twitter [@b\_plab](https://twitter.com/b_plab98) where I tweet about Flutter and Android.

source: https://biplabdutta.com.np/posts/pattern-matching-dart/
