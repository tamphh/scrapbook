# Mastering Advanced Decorators in Python: A Real-Life Example

Python is renowned for its elegant simplicity and robust capabilities, among its most remarkable features are decorators. A decorator in Python is fundamentally a function designed to modify the behavior of another function or method. It operates by ‘wrapping’ the target function, thereby enabling the addition of pre- and post-execution functionality without directly altering the original function’s code. While this concept might seem confusing at first, especially due to its unique syntax and operational flow, a deeper understanding unveils its immense power. Decorators serve as sophisticated instruments for extending and efficiently managing code, showcasing the versatility of Python as a programming language.

Before we dive into the advanced application of decorators, it’s important to note that this post assumes a solid foundation in Python programming. Familiarity with asynchronous programming in Python, as these concepts play a pivotal role in understanding the solutions presented.

Our journey begins with a real-life challenge encountered in the [llm-client](https://github.com/uripeled2/llm-client-sdk) project, an SDK for seamless integration with generative AI large language models. In its initial stages, llm-client supported only asynchronous operations, but as the project evolved, there emerged a need to extend these capabilities to synchronous contexts. This wasn't about merely adding a function or two, it involved a fundamental enhancement of every class similar to `AsyncFoo`, our example class that makes asynchronous HTTP calls. The goal was to achieve this without rewriting or duplicating the existing async code – a task easier said than done.

The solution we crafted is a testament to the power and versatility of advanced decorators in Python. By elegantly using these decorators, we transformed the async methods to sync, all the while maintaining our original codebase’s integrity and efficiency. This post is a detailed walkthrough of that solution, showcasing how decorators can be leveraged to solve complex problems in Python, proving they’re more than just syntactic sugar — they’re powerful tools capable of significant transformations.

Join me as we explore this intricate solution, learning not just about the “how”, but also the “why” behind each line of code, and witnessing the true prowess of Python’s decorators in action.

![](https://miro.medium.com/v2/resize:fit:1400/1*xkRU-UvXD7sJ-_RhoPAfGA.png)

A young girl focused on studying at her desk, surrounded by books and a laptop in a sunny, cozy study room, embodying dedication and concentration.

## Implementing Advanced Decorators: From Theory to Practice

Let’s look for example on a simple class that making async http calls:

```python
from aiohttp import ClientSession


class AsyncFoo:
    def __init__(self, session: ClientSession):
        self._session: ClientSession = session

    async def run(self):
        return await self._session.get("https://www.google.com")
```

> To run this code you will first need to run pip install [aiohttp](https://docs.aiohttp.org/en/stable/)

Now, let’s consider a scenario where we need to use the run function from a non-async function. One might suggest adding another class that employs [requests](https://pypi.org/project/requests/) instead of aiohttp. However, if you have numerous classes akin to AsyncFoo, this approach would lead to substantial code duplication. Let’s explore how we can address this issue efficiently by using decorators.

_Pause here if you’d like to give it a try yourself._

![](https://miro.medium.com/v2/resize:fit:1400/1*-QLZGqk5KJqWGISOUuWb6A.jpeg)

A hand holds a transparent hourglass with sand flowing down against the backdrop of a tranquil beach and ocean waves. Photo by [Paula Guerreiro](https://unsplash.com/@pguerreiro?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash) on [Unsplash](https://unsplash.com/photos/clear-hour-glass-on-persons-hand-W2atfIRHDIk?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash)

## Step 1: Creating a Session Management Decorator

First, we will need to create a decorator that handles the lifecycle of the ClientSession, ClientSession manages underlying connection pools and other resources. If you don’t explicitly create and close sessions, these resources might not be managed efficiently. This can lead to resource leaks, where connections or file descriptors remain open, potentially exhausting system resources over time, especially in applications that make numerous requests.

```python
from functools import wraps
from aiohttp import ClientSession

def _create_new_session(f):
    @wraps(f)
    async def func(self, *args, **kwargs):
        self._session = ClientSession()
        try:
            response = await f(self, *args, **kwargs)
            return response
        finally:
            await self._session.close()
    return func
```

-   `@wraps(f)`: This is best practice when writing decorator, it used to preserve the metadata of the original function `f`. It helps in keeping the introspection information about the original function like its docstring, name, annotations, etc.
-   The `func` defined inside `_create_new_session` is an asynchronous function that creates a new ClientSession, calls the original function, and ensures the session is closed after the function completes. This management of the session lifecycle is crucial to prevent resource leaks and ensure proper closure of network connections.

## Step 2: Applying the Decorator to All Methods

Next, we’ll develop a function designed to apply decorators to every method within a class. Without this step you would have to manually decorating each method, a process that can be error-prone and inefficient. This is particularly true for classes with numerous methods or when the same process needs to be applied across multiple classes.

> “Duplication may be the root of all evil in software.” Robert C. Martin (“Uncle Bob”)

```python
import inspect

def _decorate_all_methods_in_class(decorators):
    def apply_decorator(cls):
        for k, f in cls.__dict__.items():
            if inspect.isfunction(f) and not k.startswith("_"):
                for decorator in decorators:
                    setattr(cls, k, decorator(cls.__dict__[k]))
        return cls
    return apply_decorator
```

-   `inspect.isfunction(f)`: This checks if the class attribute is a function, which helps in identifying methods that need to be decorated.
-   `not k.startswith("_")`: This is used to skip private or protected methods (usually starting with `_`), as they are typically not part of the class's external interface.
-   `setattr(cls, k, decorator(cls.__dict__[k]))`: This applies each decorator to the method and reassigns it to the class.

## Step 3: Converting Async Methods to Sync

Didn’t we forget something? Oh yes the all code is still in async😱  
We can utilize a [library](https://pypi.org/project/async-to-sync/) that can convert the async methods of a class to synchronous methods:

```python
import async_to_sync

sync_foo = async_to_sync.methods(_decorate_all_methods_in_class([_create_new_session])(AsyncFoo)(session=None))
```

-   `async_to_sync.methods`: This function from the `async_to_sync` library is used to convert async methods of a class into sync methods.
-   `_decorate_all_methods_in_class([_create_new_session])`: This applies our session management decorator to all methods of the `AsyncFoo` class.
-   `(AsyncFoo)(session=None)`: This creates an instance of the `AsyncFoo` class with the decorators applied. Notice we set the session to None and not ClientSession because ClientSession should be created within an async, this is precisely where `_create_new_session` comes into play, ensuring that a new ClientSession is instantiated as part of the async function call process.

## Full view of the code

```python
import inspect
from functools import wraps
from typing import Callable, Any

import async_to_sync
from aiohttp import ClientSession


class AsyncFoo:
    def __init__(self, session: ClientSession):
        self._session: ClientSession = session

    async def run(self):
        return await self._session.get("https://www.google.com")


def _create_new_session(f: Callable[..., Any]) -> Callable[..., Any]:
    @wraps(f)
    async def func(self, *args, **kwargs):
        self._session = ClientSession()
        try:
            response = await f(self, *args, **kwargs)
            return response
        finally:
            await self._session.close()

    return func


def _decorate_all_methods_in_class(decorators):
    def apply_decorator(cls: Any) -> Any:
        for k, f in cls.__dict__.items():
            if inspect.isfunction(f) and not k.startswith("_"):
                for decorator in decorators:
                    setattr(cls, k, decorator(cls.__dict__[k]))
        return cls

    return apply_decorator


sync_foo = async_to_sync.methods(_decorate_all_methods_in_class([_create_new_session])(AsyncFoo)(session=None))
```

By using these decorators, we’ve managed to add synchronous support to our `AsyncFoo` class without duplicating code or creating separate classes. This solution showcases the power of decorators in Python for modifying class behaviors dynamically, maintaining clean and efficient codebases even as requirements evolve.

![](https://miro.medium.com/v2/resize:fit:1400/0*GityKkNAlCTmQwpE)

A lightbulb drawn on a yellow sticky note is pinned to a corkboard. Photo by [AbsolutVision](https://unsplash.com/@alterego_swiss?utm_source=medium&utm_medium=referral) on [Unsplash](https://unsplash.com/?utm_source=medium&utm_medium=referral)

## The real story behind this code

While developing the [llm-client SDK](https://github.com/uripeled2/llm-client-sdk), designed for seamless integration with generative AI large language models, I encountered a unique challenge. The SDK comprised numerous classes, similar to AsyncFoo, each containing several functions. These functions executed asynchronous requests using ClientSession. However, a few weeks into development, there was a growing demand for synchronous support. The idea of creating a multitude of mirror classes for synchronous functionality seemed daunting and maintenance-intensive. In pursuit of a more efficient solution, I envisioned an approach that would enable users to instantiate classes in a synchronous mode without modifying the existing asynchronous code. The code I developed, closely mirroring the solution presented here, effectively addressed this need. You can view the actual code implemented in the project [here](https://github.com/uripeled2/llm-client-sdk/blob/main/llm_client/sync/sync_llm_api_client_factory.py).

Connect with me on [LinkedIn](https://www.linkedin.com/in/uripeled/) or [Github](https://github.com/uripeled2).

source: https://python.plainenglish.io/mastering-advanced-decorators-in-python-a-real-life-example-97433aee11e7
