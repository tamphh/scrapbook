## Recursion
### What is it?
Invoke the ```same function``` with ```different inputs``` until you reach the ```base case```.

### Important concepts:
- Function that calls itself.
- Same function with different inputs which are smaller overtime.
- Base case: ending condition.

### Examples:
#### 1. Count down:
```ruby
def count_down(number)
  return if number < 0 # base case
  
  puts number
  
  count_down(number - 1) # call itself with different input
end
```

#### 2. List all file names in a directory:
```ruby
# In this sample, base case is the limit number of files & directories
def recur(file_name)
  entries = Dir.entries(file_name) - %w[. ..]
  entries.each do |entry|
    dir = "#{file_name}/#{entry}"

    puts entry if File.file?(dir)
    
    recur(dir) if File.directory?(dir) # call itself with different input
  end
end
```

#### 3. Array playgroud:
```ruby
# append [], 2 => [2, 1, 0]
# append [], 3 => [3, 2, 1, 0]
def append(ary, n)
  return ary if n < 0 # base case
  ary << n
  return append(ary, n - 1) # call itself with different input
end

```
