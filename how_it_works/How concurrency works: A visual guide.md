Dec 12, 2024

# How concurrency works: A visual guide

![concurrency is hard](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/one.png)

Concurrent programming is hard.

Mentally enumerating all the possible states that complex concurrent code might go through is far from easy. Visualizing concurrency can make it easier to understand how these programs operate, especially for those just beginning to learn about concurrency.

Such visualizations might not always be effective for larger or more complex systems. But even with complex systems, breaking them down into smaller models and visualizing those models can be an excellent way to understand what’s happening behind the scenes.

Recently, I’ve been exploring model checking and found the mindset it enforces to be not only intriguing but also quite powerful. Leslie Lamport, the renowned researcher in distributed systems and concurrency, has a brilliant quote: _If you’re thinking without writing, you only think you’re thinking._ For large and complex distributed or concurrent programs, I believe this principle extends further: _If you’re implementing without formally verifying your solution through model checking, you only think you’re implementing it correctly_.

Model checking is a powerful tool, and I’ve come across a few resources that can help in understanding concurrency. This inspired me to write about them—not only to deepen my own understanding but also to share what I’ve learned. We’ll begin by exploring how to visualize the execution of a sequential program, then move on to visualizing a concurrent one. Finally, we’ll touch on how to reason about the correctness of concurrent programs.

Alright, let’s dive in!

We can visualize how concurrent programs operate by exploring their state space. A few questions arise immediately: What is a state? And what is a state space? Let’s tackle the first question first, then circle back to the second.

A program’s state is defined by the values of its variables and the location counter (which indicates the next instruction to be executed). Let’s walk through an example using a simple C-like language. We’ll look at the states and demonstrate how states transition during the sequential (non-concurrent) execution of the following program. (We’ll dive into a concurrent program example right after this.)

![concurrency is hard](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/two.png)

The program above consists of three instructions, and for clarity, labels are added as location counters on the far left (i.e., _1_, _2_, _3_, and _end_). The program includes a single variable, **n**, which is declared as a byte.

The state of the program can be represented as a tuple containing the value of the variable **n** and the location counter: **(n, location counter)**. For example, when the program starts, its initial state is **(undefined, 1)**. This is because, at the beginning, none of the program’s statements have been executed, leaving the value of **n** as “undefined,” while the location counter points to the first instruction, labeled as 1.

We can visualize this state as follows: the orange arrow represents the location counter, and the current value of **n** is displayed at the bottom for clarity.

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/three.png)

To move to the next state, we can advance the location counter. So we advance the location counter to 2 after executing the statement at location counter 1, the next state becomes **(0, 2)**, indicating that **n** is now 0 and the location counter points to 2. This state, **(0, 2)**, reflects that the value of **n** has been set to 0 as a result of executing the first statement and is visualized as follows:

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/four.png)

The location counter increments again, and the next state becomes **(1, 3)**. The value of **n** has changed to 1 because, in the previous state, the location counter was 2, and executing the statement at that location set **n** to 1. The situation now looks like this:

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/five.png)

Finally, the location counter increments one last time to reach the end, marking the completion of execution. At this point, the value of **n** remains 1.

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/six.png)

A given sequence of states, starting from an initial state and continuing as statements execute, is called a _computation_. For example, for the program above, the following is a computation:

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/seven.png)

As explained earlier, the state of a program is defined by the values of its variables and the location counter (which points at the next instruction to be executed). The state space of a program is simply the set of all possible states that can possibly occur during a computation. Ben-Ari offers a formal definition of state space in \[2\]: “The state space of a program is a directed graph; each reachable state is a node, and there is an edge from state s1 to state s2 if a transition enabled in s1 moves the computation to s2.”

Essentially, a state space represents all the states a concurrent program goes through during its execution. By examining the state space, you can understand the full range of program behavior, including unexpected scenarios that might arise from the intricate sequencing of concurrent operations. For this reason, I believe understanding how a state space is generated for a concurrent program can help us grasp how that program works on a more fundamental level.

In model checking, the state space is also used to reason about the correctness of concurrent programs—another reason to understand how it works. We’ll explore how to reason about correctness at the end.

We’ll now consider two procedures, running concurrently, to observe how their states transition and how the state space is generated. The program includes a global variable, **n**, and two procedures, **P** and **Q**, each consisting of the following statements:

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/eight.png)

These are two simple procedures, similar in their operation, each with its own location counter.

How can we represent a state for the program described above?

We can represent the state as a triple consisting of the value of the variable **n** and the location counters of **P** and **Q**: **(n, location counter of P, location counter of Q)**. To make it even clearer, we’ll represent the state as **(n, P: location-counter, Q: location-counter)**. For example, **(5, P: 1, Q: 2)** indicates that the value of **n** is 5, the location counter in **P** is at 1, and the location counter in **Q** is at 2.

