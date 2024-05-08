![](https://miro.medium.com/v2/resize:fit:700/0*kR_FlXyqWK328fuF.jpg)

Android Tasks

## Introduction

Hello, have you ever found yourself with multiple instances of the same activity in your Android app? Have you ever clicked the back button, destroy your activity only to encounter the same activity again? In this article I will explain the various activity launch modes available in Android so you can avoid running into this issue with your activities.

Before we get into the launchModes, you should get familiar with what **tasks** are in this context. A task is basically a collection of activities that users interact with. Whenever your app launches a new activity or finishes an activity the related activity is either added or removed from the **backstack** where your activies are stored in the order which they were created. You can learn more about these concepts in the related link down below the references.

There are five modes available to the developer:

-   Standard
-   SingleTop
-   SingleTask
-   SingleInstance
-   SingleInstancePerTask

![](https://miro.medium.com/v2/resize:fit:700/0*OiNIbkfOiChV00ym)

Four Main Launch Modes

Standard is your default mode unless specified otherwise.

## Standard Mode

This mode launches a new instance of an activity in the task. This mode can create multiple instances of the same activity, and these can be assigned to the same or separate tasks.

```
<span id="ed00" data-selectable-paragraph=""><span>&lt;<span>activity</span> <span>android:launchMode</span>=<span>"standard"</span>&gt;</span></span>
```

Let’s say you have 4 different activities, A, B, C and D and they were launched in order:

> A -> B -> C -> D

In this mode, if you launch activity B again the order will be:

> A -> B -> C -> D -> **B** where activity B is created again

## SingleTop Mode

This mode differs from the standard mode where singleTop will not create a new activity if the said activity is **already in the stack** and is **on the top the stack.**

```
<span id="1932" data-selectable-paragraph=""><span>&lt;<span>activity</span> <span>android:launchMode</span>=<span>"singleTop"</span>&gt;</span></span>
```

Let’s say you have 4 different activities, A, B, C and D and they were launched in order:

> A -> B -> C -> D

In this mode, if you launch activity D again the order will be:

> A -> B -> C -> D where activity D is not created again.

But consider the scenario where you were to launch activity B:

> A -> B -> C -> D -> **B** where activity B is created again because even though it was in the backstack, it was not at the top**.**

## SingleTask Mode

This mode differs from the singleTop mode where singleTask will destroy any activity on top of the said activity, provided the activity is **already in the stack.**

```
<span id="f15b" data-selectable-paragraph=""><span>&lt;<span>activity</span> <span>android:launchMode</span>=<span>"singleTask"</span>&gt;</span></span>
```

Let’s say you have 4 different activities, A, B, C and D and they were launched in order:

> A -> B -> C

In this mode, if you launch activity D again the order will be:

> A -> B -> C -> D where activity D is created.

But consider the scenario where you were to launch activity B after creating activity D:

> A -> B where activity B is **brought to the top of the stack** in its old state and other activities on **top of the activity B is destroyed**

## SingleInstance Mode

This mode is similar to singleTask mode, but the major difference is that the activity is launched in a new task and this task cannot have any other activities.

```
<span id="57c7" data-selectable-paragraph=""><span>&lt;<span>activity</span> <span>android:launchMode</span>=<span>"singleInstance"</span>&gt;</span></span>
```

Let’s say you have 4 different activities, A, B, C and D and they were launched in order:

> Task1: A -> B -> C

In this mode, if you launch activity D again the order will be:

> Task1: A -> B -> C
> 
> Task2: D where the activity D is created in a separate task.

In this state, if you were to create another instance of activity D, the state would be:

> Task1: A -> B -> C
> 
> Task2: D where the activity D is not created again because it was already in the task2 and instead retrieved in its old state.

But what about creating a new activity E, which we’ll assume isn’t on singleInstance mode?

> Task1: A -> B -> C -> E
> 
> Task2: D where activity E is created on task1.

## SingleInstancePerTask Mode

This mode is similar to singleInstance mode, but the only difference is that muliple instances of the activity can be created in different tasks.

## Conclusion

In this article we have learned what activity launch modes are and how they affect the backstack. If you are working with activities, these modes are important for a seamless navigation experience for your users.

source: https://medium.com/huawei-developers/android-launch-modes-explained-8b32ae01f204
