Finding out the time complexity of your code can help you develop better programs that run faster. Some functions are easy to analyze, but when you have loops, and recursion might get a little trickier when you have recursion. After reading this post, you are able to derive the time complexity of any code.

In general, you can determine the time complexity by analyzing the program’s statements (go line by line). However, you have to be mindful how are the statements arranged. Suppose they are inside a loop or have function calls or even recursion. All these factors affect the runtime of your code. Let’s see how to deal with these cases.

## [](https://adrianmejia.com/how-to-find-time-complexity-of-an-algorithm-code-big-o-notation/#Big-O-Notation "Big O Notation")Big O Notation

How to calculate time complexity of any algorithm or program? The most common metric it’s using Big O notation.

Here are some highlights about Big O Notation:

-   Big O notation is a framework to analyze and compare algorithms.
-   Amount of work the CPU has to do (time complexity) as the input size grows (towards infinity).
-   Big O = Big Order function. Drop constants and lower order terms. E.g. `O(3*n^2 + 10n + 10)` becomes `O(n^2)`.
-   Big O notation cares about the worst-case scenario. E.g., when you want to sort and elements in the array are in reverse order for some sorting algorithms.

For instance, if you have a function that takes an array as an input, if you increase the number of elements in the collection, you still perform the same operations; you have a constant runtime. On the other hand, if the CPU’s work grows proportionally to the input array size, you have a linear runtime `O(n)`.

