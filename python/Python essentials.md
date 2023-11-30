# Python Wish List

## Introduction

The Python programming language is praised for its simplicity and readability and offers a multitude of powerful features and concepts. As you might embark on your personal Python journey, you may wonder about the essential concepts that can significantly enhance your programming effectiveness and efficiency.

In this article, join me on this journey through essential Python concepts I either didn’t pay enough attention to or somehow managed to overlook during my own early learning adventures. However, as I’ve returned to relearn the fundamentals with a deeper emphasis, I’ve discovered these invaluable gems — concepts that are not only native to Python but essential for building a versatile programming toolkit.

Together, we’ll explore these fundamental to more advanced concepts to ensure that you get a good grasp of their importance and how they’re implemented.

**Let’s dive in!**

## Background

Before we get into the depths of these Python gems, let’s take a moment to lay out what we’ll be exploring.

## Assign Variables in One Line

Efficiently assign multiple variables in one line to simplify your code.

## Unpacking Lists/Tuples

Utilize list and tuple unpacking to assign elements to variables efficiently.

## String Formatting

Insert values into strings in a controlled manner using string formatting techniques like f-strings.

## Truthy and Falsey Values

Grasp how Python evaluates values as Truthy or Falsey, crucial for effective conditional statements.

## Ternary Operator

Write concise conditional statements in a single line, enhancing code readability.

## Short Circuiting

Understand short-circuiting with logical operators to save processing time during conditional evaluations.

## Mutable vs. Immutable Types

Understand the difference between mutable and immutable data types in Python.

## List Comprehension

Create lists elegantly and efficiently using list comprehensions, reducing the need for verbose loops.

## Dictionaries and Default Values

Access dictionary values with default fallback values using the **.get()** method.

## Enumerate()

Iterate over sequences while accessing both index and value using the enumerate() function.

## Sets and Frozensets

Work with sets to store unique values and frozensets for immutable sets, automatically removing duplicates.

## \*Args and \*\*Kwargs

Utilize function argument unpacking techniques to increase the flexibility and adaptability of your functions.

## Docstrings

Enhance code documentation with informative docstrings, aiding others in understanding and using your functions, classes or modules.

## Exception Handling

Manage errors gracefully with try and except blocks, preventing program crashes and providing user-friendly error messages.

## Walrus Operator (:=)

Introduced in Python 3.8, the walrus operator assigns values as part of an expression, enabling concise and expressive code.

## Generators

Efficiently create iterable sequences of values using generators, which generate values on-the-fly, conserving memory.

## Lambda Functions

Use concise inline lambda functions, often with functions like map, filter and sorted, for various operations.

## Context Managers

Ensure proper resource management, such as automatic file closure, with context managers and the **with** statement.

## Modules

Organize and reuse code efficiently by utilizing Python’s modules.

## Decorators

Modify or enhance the behavior of functions or methods using decorators, adding functionality without altering the original code.

Now let’s get into the meat of these concepts with more detailed explanations along with examples!

## **Python Essential Concepts**

## **Assign Variables in One Line**

Assigning variables in one line means assigning values to multiple variables in a single code line. This is often done for brevity and clarity in code

```python
x, y, z = 1, 2, 3
```

we’ve initialized three variables **x**, **y** and **z** in one line, each with its respective value **1**, **2** and **3**. This is a concise way of assigning values to multiple variables at once.

## Unpacking Lists/Tuples

Unpacking lists or tuples refers to extracting and assigning their elements to individual variables. This is a convenient way to work with the individual values contained within these data structures.

Here is a list or tuple containing multiple values:

```python
my_tuple = (1, 2, 3)
```

You can unpack these values into separate variables like this:

```python
a, b, c = my_tuple
```

Now, **a** will have the value **1**, **b** will have the value **2** and **c** will have the value **3**.

This is useful when you want to work with the elements of a list or tuple individually without having to access them using indexes. Unpacking is also commonly used in functions to return multiple values as a tuple and then unpack them when calling the function.

## String Formatting

String formatting allows you to insert values into strings in a controlled manner. This helps you control the appearance and structure of your output text. In Python, there are various ways to format strings, including the older **%** operator and the newer **str.format()** method.

Here’s an example of using f-strings, which are a modern and concise way to format strings in Python :