For the program above, the initial state could be **(0, P: 1, Q: 2)**, where the value of **n** is 0, and the location counters are at the first statements of both **P** and **Q**. We can visualize this initiate state with the visualization below, with orange arrows indicating the location counters and the value of **n** displayed at the bottom:

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/nine.png)

Let’s explore two possible transitions from this initial state.

We can transition to the next state by incrementing the location counter in **P**, resulting in **(1, P: end, Q: 2)**. Here, **n** becomes 1, reflecting the result of the evaluated expression when the statement at location counter 1 was executed. The state at this point looks like this:

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/ten.png)

The second possible next state from the initial state could be reached by incrementing the location counter in **Q**. That next state we get by incrementing the location counter in **Q** is **(2, P: 1, Q: end)**, and we can visualize it like this:

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/eleven.png)

The location counter of **Q** reached its end, while **P** remained at location counter 1, and the value of **n** is 2.

So, the transition from the initial state **(0, P: 1, Q: 2)** to these two states could be represented as state space like this (left arrow points to the next state after an increment in the location counter of **P** whereas right arrow points to the next state after an increment in the location counter of **Q**) :

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/twelve.png)

Next, we’ll write the above program in PROMELA (a C-like language that SPIN \[1\] uses; SPIN is a software verification tool and a model checker) and then visualize its state space.

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/thirteen.png)

The code is C-like. The keyword **proctype** is used to declare a process, while the keyword **active** activates a process, ensuring that **P** and **Q** run concurrently when the program starts.

As before, we represent the state as a triple: **(n, location counter of P, location counter of Q)**. In the image above, the line numbers on the far left serve as location counters.

Below is the state space of the program:

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/fourteen.png)

_Figure 1_

The edges in the state space are labeled with orange text, indicating what triggers the transition to the next state. This state space shows that at the end of the program, the value of **n** could be either 1 or 2. (As an aside: In concurrency, there is also a concept called interleaving, where statements are chosen nondeterministically from processes. For example, a statement from process **P** could execute first, followed by one from **Q**, and so on. In the state space above, depending on the interleavings, we could say that at the end, the value of **n** might be either 1 or 2.)

Let’s quickly explore how state transitions occur along the right-hand path of the above state space in _Figure 1_.

Starting with the initial state at the top of the state space, **(0, P: 5, Q: 9)**,we can represent it as:

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/fifteen.png)

Starting from the initial state **(0, P: 5, Q: 9)**, if we increment the location counter in **Q**, moving it to line 10, the statement at line 9 executes, setting **n** to 2. This brings us to the next state, **(2, P: 5, Q: 10)**:

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/sixteen.png)

From this state, we transition to the next state by incrementing the location counter in **P**, resulting in **(1, P: 6, Q: 10)**. At this point, the value of **n** becomes 1 as the statement at location counter 5 executes, as shown below:

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/seventeen.png)

This marks the end of the computation along the right-hand path of the state space shown in _Figure 1_.

What happens if we extend **P** and **Q** by adding more statements? Does the state space expand, or does it shrink? Let’s find out.

Suppose we add a few more lines to both **P** and **Q**—introducing a local variable, assigning it a value, and setting the global variable **total** to a constant (as shown in _Figure 2_ below). While these changes might seem minor, they can impact the state space.

To explore the effect of these changes on the state space, I generated a visualization using _jSpin_ \[3\], an excellent educational tool by Ben-Ari built on top of Spin.

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/eighteen.png)

_Figure 2_

The code is displayed on the left side, while the state space is generated as a graph on the right side. In the graph, each box contains three lines: the top line shows the location counter in **P**, the middle line shows the location counter in **Q**, and the last line displays the value of the variable **total**.

The state space has expanded dramatically compared to the earlier example.

Now, imagine a concurrent program with dozens of processes, each executing thousands of lines of code with numerous variables. The state space would grow exponentially. Even small programs, if not managed carefully, can generate massive state spaces.

To further examine the impact of concurrency on state space size, I modified the above program to run five concurrent processes instead of two. As a result, the state space grew so large that, in the final visualization, each state appeared as a tiny dot, rendering the entire image unreadable.

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/nineteen.png)

This demonstrates just how challenging it can be to debug and test large or complex concurrent programs. You may need to address numerous scenarios, each leading to countless states. While creating visualizations for such large programs might not be practical (at least with jSpin), you can simplify your program into smaller models and generate visualizations from them.

These simplified visualizations can provide valuable insights into your implementation and serve as an excellent starting point for understanding what’s happening behind the scenes. They’re especially useful as a first step in helping folks grasp the complexities of concurrency.