If we plot the [most common Big O notation examples](https://adrianmejia.com/most-popular-algorithms-time-complexity-every-programmer-should-know-free-online-tutorial-course/), we would have graph like this:

![](https://adrianmejia.com/images/time-complexity-examples.png "Time Complexity")

As you can see, you want to lower the time complexity function to have better performance.

Let’s take a look, how do we translate code into time complexity.

## [](https://adrianmejia.com/how-to-find-time-complexity-of-an-algorithm-code-big-o-notation/#Sequential-Statements "Sequential Statements")Sequential Statements

If we have statements with basic operations like comparisons, assignments, reading a variable. We can assume they take constant time each `O(1)`.

<table><tbody><tr><td><pre><span>1</span><br><span>2</span><br><span>3</span><br><span>4</span><br></pre></td><td><pre><span>statement1;</span><br><span>statement2;</span><br><span>...</span><br><span>statementN;</span><br></pre></td></tr></tbody></table>

If we calculate the total time complexity, it would be something like this:

<table><tbody><tr><td><pre><span>1</span><br></pre></td><td><pre><span>total = time(statement1) + time(statement2) + ... time (statementN)</span><br></pre></td></tr></tbody></table>

Let’s use `T(n)` as the total time in function of the input size `n`, and `t` as the time complexity taken by a statement or group of statements.

<table><tbody><tr><td><pre><span>1</span><br></pre></td><td><pre><span>T(n) = t(statement1) + t(statement2) + ... + t(statementN);</span><br></pre></td></tr></tbody></table>

If each statement executes a basic operation, we can say it takes constant time `O(1)`. As long as you have a fixed number of operations, it will be constant time, even if we have 1 or 100 of these statements.

Example:

Let’s say we can compute the square sum of 3 numbers.

<table><tbody><tr><td><pre><span>1</span><br><span>2</span><br><span>3</span><br><span>4</span><br><span>5</span><br><span>6</span><br><span>7</span><br></pre></td><td><pre><span><span><span>function</span> <span>squareSum</span>(<span>a, b, c</span>) </span>{</span><br><span>  <span>const</span> sa = a * a;</span><br><span>  <span>const</span> sb = b * b;</span><br><span>  <span>const</span> sc = c * c;</span><br><span>  <span>const</span> sum = sa + sb + sc;</span><br><span>  <span>return</span> sum;</span><br><span>}</span><br></pre></td></tr></tbody></table>

As you can see, each statement is a basic operation (math and assignment). Each line takes constant time `O(1)`. If we add up all statements’ time it will still be `O(1)`. It doesn’t matter if the numbers are `0` or `9,007,199,254,740,991`, it will perform the same number of operations.

> ⚠️ Be careful with function calls. You will have to go to the implementation and check their run time. More on that later.

## [](https://adrianmejia.com/how-to-find-time-complexity-of-an-algorithm-code-big-o-notation/#Conditional-Statements "Conditional Statements")Conditional Statements

Very rarely, you have a code without any conditional statement. How do you calculate the time complexity? Remember that we care about the worst-case with Big O so that we will take the maximum possible runtime.

<table><tbody><tr><td><pre><span>1</span><br><span>2</span><br><span>3</span><br><span>4</span><br><span>5</span><br><span>6</span><br></pre></td><td><pre><span><span>if</span> (isValid) {</span><br><span>  statement1;</span><br><span>  statement2;</span><br><span>} <span>else</span> {</span><br><span>  statement3;</span><br><span>}</span><br></pre></td></tr></tbody></table>

Since we are after the worst-case we take whichever is larger:

<table><tbody><tr><td><pre><span>1</span><br></pre></td><td><pre><span>T(n) = Math.max([t(statement1) + t(statement2)], [time(statement3)])</span><br></pre></td></tr></tbody></table>

Example:

<table><tbody><tr><td><pre><span>1</span><br><span>2</span><br><span>3</span><br><span>4</span><br><span>5</span><br><span>6</span><br></pre></td><td><pre><span><span>if</span> (isValid) {</span><br><span>  array.sort();</span><br><span>  <span>return</span> <span>true</span>;</span><br><span>} <span>else</span> {</span><br><span>  <span>return</span> <span>false</span>;</span><br><span>}</span><br></pre></td></tr></tbody></table>

What’s the runtime? The `if` block has a runtime of `O(n log n)` (that’s common runtime for [efficient sorting algorithms](https://adrianmejia.com/most-popular-algorithms-time-complexity-every-programmer-should-know-free-online-tutorial-course/#Mergesort)). The `else` block has a runtime of `O(1)`.

So we have the following:

<table><tbody><tr><td><pre><span>1</span><br></pre></td><td><pre><span>O([n log n] + [n]) =&gt; O(n log n)</span><br></pre></td></tr></tbody></table>

Since `n log n` has a higher order than `n`, we can express the time complexity as `O(n log n)`.

## [](https://adrianmejia.com/how-to-find-time-complexity-of-an-algorithm-code-big-o-notation/#Loop-Statements "Loop Statements")Loop Statements

Another prevalent scenario is loops like for-loops or while-loops.

### [](https://adrianmejia.com/how-to-find-time-complexity-of-an-algorithm-code-big-o-notation/#Linear-Time-Loops "Linear Time Loops")Linear Time Loops

For any loop, we find out the runtime of the block inside them and multiply it by the number of times the program will repeat the loop.

<table><tbody><tr><td><pre><span>1</span><br><span>2</span><br><span>3</span><br><span>4</span><br></pre></td><td><pre><span><span>for</span> (<span>let</span> i = <span>0</span>; i &lt; array.length; i++) {</span><br><span>  statement1;</span><br><span>  statement2;</span><br><span>}</span><br></pre></td></tr></tbody></table>

For this example, the loop is executed `array.length`, assuming `n` is the length of the array, we get the following:

<table><tbody><tr><td><pre><span>1</span><br></pre></td><td><pre><span>T(n) = n * [ t(statement1) + t(statement2) ]</span><br></pre></td></tr></tbody></table>

All loops that grow proportionally to the input size have a linear time complexity `O(n)`. If you loop through only half of the array, that’s still `O(n)`. Remember that we drop the constants so `1/2 n => O(n)`.

### [](https://adrianmejia.com/how-to-find-time-complexity-of-an-algorithm-code-big-o-notation/#Constant-Time-Loops "Constant-Time Loops")Constant-Time Loops

However, if a constant number bounds the loop, let’s say 4 (or even 400). Then, the runtime is constant `O(4) -> O(1)`. See the following example.

<table><tbody><tr><td><pre><span>1</span><br><span>2</span><br><span>3</span><br><span>4</span><br></pre></td><td><pre><span><span>for</span> (<span>let</span> i = <span>0</span>; i &lt; <span>4</span>; i++) {</span><br><span>  statement1;</span><br><span>  statement2;</span><br><span>}</span><br></pre></td></tr></tbody></table>

That code is `O(1)` because it no longer depends on the input size. It will always run statement 1 and 2 four times.

### [](https://adrianmejia.com/how-to-find-time-complexity-of-an-algorithm-code-big-o-notation/#Logarithmic-Time-Loops "Logarithmic Time Loops")Logarithmic Time Loops

Consider the following code, where we divide an array in half on each iteration (binary search):

<table><tbody><tr><td><pre><span>1</span><br><span>2</span><br><span>3</span><br><span>4</span><br><span>5</span><br><span>6</span><br><span>7</span><br><span>8</span><br><span>9</span><br><span>10</span><br><span>11</span><br><span>12</span><br></pre></td><td><pre><span><span><span>function</span> <span>fn1</span>(<span>array, target, low = <span>0</span>, high = array.length - <span>1</span></span>) </span>{</span><br><span>  <span>let</span> mid;</span><br><span>  <span>while</span> ( low &lt;= high ) {</span><br><span>    mid = ( low + high ) / <span>2</span>;</span><br><span>    <span>if</span> ( target &lt; array[mid] )</span><br><span>      high = mid - <span>1</span>;</span><br><span>    <span>else</span> <span>if</span> ( target &gt; array[mid] )</span><br><span>      low = mid + <span>1</span>;</span><br><span>    <span>else</span> <span>break</span>;</span><br><span>  }</span><br><span>  <span>return</span> mid;</span><br><span>}</span><br></pre></td></tr></tbody></table>

This function divides the array by its `mid`dle point on each iteration. The while loop will execute the amount of times that we can divide `array.length` in half. We can calculate this using the `log` function. E.g. If the array’s length is 8, then we the while loop will execute 3 times because `log2(8) = 3`.

## [](https://adrianmejia.com/how-to-find-time-complexity-of-an-algorithm-code-big-o-notation/#Nested-loops-statements "Nested loops statements")Nested loops statements

Sometimes you might need to visit all the elements on a 2D array (grid/table). For such cases, you might find yourself with two nested loops.

<table><tbody><tr><td><pre><span>1</span><br><span>2</span><br><span>3</span><br><span>4</span><br><span>5</span><br><span>6</span><br><span>7</span><br><span>8</span><br></pre></td><td><pre><span><span>for</span> (<span>let</span> i = <span>0</span>; i &lt; n; i++) {</span><br><span>  statement1;</span><br><span></span><br><span>  <span>for</span> (<span>let</span> j = <span>0</span>; j &lt; m; j++) {</span><br><span>    statement2;</span><br><span>    statement3;</span><br><span>  }</span><br><span>}</span><br></pre></td></tr></tbody></table>

For this case, you would have something like this:

<table><tbody><tr><td><pre><span>1</span><br></pre></td><td><pre><span>T(n) = n * [t(statement1) + m * t(statement2...3)]</span><br></pre></td></tr></tbody></table>

Assuming the statements from 1 to 3 are `O(1)`, we would have a runtime of `O(n * m)`. If instead of `m`, you had to iterate on `n` again, then it would be `O(n^2)`. Another typical case is having a function inside a loop. Let’s see how to deal with that next.

## [](https://adrianmejia.com/how-to-find-time-complexity-of-an-algorithm-code-big-o-notation/#Function-call-statements "Function call statements")Function call statements

When you calculate your programs’ time complexity and invoke a function, you need to be aware of its runtime. If you created the function, that might be a simple inspection of the implementation. If you are using a library function, you might need to check out the language/library documentation or source code.

Let’s say you have the following program:

<table><tbody><tr><td><pre><span>1</span><br><span>2</span><br><span>3</span><br><span>4</span><br><span>5</span><br><span>6</span><br><span>7</span><br><span>8</span><br><span>9</span><br></pre></td><td><pre><span><span>for</span> (<span>let</span> i = <span>0</span>; i &lt; n; i++) {</span><br><span>  fn1();</span><br><span>  <span>for</span> (<span>let</span> j = <span>0</span>; j &lt; n; j++) {</span><br><span>    fn2();</span><br><span>    <span>for</span> (<span>let</span> k = <span>0</span>; k &lt; n; k++) {</span><br><span>      fn3();</span><br><span>    }</span><br><span>  }</span><br><span>}</span><br></pre></td></tr></tbody></table>

Depending on the runtime of fn1, fn2, and fn3, you would have different runtimes.

-   If they all are constant `O(1)`, then the final runtime would be `O(n^3)`.
-   However, if only `fn1` and `fn2` are constant and `fn3` has a runtime of `O(n^2)`, this program will have a runtime of `O(n^5)`. Another way to look at it is, if `fn3` has two nested and you replace the invocation with the actual implementation, you would have five nested loops.

In general, you will have something like this:

<table><tbody><tr><td><pre><span>1</span><br></pre></td><td><pre><span>T(n) = n * [ t(fn1()) + n * [ t(fn2()) + n * [ t(fn3()) ] ] ]</span><br></pre></td></tr></tbody></table>

## [](https://adrianmejia.com/how-to-find-time-complexity-of-an-algorithm-code-big-o-notation/#Recursive-Functions-Statements "Recursive Functions Statements")Recursive Functions Statements

Analyzing the runtime of recursive functions might get a little tricky. There are different ways to do it. One intuitive way is to explore the recursion tree.

Let’s say that we have the following program:

<table><tbody><tr><td><pre><span>1</span><br><span>2</span><br><span>3</span><br><span>4</span><br><span>5</span><br><span>6</span><br></pre></td><td><pre><span><span><span>function</span> <span>fn</span>(<span>n</span>) </span>{</span><br><span>  <span>if</span> (n &lt; <span>0</span>) <span>return</span> <span>0</span>;</span><br><span>  <span>if</span> (n &lt; <span>2</span>) <span>return</span> n;</span><br><span></span><br><span>  <span>return</span> fn(n - <span>1</span>) + fn(n - <span>2</span>);</span><br><span>}</span><br></pre></td></tr></tbody></table>

You can represent each function invocation as a bubble (or node).

Let’s do some examples:

-   When you n = 2, you have 3 function calls. First `fn(2)` which in turn calls `fn(1)` and `fn(0)`.
-   For `n = 3`, you have 5 function calls. First `fn(3)`, which in turn calls `fn(2)` and `fn(1)` and so on.
-   For `n = 4`, you have 9 function calls. First `fn(4)`, which in turn calls `fn(3)` and `fn(2)` and so on.

Since it’s a binary tree, we can sense that every time `n` increases by one, we would have to perform at most the double of operations.

Here’s the graphical representation of the 3 examples:

![](https://adrianmejia.com/images/big-o-recursive-example.png "recursive-function-example")

If you take a look at the generated tree calls, the leftmost nodes go down in descending order: `fn(4)`, `fn(3)`, `fn(2)`, `fn(1)`, which means that the height of the tree (or the number of levels) on the tree will be `n`.

The total number of calls, in a complete binary tree, is `2^n - 1`. As you can see in `fn(4)`, the tree is not complete. The last level will only have two nodes, `fn(1)` and `fn(0)`, while a complete tree would have 8 nodes. But still, we can say the runtime would be exponential `O(2^n)`. It won’t get any worst because `2^n` is the upper bound.

## [](https://adrianmejia.com/how-to-find-time-complexity-of-an-algorithm-code-big-o-notation/#Summary "Summary")Summary

In this chapter, we learned how to calculate the time complexity of our code when we have the following elements:

-   Basic operations like assignments, bit, and math operators.
-   Loops and nested loops
-   Function invocations and recursions.

If you want to see more code examples for `O(n log n)`, `O(n^2)`, `O(n!)`, check out the [most common time complexities that every developer should know](https://adrianmejia.com/most-popular-algorithms-time-complexity-every-programmer-should-know-free-online-tutorial-course).