```python
name = "Ifeanyi"
age = 27
formatted_string = f"My name is {name} and I am {age} years old."
```

In this case, the f-string **f”My name is {name} and I am {age} years old.”** dynamically inserts the values of **name** and **age** into the string.

The output result:

```python
My name is Ifeanyi and I am 27 years old.
```

## **Truthy and Falsey Values**

Truthy and falsey values in Python refer to how values are interpreted in conditional expressions like **if** statements or boolean contexts. In Python, certain values are considered “**truthy**”, meaning they are treated as True when evaluated in a boolean context, while others are considered “**falsey**”, meaning they are treated as False.

Truthy values in Python include non-zero numbers, non-empty strings, non-empty lists, non-empty dictionaries and objects.

For the below example, the **if** statement evaluates **42** as a truthy value, so the code inside the **if** block will be executed.

```python
if 5: # 5 is a truthy value 
print("This will be printed") 
```

Falsey values in Python include **0**, None, an empty string **“ ”**, an empty list **\[\]** and an empty dictionary **{ }.**

In this example below, the **if** statement evaluates **0** as a falsey value, so the code inside the **if** block will not be executed

```python
if 0: # 0 is a falsey value 
print("This won't be printed")
```

## **Ternary Operator**

The ternary operator, also known as the conditional expression allows you to write concise conditional statements in a single line. It allows you to assign a value to a variable based on a condition.

```python
x = 10 
result = "Even" if x % 2 == 0 else "Odd"
```

This assigns the value **Even** to the variable **result** if **x** is even and **Odd** if it’s not.

## Short Circuiting

Short circuiting refers to the behavior of logical operators e.g **and**, **or** where the second operand is not evaluated if the outcome can be determined by the first operand.

This optimization can improve code efficiency and prevent unnecessary computations.

```python
a = 10
b = 5

if b > 5 and a / b > 2:
    print("Both conditions are true.")
else:
    print("Short-circuited because the first condition is false.")
```

Since the variable **b** is not greater than **5**, the second condition **a / b > 2** is not evaluated so “**Short-circuited because the first condition is false.”** will be printed.

## Mutable vs. Immutable Types

In Python, data types can be categorized as either mutable or immutable based on whether their values can be changed after they are created.

Mutable data types are those whose values can be modified or changed after they are created. Lists, dictionaries and sets are examples of mutable data types. When you modify a mutable object, it retains its identity (memory address), but its content can be altered.

```python
my_list = [1, 2, 3]my_list.append(4)  print(my_list)
```

The output result:

```python
[1, 2, 3, 4]
```

Immutable data types, on the other hand, cannot be changed once they are created. Examples of immutable data types include strings, tuples and frozensets. Any operation that appears to modify an immutable object actually creates a new object with the modified value.

Here we demonstrate immutability using strings:

```python
name = "Ifeanyi"name += " Otuonye"print(my_string)
```

The output result:

```python
Ifeanyi Otuonye
```

Even though we appended “ **Otuonye**” to the **name** variable, it does not modify the original string but creates a new one, showing the immutable nature of strings.

## List Comprehension

List comprehensions are concise ways to create lists. They allow you to generate a new list by applying an operation or expression to each item in an existing iterable (e.g., a list, tuple, or range)

With these list of numbers, we want to create a new list containing the squares of only the even numbers from the original list:

```python
original_numbers = [1, 2, 3, 4, 5, 6]
squares_of_evens = [x ** 2 for x in original_numbers if x % 2 == 0]
```

This list comprehension generates the **squares\_of\_evens** list and applies the expression **x \*\* 2** to each element **x** in the **original\_numbers** list, but only if the condition **x % 2 == 0** is met.

As a result, **squares\_of\_evens** will contain **\[4, 16, 36\]**, which are the squares of the even numbers in the original list.

## Dictionaries Default Values

Dictionaries are collections of key-value pairs. When you want to access a value in a dictionary, you can use the **.get()** method to retrieve the value associated with a specified key. If the key exists, it returns the corresponding value but if the key doesn’t exist, you can provide a default fallback value.

Here’s an example:

```python
# Creating a dictionary
user_data = {
  "name": "John", 
  "age": 30
}

# Accessing values with .get() and a default value
occupation = user_data.get("occupation", "unknown")

print(f"The occupation is {occupation}.")
```