State space can help us reason about the correctness of concurrent and distributed systems.

To increase confidence in a program’s correctness, we can define certain _invariants_ or _correctness properties_ that must hold across a program’s state space. Model checkers like SPIN, for one, can verify that these properties are upheld throughout the entire state space. For instance, we might define a property such as _“X should always be true,”_ meaning that **X** must not be false in any state.

When reasoning about large and complex distributed systems, this _invariant-based thinking_ becomes essential for ensuring correctness. To achieve this, we rely on two key types of properties:

-   **Safety properties**: Ensuring that nothing bad happens.
-   **Liveness properties**: Ensuring that something good eventually happens.

Model checkers like SPIN and TLA+ allow us to verify these properties.

Let’s try to come up with a safety property for the program shown in _Figure 2_ above. We want the safety properties to hold for every state in the program’s state space. Since a state is defined by a combination of the location counter and variables, for this example, we’ll focus on defining our property for the variable **total**. Please note that this is a somewhat contrived example, intended to demonstrate concepts.

For example purposes, to define a safety property, we can try to come up with an expression for the variable **total** that holds true in all program states. Consider the following expression as a safety property, where we expect **total** to be 1 in all states:

Would this hold true in every state? Let’s revisit the state space, represented as a directed graph on the right side of the code:

![](https://wyounas.github.io/images/2024-12-10-visualizing-concurrency/eighteen.png)

Does **total** equal 1 in all states? No, the above wouldn’t hold in every state because the value of **total** can be 0, 1, or 2 (as shown at the bottom of each square in the state space). There are states where **total** is 0 and others where it is 2, so the property `total == 1` doesn’t hold universally. Similarly, another property like `total == 2` wouldn’t hold either, for the same reason.

How about this instead?

Since there are states where the value of **total** is 0, the previous property wouldn’t hold universally either. However, the following does hold across all states:

```
total == 1 || total == 2 || total == 0
```

We almost derived a safety property by exploring the state space—this was just for example purposes. In practice, you may define safety and liveness properties even before writing any models or code.

As we examine the above expression, a question arises: How can we express it as a safety property and use it to validate correctness in SPIN?

Expressions like the one above can be expressed as a program’s safety property using _Linear Temporal Logic_ (LTL). LTL is based on propositional logic and allows formulas to include both logical operators and temporal operators, such as:

-   **Always (\[\] in SPIN)**: Ensures a condition holds in all states.
-   **Eventually (<> in SPIN)**: Ensures a condition will hold in some future state.

As an example, we can express the above expression as a safety property in LTL:

```
[] (total == 1 || total == 2 || total == 0)
```

This reads as: _Always, **total** is either 1, 2, or 0._ We can use this property in SPIN and validate the program’s correctness by ensuring it holds across the state space \[4\]. Our confidence in concurrent programs increases when we know that a certain property holds across the state space.

There is much more to LTL, and we’ll dive deeper into it in future articles. Validating safety and liveness properties with LTL is especially useful for large or complex programs.

In complex concurrent or distributed systems with thousands of possible states, relying on unit tests alone makes it hard to be confident in the solution’s correctness. Most of us would struggle to keep such a vast state space in mind while writing tests. Concurrency bugs are also tough to catch during testing as traditional methods, such as unit or integration tests (though essential), might overlook the issues. The timing and interleaving of events make these bugs hard to find and reproduce. This often leads to dealing with “heisenbugs”—bugs that behave unpredictably and are difficult to track down.

This all is what makes model checkers excel—they allow you to verify program correctness across a wide range of scenarios. Please stay tuned as I plan to write more about this.

_Thanks to Gerard Holzmann, Hillel Wayne, Jack Vanlightly, and Murat Demirbas for reading drafts of this._

_Please [email](mailto:waqas.younas@gmail.com) with questions, ideas, or corrections._

### References

1.  More detail and installation instructions are available at https://spinroot.com. And the overview paper The Model Checker Spin, IEEE Trans. on Software Engineering Vol. 23, No. 5, May 1997, pp. 279-295.
    
2.  Mathematical Logic for Computer Science, 3rd edition, by Mordechai Ben-Ari.
    
3.  For state space visualization, I used https://github.com/motib/jspin.
    
4.  You can specify the safety property in a `.prp` file and, assuming your PROMELA code is in `safety.pml`, run the following commands to validate it:
    
    ```
         $ spin -a -F safety.prp  safety.pml
         $ gcc -DSAFETY -o pan pan.c
         $ ./pan
    ```
    
5.  Top image courtesy of https://geek-and-poke.com/
    

source: https://wyounas.github.io/concurrency/2024/12/12/how-concurrency-works-a-visual-guide/?ref=dailydev
___

[← Back to all articles](https://wyounas.github.io/articles)
