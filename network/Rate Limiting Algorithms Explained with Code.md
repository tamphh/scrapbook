Imagine you’re running an online service that has suddenly gone **viral**.

Users from around the world are flooding your servers with requests.

But as more people use it, your system **slows down**.

Some users experience **timeouts**, while others are unable to access the service altogether.

In the midst of this chaos, you notice a few users—or **bots**—are making thousands of requests per minute, hogging resources and degrading the experience for everyone else.

To avoid this, you can **limit** such users from overusing or exploiting you service.

[

![](https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fe650d4db-f851-4602-a0c2-86c88f921a8f_318x384.png)

](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fe650d4db-f851-4602-a0c2-86c88f921a8f_318x384.png)

This is where **rate limiting** can help.

Rate limiting helps protects services from being overwhelmed by too many requests from a single user or client.

In this article we will dive into 5 of the most common rate limit limiting algorithms, their pros and cons and learn how to implement them in code.

### 1\. Token Bucket

[

![](https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fcea82243-07a3-48bc-a16b-1540cd175092_1204x1046.png)

](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fcea82243-07a3-48bc-a16b-1540cd175092_1204x1046.png)

The Token Bucket algorithm is one of the most popular and widely used rate limiting approaches due to its simplicity and effectiveness.

#### **How It Works**:

-   Imagine a bucket that holds tokens.
    
-   The bucket has a maximum capacity of tokens.
    
-   Tokens are added to the bucket at a fixed rate (e.g., 10 tokens per second).
    
-   When a request arrives, it must obtain a token from the bucket to proceed.
    
-   If there are enough tokens, the request is allowed and tokens are removed.
    
-   If there aren't enough tokens, the request is dropped.
    

[

![](https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F99b5890f-d100-416a-9948-b704daba4d47_3568x3068.png)

](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F99b5890f-d100-416a-9948-b704daba4d47_3568x3068.png)

