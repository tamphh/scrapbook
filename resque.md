Get numbers in queues

```ruby
Resque.info   
#=> {:pending=>0, :processed=>346, :queues=>1, :workers=>1, :working=>1,
:failed=>346,
:servers=>["...."],
:environment=>"qa"}

```

Get number in particular queue

```ruby
Resque.size('queue_name')
```


Flush redis

```ruby
#will erase entire redis
port = 10000
$redis = Redis.new(:port => port)
$redis.flushall

```

http://www.rubydoc.info/gems/resque/Resque/Failure


Show what's going on:

```ruby
Resque.info
```

Show last 10 failed jobs:

```ruby
Resque::Failure.all(0,10)
```

Delete all failed jobs:

```ruby
Resque::Failure.clear
```


```ruby
Resque.queues.each { |q| Resque.redis.del "queue:#{q}" }
```

source: http://www.runshell.com/2014/07/handy-resque-commands.html


# Retriggering failed resque jobs

```ruby
# reque 800..last-job
800.upto(Resque::Failure.count - 1) .each { |i| Resque::Failure.requeue(i) }

# Requeue all jobs in the failed queue
(Resque::Failure.count-1).downto(0).each { |i|
Resque::Failure.requeue(i) }

# Clear the entire failed queue
Resque::Failure.clear

# Remove individual from failed
Resque::Failure.remove(1196)


# Retriger jobs in spec queues
Resque::Failure.all(0, (Resque::Failure.count)).each_with_index do |r, i|
  resq_position = i+1

  if r.fetch("queue").in?(['store_address_data', 'store_work_view_data'])
    Resque::Failure.requeue(resq_position)
  end
end; true



```

https://ariejan.net/2010/08/23/resque-how-to-requeue-failed-jobs/