Here, the **.get()** method tries to retrieve the value associated with the **occupation** key from the **user\_data** dictionary, however, it defaults to **unknown** as the key is not present and outputs:

```
The occupation is unknown.
```

## Enumerate()

enumerate() is a built-in function used to iterate over both the index and value of iterable objects.

```python
fruits = ['apple', 'banana', 'cherry']
for index, fruit in enumerate(fruits, start=1):
    print(f"Item {index}: {fruit}")
```

**enumerate(fruits, start=1)** creates an iterator that produces pairs of (**index**, **fruit**) as you loop through the fruits list. The **start=1** parameter sets the initial index to **1** instead of the default **0**.

As a result, the code will output:

```
Item 1: appleItem 2: bananaItem 3: cherry
```

## Sets and Frozensets

Sets and frozensets are data structures in Python used to store collections of unique values. The key difference between them is that sets are mutable (can be modified), while frozensets are immutable (cannot be modified after creation)

Here we create a **set** to store unique numbers:

```python
# Creating a set
fruits = {"apple", "banana", "cherry", "banana"}

# Adding an element
fruits.add("orange")

# Removing an element
fruits.remove("cherry")

print(fruits)
```

The **fruits** set stores unique elements and will automatically remove duplicate values in the output result.

```python
{'orange', 'apple', 'banana'}
```

Here we create a **frozenset()** constructor which is defined to store unique numbers.

```python
# Creating a frozenset
colors = frozenset(["red", "green", "blue"])

# Attempting to add an element (will raise an error)
# colors.add("yellow")

print(colors)
```

The **colors** frozenset stores unique elements just like a set, but it cannot be modified. Any attempt to add or remove elements will result in an error.

The output result:

```python
frozenset({'red', 'green', 'blue'})
```

## \*Args and \*\*Kwargs

These are special syntaxes used in function definitions to work with variable numbers of arguments and keyword arguments.

-   **\*args** is used to pass a variable number of non-keyword (positional) arguments to a function. It allows you to pass any number of arguments and they are collected into a tuple inside the function.
-   **\*\*kwargs** allows it to accept a variable number of keyword arguments.

```python
def example_function(arg1, *args, kwarg1="default", **kwargs): 
    print(“arg1:”, arg1) 
    print(“args:”, args) 
    print(“kwarg1:”, kwarg1) 
    print(“kwargs:”, kwargs) 

example_function(1, 2, 3, kwarg1="custom", option1="A", option2="B")
```

-   **arg1** receives the first positional argument **1**.
-   **\*args** collects any additional positional arguments after **arg1** into a tuple. In this case, it collects **2** and **3** into the **args** tuple.
-   **kwarg1** receives the keyword argument **kwarg1= “custom”**.
-   **\*\*kwargs** collects any additional keyword arguments that are not explicitly named in the function signature into a dictionary. In this case, it collects **option1= “A”** and **option2= “B”** into the kwargs dictionary.

As a result, the code will output:

```python
arg1: 1
args: (2, 3)
kwarg1: custom
kwargs: {'option1': 'A', 'option2': 'B'}
```

## **Docstrings**

Docstrings are multi-line string literals used to provide documentation for functions, classes or modules. They are used to help developers understand how to use and work with the code.

```python
def greet(name): 
""" This function greets the person passed in as a parameter. """ 
    print(f"Hello, {name}!") 

# Access the docstring
docstring = greet.__doc__
print(docstring)
```

The docstring provides information about the purpose and usage of the **greet** function.

We can also access the docstring of a function, class or module by using the **.\_\_doc\_\_** attribute.

Running this code will print the docstring of the **greet** function.

```
This function greets the person passed in as a parameter.
```

## Exception Handling

Exception handling is crucial for managing errors gracefully allowing you to anticipate and handle exceptional situations or errors that may occur during the execution of a program.

It enables you to take specific actions when errors occur, such as providing informative error messages, logging the issue, or taking alternative paths in your code.

Here we have a **try** and **except** block is used to catch a **ZeroDivisionError**:

```python
try:
    result = 10 / 0
except ZeroDivisionError:
    print("Division by zero is not allowed.")
```

This code prevents a program crash by handling the division by zero error and displaying a user-friendly message.

The output results:

```
Division by zero is not allowed.
```

## **Walrus Operator (**:=**)**