Code Link: **[Python](https://github.com/ashishps1/awesome-system-design-resources/blob/main/implementations/python/rate_limiting/token_bucket.py), [Java](https://github.com/ashishps1/awesome-system-design-resources/blob/main/implementations/java/rate_limiting/TokenBucket.java)**

#### Pros:

-   Relatively straightforward to implement and understand.
    
-   Allows bursts of requests up to the bucket's capacity, accommodating short-term spikes.
    

#### Cons:

-   The memory usage scales with the number of users if implemented per-user.
    
-   It doesn’t guarantee a perfectly smooth rate of requests.
    

### 2\. Leaky Bucket

[

![](https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F79d555be-f951-4086-9fad-84884f21f517_1088x724.png)

](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F79d555be-f951-4086-9fad-84884f21f517_1088x724.png)

The Leaky Bucket algorithm is similar to Token Bucket but focuses on smoothing out bursty traffic.

#### How it works:

1.  Imagine a bucket with a small hole in the bottom.
    
2.  Requests enter the bucket from the top.
    
3.  The bucket processes ("leaks") requests at a constant rate through the hole.
    
4.  If the bucket is full, new requests are discarded.
    

[

![](https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fd07bb981-33a2-48f1-960b-8fb94f7220a4_3532x3516.png)

](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fd07bb981-33a2-48f1-960b-8fb94f7220a4_3532x3516.png)

Code Link: **[Python](https://github.com/ashishps1/awesome-system-design-resources/blob/main/implementations/python/rate_limiting/leaky_bucket.py), [Java](https://github.com/ashishps1/awesome-system-design-resources/blob/main/implementations/java/rate_limiting/LeakyBucket.java)**

#### Pros:

-   Processes requests at a steady rate, preventing sudden bursts from overwhelming the system.
    
-   Provides a consistent and predictable rate of processing requests.
    

#### Cons:

-   Does not handle sudden bursts of requests well; excess requests are immediately dropped.
    
-   Slightly more complex to implement compared to Token Bucket.
    

### 3\. Fixed Window Counter

[

![](https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F340645cf-8953-4f10-b7da-cdbeea10e280_1364x872.png)

](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F340645cf-8953-4f10-b7da-cdbeea10e280_1364x872.png)

The Fixed Window Counter algorithm divides time into fixed windows and counts requests in each window.

#### How it works:

1.  Time is divided into fixed windows (e.g., 1-minute intervals).
    
2.  Each window has a counter that starts at zero.
    
3.  New requests increment the counter for the current window.
    
4.  If the counter exceeds the limit, requests are denied until the next window.
    

[

![](https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F643a169a-b6c9-4130-b68e-3fe805df4865_3532x3248.png)

](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F643a169a-b6c9-4130-b68e-3fe805df4865_3532x3248.png)

Code Link: **[Python](https://github.com/ashishps1/awesome-system-design-resources/blob/main/implementations/python/rate_limiting/fixed_window_counter.py), [Java](https://github.com/ashishps1/awesome-system-design-resources/blob/main/implementations/java/rate_limiting/FixedWindowCounter.java)**

#### Pros:

-   Easy to implement and understand.
    
-   Provides clear and easy-to-understand rate limits for each time window.
    

#### Cons:

-   Does not handle bursts of requests at the boundary of windows well. Can allow twice the rate of requests at the edges of windows.
    

### 4\. Sliding Window Log

[

![](https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F8704b8f0-5644-4852-a8c7-bc31a2ac1682_1076x722.png)

](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F8704b8f0-5644-4852-a8c7-bc31a2ac1682_1076x722.png)

The Sliding Window Log algorithm keeps a log of timestamps for each request and uses this to determine if a new request should be allowed.

#### How it works:

1.  Keep a log of request timestamps.
    
2.  When a new request comes in, remove all entries older than the window size.
    
3.  Count the remaining entries.
    
4.  If the count is less than the limit, allow the request and add its timestamp to the log.
    
5.  If the count exceeds the limit, request is denied.
    

[

![](https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F1d45128c-2c85-4158-8731-f7c3893ec994_3532x3068.png)

](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F1d45128c-2c85-4158-8731-f7c3893ec994_3532x3068.png)

Code Link: **[Python](https://github.com/ashishps1/awesome-system-design-resources/blob/main/implementations/python/rate_limiting/sliding_window_log.py), [Java](https://github.com/ashishps1/awesome-system-design-resources/blob/main/implementations/java/rate_limiting/SlidingWindowLog.java)**

#### Pros:

-   Very accurate, no rough edges between windows.
    
-   Works well for low-volume APIs.
    

#### Cons:

-   Can be memory-intensive for high-volume APIs.
    
-   Requires storing and searching through timestamps.
    

### 5\. Sliding Window Counter

[

![](https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fb768707a-ba4d-4ab4-a15c-e1b1bd2f68c1_1086x764.png)

](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fb768707a-ba4d-4ab4-a15c-e1b1bd2f68c1_1086x764.png)

This algorithm combines the Fixed Window Counter and Sliding Window Log approaches for a more accurate and efficient solution.

Instead of keeping track of every single request’s timestamp as the sliding log does, it focus on the number of requests from the last window.

So, if you are in 75% of the current window, 25% of the weight would come from the previous window, and the rest from the current one:

```
weight = (100 - 75)% * lastWindowRequests + currentWindowRequests
```

Now, when a new request comes, you add one to that weight (weight + 1). If this new total crosses our set limit, we have to reject the request.

#### How it works:

1.  Keep track of request count for the current and previous window.
    
2.  Calculate the weighted sum of requests based on the overlap with the sliding window.
    
3.  If the weighted sum is less than the limit, allow the request.
    

[

![](https://substackcdn.com/image/fetch/w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fa5bf707c-52e2-49ed-a9b6-c8deb4bfd409_3680x3876.png)

](https://substackcdn.com/image/fetch/f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fa5bf707c-52e2-49ed-a9b6-c8deb4bfd409_3680x3876.png)

Code Link: **[Python](https://github.com/ashishps1/awesome-system-design-resources/blob/main/implementations/python/rate_limiting/sliding_window_counter.py), [Java](https://github.com/ashishps1/awesome-system-design-resources/blob/main/implementations/java/rate_limiting/SlidingWindowCounter.java)**

#### Pros:

-   More accurate than Fixed Window Counter.
    
-   More memory-efficient than Sliding Window Log.
    
-   Smooths out edges between windows.
    

#### Cons:

-   Slightly more complex to implement.
    

When implementing rate limiting, consider factors such as the scale of your system, the nature of your traffic patterns, and the granularity of control you need.

Lastly, always communicate your rate limits clearly to your API users, preferably through response headers, so they can implement appropriate retry and backoff strategies in their clients.

Thank you so much for reading.

If you found it valuable, hit a like ❤️ and consider subscribing for more such content every week.

If you have any questions or suggestions, leave a comment.

This post is public so feel free to share it.

[Share](https://blog.algomaster.io/p/rate-limiting-algorithms-explained-with-code?utm_source=substack&utm_medium=email&utm_content=share&action=share)

Checkout my [Youtube channel](https://www.youtube.com/@ashishps_1/videos) for more in-depth content.

Follow me on [LinkedIn](https://www.linkedin.com/in/ashishps1/) and [X](https://twitter.com/ashishps_1) to stay updated.

Checkout my [GitHub repositories](https://github.com/ashishps1) for free interview preparation resources.

I hope you have a lovely day!

See you soon,

Ashish

source: https://blog.algomaster.io/p/rate-limiting-algorithms-explained-with-code?ref=dailydev
