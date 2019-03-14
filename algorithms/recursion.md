### Recursion

#### What is it?
Invoke the ```same function``` with ```different inputs``` until you reach the ```base case```.

#### Important concepts:
- Function that calls itself.
- Same function with different inputs which are smaller overtime.
- Base case: ending condition.

#### Examples:
1. List all file names in a directory:
```ruby
def recur(file_name)
  entries = Dir.entries(file_name) - %w[. ..]
  entries.each do |entry|
    dir = "#{file_name}/#{entry}"

    puts entry if (File.file?(dir))
    
    if(File.directory?(dir))
      recur(dir)
    end
  end
end
```