Introduced in Python 3.8, the walrus operator assigns a value to a variable as part of an expression.

```python
while (user_input := input("Enter 'quit' to exit: ")) != 'quit': 
    print(f"You entered: {user_input}")
```

Here, the walrus operator both assigns the user input to **user\_input** and checks if it’s equal to **quit** in a single line.

## **Generators**

Generators allow you to create iterable sequences of values efficiently by defining functions with the **yield** keyword. They help conserve memory since they generate values on-the-fly as needed.

A generator function is defined like a regular function, but it contains one or more **yield** statements. When a function with **yield** is called, it doesn't execute the entire function at once but rather returns a generator object, which can be iterated over to produce values one at a time.

The following defines a generator that produces even numbers:

```python
def count_up_to(n):
    i = 1
    while i <= n:
        yield i
        i += 1

# Create a generator object
counter = count_up_to(5)

# Iterate over the generator to get values one at a time
for num in counter:
    print(num)
```

Here, **count\_up\_to** function is a generator that yields values from 1 up to **n.** When you create the generator object **counter**, it doesn't execute the function immediately. Instead, it creates an iterator. When you loop over **counter**, it yields values one at a time as you iterate, which is more memory-efficient than generating a list of all values upfront.

As a result, the code will output:

```
12345
```

## **Lambda Functions**

Lambda functions in Python are concise, inline functions that allow you to create small, anonymous functions without the need for a formal **def** statement. They are particularly useful when you need a simple function for a short period and don't want to define a separate named function. Lambda functions are often used with higher-order functions like **map**, **filter** and **sorted.**

Here a lambda function is used with **map** to square a list of numbers:

```python
numbers = [1, 2, 3, 4, 5]
squared = list(map(lambda x: x**2, numbers))
print(squared_numbers)
```

Here, the lambda function **lambda x: x\*\*2** is applied to each element in the **numbers** list, resulting in a list of squared numbers.

The output result:

```
[1, 4, 9, 16, 25]
```

## Context Managers

Context managers are used to ensure proper resource management, such as automatically closing files, releasing locks, or cleaning up resources after they are no longer needed. They help simplify resource handling and improve code readability.

This is a context manager with the **with** statement to open and close a file:

```python
# Opening and closing a file using a context manager
with open('test.txt', 'w') as file:
    file.write('Hello, World!')
```

In this case, the file is automatically closed when the block inside the **with** statement exits, ensuring that resources are managed correctly.

## Modules

Python allows you to organize code into modules for better organization, reusability and and maintainability.

A module is a single Python file that contains functions, variables and classes that you can import into other Python scripts. They are used to encapsulate related code and promote code reusability.

Here we have a file named **math\_operations.py**

```python
# math_operations.py

def add(x, y):
    return x + y

def subtract(x, y):
    return x - y
```

You can import and use this module in another Python script:

```python
# main.py

import math_operations

result = math_operations.add(5, 3)
print(result)
```

The output result:

```
8
```

## Decorators

Decorators are functions that modify or enhance the behavior of other functions or methods. They are used to add functionality to functions or methods without changing their source code and are commonly used for tasks such as logging, authentication, access control etc.

In this code, a timing decorator is created to measure the execution time of a function:

```python
import time

def timing_decorator(func):
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()
        print(f"Execution time: {end_time - start_time} seconds")
        return result
    return wrapper

@timing_decorator
def slow_function():
    time.sleep(2)

slow_function()
```

The decorator **timing\_decorator** defined measures the execution time of a wrapped function. When the decorated function **slow\_function** which includes a 2-second delay using **time.sleep(2)** is invoked, the decorator records and prints the execution time.

When **slow\_function()** is called, it prints the execution time, which is about 2.0 seconds and reflects the time taken by the sleep operation within the function.

The output result:

```
Execution time: 2.0 seconds
```

**Thats it!**

## Congratulations!

You’ve reached the end. We’ve explored essential Python concepts that can significantly improve your programming skills for those just getting familiar in this programming language.

With this knowledge based off of my personal experience, I hope you will be better equipped for more complex coding challenges and writing elegant and efficient Python code with confidence.

If you’ve got this far, **thanks for reading!** I hope it was worthwhile for you.

source: https://python.plainenglish.io/python-programming-essentials-what-i-wished-i-learned-52659e4937ad
