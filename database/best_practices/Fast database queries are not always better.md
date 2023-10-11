# Fast database queries are not always better
You probably think fast database queries are good. You also probably think slow database queries are bad. On top of all of these "thinks" you have about database queries - there is a certain Laravel method that, if you have seen it, you probably think you understand…but there is a chance you don’t.

The last one is likely my fault; I am sorry.

Let’s challenge your thinking on queries and see if we can’t clear up this Laravel function mess I have put us in.

## Are slow database queries bad?

Some queries are just inherently slow and as optimized as they are gonna get. That is fine, but...

I think we can agree that slow queries are generally bad. Maybe "bad" isn’t the right word. Perhaps "not ideal" is better.

Slow database queries are not ideal. Yea. That's better.

But how do we even define "slow"?

We could compare two queries, e.g., a 50ms query verses a 2s query. In this case the 2 second query is slow (without knowing any context about the query).

Alternatively, instead of comparing two queries, we might explicitly define what a "slow" query is within our system by setting an explicit threshold via the [Slow Query Log](https://dev.mysql.com/doc/refman/8.0/en/slow-query-log.html) feature of the database. This allows us to operationalise what we consider a slow query.

Why don’t we set our imaginary slow query threshold to 1 second. Anything over 1 second we will classify as slow, for the purpose of the post.

Our slow query log will now record queries over 1 second. If the logs are filling up, we know we have slow queries and can try to address them.

Well that wasn’t all too exciting. So let’s talk about fast database queries…

## Are fast queries good?

Are they? What makes them good? In what context are we talking?

I’d have a guess and say you feel they are good because they indicate your application is fast, at least when it comes to querying the database.

In isolation: fast database queries are good.

But I don't deal with queries in isolation. I work on web apps that have rich interactions with potentially multiple queries happening within a single HTTP request lifecycle, queued job, or artisan command.

If we were to use comparison as our measure again: a HTTP request that queries the database for 5ms is better than a HTTP request that queries the database for 1.5 seconds, right?

I think it is, in regards to resource usage at least.

What if I make a HTTP request and there are no logs in my slow query log, is that good?

I don’t think so. I don’t think it’s bad, but I don’t think it’s evidence of "good" either.

After all, what information do we actually have with an empty slow query log?

We know that the HTTP request did not perform any queries over 1 second. This _sounds_ good, but it isn’t enough information to work with.

What if our HTTP request executed the following code. Forgive the extreme example.

```php
use App\Models\User;

$endAt = now()->addSeconds(20);

while ($endAt->isFuture()) {
    User::first();
}
```

The above code executes a very fast database query, however it executes the query in a non-stop loop for 20 seconds. Of course this is a contrived example, but I've certainly worked in applications where, for example, checking feature flags made hundreds, and sometimes thousands, of "fast" database queries throughout a single HTTP request.

If the above code was executed within a HTTP request to my application, there are a few facts that reveal themselves:

1.  I am a psychopath.
2.  My slow query log will be empty.

These queries are fast; These queries are not _good_.

So fast queries are not indicative of "good" in this particular context. The slow query log only goes so far.

What I really want to do, in order to make my HTTP requests fast, is to spend less time in the database for my _overall_ request. I care about the "cumulative query time" for the request.

If I make one 2 second query or four 0.5 second queries, they both make my HTTP request slower by 2 seconds and, from an end-user perspective, are both just as slow as each other.

So what can we do? Well, now I'm gonna reach for my sharp hammer: Laravel.

## Measuring query time with Laravel

I’m gonna show you a thing. This isn’t _the_ thing. This is _a_ thing, and a thing to cover, but it isn’t _the_ thing. So I’ll try and be brief.

Laravel has a way to listen for queries and check their duration. We could, for example, emulate the slow query log with something like the following:

```php
use Illuminate\Database\Events\QueryExecuted;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Log;

Event::listen(QueryExecuted, function (QueryExecuted $event) {
    if ($event->time > 1000) {
        Log::info('Slow query detected.', [
            // ...
        ]);
    }
});
```

If any individual query made by Laravel is over the 1 second threshold it will log `"Slow query detected."` to the application log. If 5 queries in a single HTTP request all take over 1 second it will log this message 5 times.

This does not give us anything _new_ and moving it to Laravel is fine, but not ideal.

But knowing this technique is relevant to help us differentiate what we are about to talk about.

## Measuring cumulative query time with Laravel

A little while ago I added a method to Laravel. You might have seen this method:

```php
use Illuminate\Database\Connection;
use Illuminate\Support\Facades\DB;

DB::whenQueryingForLongerThan(1000, function (Connection $connection) {
    Log::info('Queries collectively took longer than 1 second.', [
        // ...
    ]);
});
```

You might be forgiven for assuming that this handler and the previous query log emulation example were the same, i.e., if a query takes longer than 1 second to execute than the provided closure is called.

You would be forgiven because multiple people have told me they thought that is what it did.

But they are not the same. The first event listener example only considers a single query in isolation, while this new handler considers the context of the entire HTTP request.

To show the difference, let’s register both of these in our imaginary application’s service provider. We’ll continue to use 1 second for our logging threshold.

```php
use Illuminate\Database\Connection;
use Illuminate\Database\Events\QueryExecuted;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Request;

/*
 * Log when any query exceeds one second in duration.
 */
Event::listen(QueryExecuted, function (QueryExecuted $event) {
    if ($event->time > 1000) {
       Log::info('Query took longer than 1 second.', [
           // ...
       ]);
    }
});

/*
 * Log when all queries collectivly exceed one second in duration.
 */
DB::whenQueryingForLongerThan(1000, function (Connection $connection) {
    Log::info('Queries collectively took longer than 1 second.', [
        // ...
    ]);
});
```

Then we will make a HTTP request to the endpoint with our terrible code again. I've duplicated it here for your personal pain and suffering - and as a friendly reminder.

```php
use App\Models\User;

$endAt = now()->addSeconds(20);

while ($endAt->isFuture()) {
    User::first();
}
```

Now something interesting will happen when this HTTP request is finished:

1.  My slow query log will be empty.
2.  Our application’s log will not contain any `"Slow query detected."` entries
3.  Our application log will, however, contain a single `"Queries collectively took longer than 1 second."` entry.

This is because the `whenQueryingForLongerThan` feature will keep track of _all queries_ made during a single HTTP request lifecycle. If many fast queries are made that, when added together, take longer than one second the closure will be called and it will only ever be called _once_ per HTTP request lifecycle.

This allows us to detect and log when many fast queries cause our HTTP requests to be slow 🎉

See! Fast queries can be bad!

This feature doesn’t just work for HTTP requests. It also works for queued jobs, where the closure is called once per job lifecycle.

It’s pretty neat, but I always felt it needed a better name to make it more obvious how it deviates from the alternative `QueryExecuted` event listener set up.

So that’s what this post is. This post is, in its entirety, the new method name.

Remember that none of this is a replacement for the database’s slow query log. The database's slow query log is an important tool to dive into and learn about.

> Fun fact: the MySQL slow query log limit is 365 days. It’s like they knew I might be crafting queries 😆

## Further reading

-   [`DB::whenQueryingForLongerThan` documentation](https://laravel.com/docs/10.x/database#monitoring-cumulative-query-time)
-   [MySQL slow query log documentation](https://dev.mysql.com/doc/refman/en/slow-query-log.html)
