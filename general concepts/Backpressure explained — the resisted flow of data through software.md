# Backpressure explained — the resisted flow of data through software

Backpressure (or back pressure) is something nearly every software engineer will have to deal with at some point, and for some it’s a frequent problem. But the term itself isn’t nearly as understood and recognized as such.

In this post I’m going to elaborate on what exactly backpressure is, when it’s common, and the strategies we can use to mitigate it.

> I recently gave a talk about this at ReactiveConf: https://youtu.be/I6eZ4ZyI1Zg

## The Definition

In the software world “backpressure” is an analogy borrowed from fluid dynamics, like in automotive exhaust and house plumbing.

The [Wikipedia definition](https://en.wikipedia.org/wiki/Back_pressure):

> Resistance or force opposing the desired flow of fluid through pipes.

In the context of software, the definition could be tweaked to refer to the flow of data within software:

> Resistance or force opposing the desired **flow of data through software**.

The purpose of software is to take input data and turn it into some desired output data. That output data might be JSON from an API, it might be HTML for a webpage, or the pixels displayed on your monitor.

Backpressure is when the progress of turning that input to output is resisted in some way. In most cases that resistance is computational speed — trouble computing the output as fast as the input comes in — so that’s by far the easiest way to look at it. But other forms of backpressure can happen too: for example, if your software has to wait for the user to take some action.

> By the way, you might eventually hear someone use the word “backpressure” to actually mean something has the ability to **control or handle backpressure.**
> 
> For example, if someone says: “I made this new library with built-in backpressure…” they probably mean it somehow helps you manage backpressure, not that it actually intrinsically is the cause of it. Backpressure is not “desirable” except when it’s inescapable and you want to protect something else from receiving it.

Even with these definitions in hand, what “backpressure” really means can still be a little hazy at this point. I find many people have their “ah ha” moment after hearing some examples.

## Examples of Backpressure

## I Love Lucy: Chocolate Factory

Let’s start with an analogy. In the 50s television show “I Love Lucy” there’s an episode in which Lucy is working at a candy packaging plant. Her job is to take candy from a conveyor belt and wrap each of them in paper. Easy enough, except she quickly finds the conveyor’s speed is faster than she can handle. Hilarity ensues.

Thanks to my old co-worker **Randall Koutnik for suggesting this example years ago!**

This is a perfect example of backpressure. She actually tries two different ways of dealing with it: setting some aside to get to later (buffering), and eventually she starts eating and hiding them in her hat (dropping). However, in the case of a chocolate factory, neither of these backpressure strategies are viable. Instead, she needed them to slow down the conveyor; in other words, she needs to be able to control the producer’s speed. We’ll talk more about strategies in a bit!

## Reading and Writing Files

Now we’ll talk about software-related backpressure. The most common case is when dealing with the file system.

Writing to a file is [slower than reading](https://www.lifewire.com/what-are-read-and-write-speeds-2640236) a file. Imagine a hard drive that provides an effective read speed of 150 MB/s and a write speed of 100 MB/s. If you were to read a file into memory as fast as you can, while at the same time wrote it back to disk — again as fast as you can — you’d have to buffer 50 MB every second. That’s a growing deficit! You won’t be able to start to catch up and pay down that debt until the input file has been completely finished being read.

Now imagine doing this with a 6 GB file. By the time you’ve read the file completely, you’d have a 2 GB buffer you still need to finish writing.

```
6 GB / 150 MB = 40 seconds
150 MB - 100 MB = 50 MB deficit
50 MB x 40 = 2 GB !!!
```

That’s a lot of wasted memory. On some systems this might even exceed the amount of available memory. Or imagine this is a web server performing this operation each for multiple requests. Hopefully it’s clear this approach is not viable in a lot of cases.

Fear not, the solution is simple: only read as fast as you can write. Nearly all I/O libraries will provide abstractions to do this for you automatically, often with the concept of “streams” and “pipes”. [Node.js is a great example](https://nodejs.org/en/docs/guides/backpressuring-in-streams/).

## Server Communication

The next example is communication between servers. Today it’s very common to employ a microservice architecture where responsibilities are separated into multiple servers.

Backpressure can commonly occur in this scenario when one server is sending requests to another faster than it can process them.

If server A sends 100 rps (requests per second) to server B, but server B can only process 75 rps, you’ve got a 25 rps deficit. Server B might be falling behind because it needs to do processing or it might also need to communicate with other servers downstream.

![](https://miro.medium.com/v2/resize:fit:875/1*ZQWlVVyCANAmgUKJU9xUlw.gif)

Either way, server B needs to deal with backpressure somehow. Buffering that 25 rps deficit is one option, but if that increase remains constant it’ll soon run out of memory and fall over. Dropping requests is another option, but it’s a pretty common requirement that dropping requests is not acceptable.

The ideal option is for server B to control the rate in which server A sends requests, but again that’s not always viable — if server A is requesting on behalf of a user, you can’t always tell or control the user to slow down, but sometimes you can! Still, it’s often better to have the requesting server buffer, so you can better distribute the memory load down-stream, where the stress is, and not impact other requestors.

For example, if three different types of services (A, B, C) all make requests to the same downstream service (Z), and one of the four (A) is experiencing high load, service Z could effectively tell service A to “slow down” (control the producer) causing service A to buffer the requests. If that continued, eventually service A would run out of memory, however, the other two services (B, C) would remain up, as would the downstream service Z because it wasn’t allowing one misbehaving service to deny equal access for the others. An outage in this case might be inevitable, but we limited the scope and prevented a cascading Denial of Service. This would be a case of controlling the producer, who then buffers because they can’t control their own producer (the user). In this case _someone_ has to buffer, but _who_ is the important part.

When I worked at Netflix, this sort of backpressure was common. I talk about it in [one of my talks](https://www.youtube.com/watch?v=uODxUJ5Jwis). Ultimately, which strategy we used to control backpressure depended on the use case. Sometimes we were able to control the producer using things like [RSocket](http://rsocket.io/) and [gRPC](https://grpc.io/).

> If handling services-at-scale interests you, you’ll want to learn more about [Chaos Engineering](https://www.gremlin.com/chaos-monkey/the-origin-of-chaos-monkey/) and how you can intentionally induce these failures in production to test resiliency and failovers/fallbacks.

## Rendering UI

The final example of backpressure is rendering a UI app. Backpressure happens when you can’t render as fast as you need to. It could be as simple as trying to render a giant list, debouncing rapid keyboard events, or more complex situations like trying to display the output of a WebSocket that emits 20,000 events per second.

Because this sort of backpressure can be _very_ complex, often involving [death by a thousand cuts](https://logrocket.com/blog/death-by-a-thousand-cuts-a-checklist-for-eliminating-common-react-performance-issues/), let’s focus on the WebSocket example since it’s easier to see how it can go wrong.

![](https://miro.medium.com/v2/resize:fit:750/1*feQArAYERutZ451cMQSV6w.gif)

If a WebSocket is emitting 20k, 100k, or even 200k+ messages per second, there’s no way you’re going to be able to render each of those messages as they come in. Zero chance. So we need some sort of backpressure strategy. If we can’t [control the rate from the server](https://github.com/rsocket/rsocket-js) we’ll need to either buffer or drop on the client-side.

In the case of buffering, you could perhaps accumulate incoming messages in an array and periodically flush it on each [requestAnimationFrame](https://www.html5rocks.com/en/tutorials/speed/rendering/), rendering that list into the DOM. Alternatively, you could buffer them for some duration, like every second. If you’re appending them into an existing table, you’ll probably also want to use some form of [table virtualization](https://swizec.com/blog/build-list-virtualization/swizec/8167) because rendering 100k rows is also going to be a huge bottleneck — and a form of backpressure!

Depending on the actual number of events coming in, one of these approaches might work. Otherwise, your only other option is to “drop”: sample only a percentage of the incoming messages and filter out the others.

## Backpressure Strategies

Aside from scaling up your available compute resources, how you handle backpressure can pretty much be summed up with three possible options:

-   **Control** the producer (slow down/speed up is decided by consumer)
-   **Buffer** (accumulate incoming data spikes temporarily)
-   **Drop** (sample a percentage of the incoming data)

> Technically there’s a fourth option — ignore the backpressure — which, to be honest, is not a bad idea if the backpressure isn’t causing critical issues. Introducing more complexity comes at a cost too.

**Controlling** the producer is by far the best option. When it’s actually possible, it has no real tradeoffs to speak of, other than the overhead of the control mechanism itself. You don’t need to use excess memory buffering things on your end, and you don’t need to be lossy and drop data.

Unfortunately, of course controlling the producer isn’t always possible. The most clear case is when dealing with user input. Try as we might, it’s not easy to control our users!

**Buffering** is what most people will reach for next. However, always keep in mind that buffering is dangerous if unbounded — meaning you don’t have a size or time limit to the buffer. Unbounded buffers are a common source of memory crashes in servers.

When used, always ask yourself: is it possible that the rate the buffer grows will ever exceed the rate it is drained for any appreciable amount of time? Refer back to the Server Communication example above for an example of this.

In fact, some people advocate that buffers should **never** be left unbounded. I’m not that strict, but I would say that it is often better to start dropping than to fall over completely (run out of memory).

**Dropping** is the last strategy, and as mentioned it’s often combined with buffering too. Sampling based on time is the most common, e.g. 10% of data per second.

## Choosing a Strategy

When deciding which approach to take, the User Experience (UX) can often help guide us. Is it a good UX updating a table 100k per second, even if we could? Probably not. Would the user rather see a sample updated per second? Or perhaps rearchitect things so that the stream is sent to a database that can be read by the user as-needed, more slowly? Only your unique circumstances can tell, but just remember the UX can guide you!

It’s very common for developers to spend a lot of time tuning performance, only to end up with a bad UX, when the good UX wouldn’t have had the performance issue to begin with.

## Code for Backpressure

I wanted to keep most of this post agnostic of the language/platform you code for, since backpressure is a problem we all have to deal with. **_But_**, there are some patterns you’ll see across ecosystems and I imagine many of my readers will be Web folk.

The term “stream” is unfortunately ambiguous. Elaborating on them all will have to be saved for another post, but in summary:

## Pull

With pull-based streams the consumer controls the producer. Usually it’s a 1:1 request → response style, but there are patterns for `request(n)` as well, like [Flowables](https://github.com/ReactiveX/RxJava/wiki/Backpressure-(2.0)) in RxJava. Some other pull-based streams are [Node.js Streams](https://nodejs.org/en/docs/guides/backpressuring-in-streams/), [Web Streams](https://developer.mozilla.org/en-US/docs/Web/API/Streams_API), and [Async Iterators](http://2ality.com/2016/10/asynchronous-iteration.html) — [IxJS is a great async iterator library](https://github.com/ReactiveX/IxJS) for you JS folks, there are also ports in other languages).

Depending on who you talk to, many of these are considered hybrid “push-pull” if the response is pushed to you asynchronously. Some consider normal synchronous [iterators](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Iterators_and_Generators#Iterators) traditional “pull” streams, some make no distinction between asynchronous/synchronous call them both just “pull”.

**Push**

With push-based streams, the producer is in control and pushes data to the consumer when it’s available. Often push-streams are used when dealing with user input; they model the producer accurately since you can’t control the user. There are lots of libraries, but by far the most popular are implementations of the Reactive Extensions aka Rx. There’s [RxJS](https://github.com/ReactiveX/rxjs/), [RxJava](https://github.com/ReactiveX/RxJava), and probably an [RxYourFavoriteLanguage](https://github.com/ReactiveX).

## Summary

When I first heard the term “backpressure”, I’ll admit I was intimidated. It felt like jargon being used to make the person sound smart — and unfortunately, sometimes it is. But in truth it is a real thing, and knowing about it and how to combat it can empower you to tackle even bigger problems and scale. From a small thing like dealing with rapid mouse moves to managing thousands of servers, backpressure is everywhere.

> Did this post adequately explain backpressure? Do you have feedback? Let me know in the comments or on [Twitter: @\_jayphelps](https://twitter.com/_jayphelps)
> 
> Thanks to [Estèphe](https://medium.com/u/29d81e040922?source=post_page-----2350b3e77ce7--------------------------------) in the comments for the reminder about scaling as a possible solution to backpressure!

source: https://medium.com/@jayphelps/backpressure-explained-the-flow-of-data-through-software-2350b3e77ce7
