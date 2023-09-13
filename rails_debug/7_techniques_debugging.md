![7 common techniques to improve your debugging skills](https://www.fastruby.io/blog/assets/images/header/7-common-techniques-to-improve-your-debugging-skills.jpg "7 common techniques to improve your debugging skills")

When we work on Rails upgrades, most of the time we have to solve issues after updating the gems. These problems can go from simple and straightforward to really complex and hard to debug. Here we will discuss different skills and techniques that we use to complete the upgrade.

## Basic things which you should always do

1.  Ask yourself and others simple or stupid questions. Try to make sure you know what you are fixing.
2.  Take a close look at an error log or stack trace.
3.  If you are not sure how or where to start, add debug breakpoints or `puts` statements in the code. This will help you understand the code workflow.
4.  Write down your understanding or have a `Rubber duck conversation`. (The idea is that when a programmer needs to debug their code, they should explain the program line-by-line to a rubber duck. Often, the act of explaining the problem step by step will cause the solution to present itself)
5.  Pair with someone and discuss your findings.
6.  Check documentation for the issues you are having.
7.  Take a break :) and divert your focus temporarily to something else. Then come back and follow the above steps.

Most of the techniques here are valid for any Ruby applications, but some are specific to Ruby on Rails applications.

We will use [Points opens a new window](https://github.com/fastruby/points "Opens a new window") as an example for all the different techniques we are going to discuss here, so that you can try all these techniques yourself by running the application locally.

### 1\. `source_location` - where is this method coming from

Sometimes you need to find the source code of a method and it’s not trivial to figure out where it’s defined. Let’s use the [projects\_controller opens a new window](https://github.com/fastruby/points/blob/main/app/controllers/projects_controller.rb#L51 "Opens a new window") controller as an example. Imagine we don’t know where `clone_params` is defined. We can start a debug session right before the method is used and check its source location using the `source_location` method in the object returned by `method(:clone_params)`:

```
[47, 56] in /Users/myuser/Documents/ombulabs/points/app/controllers/projects_controller.rb
  47:   end
  48:
  49:   def clone
  50:     original = Project.includes(stories: :estimates).find(params[:id])
  51:     byebug
=> 52:     clone = Project.create(clone_params)
  53:     original.clone_stories_into(clone)
  54:     if clone.parent.nil? && original.projects
  55:       original.clone_projects_into(clone, only: params[:sub_project_ids])
  56:     end
(byebug) method(:clone_params).source_location
["/Users/myuser/Documents/ombulabs/points/app/controllers/projects_controller.rb", 118]
(byebug) self.method(:clone_params).source_location
["/Users/myuser/Documents/ombulabs/points/app/controllers/projects_controller.rb", 118]
(byebug)
```

### 2\. Getting the Current Backtrace

There are two ways to get the current backtrace in Ruby:

1.  `Thread.current.backtrace` returns the entire backtrace up to and including the current method.
2.  `caller` returns the backtrace up to but NOT including the current method.

### A. `caller` - Who called this method

Many times it might be tricky to find the caller of the method. It could be getting called using meta programming, background jobs, controller, gem, engine, callbacks, and more. If you want to find out the `caller` of the method `clone_params`, add `puts caller` in the method to see who is calling it.

Let’s take this simple method from the [projects\_controller.rb opens a new window](https://github.com/fastruby/points/blob/main/app/controllers/projects_controller.rb#L117 "Opens a new window") file:

```
def clone_params
 puts caller
 params.require(:project).permit(:title, :parent_id)
end


OUTPUT >>


/Users/myuser/Documents/ombulabs/points/app/controllers/projects_controller.rb:51:in `clone'
/Users/myuser/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/actionpack-7.0.4.3/lib/action_controller/metal/basic_implicit_render.rb:6:in `send_action'
/Users/myuser/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/actionpack-7.0.4.3/lib/abstract_controller/base.rb:215:in `process_action'
/Users/myuser/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/actionpack-7.0.4.3/lib/action_controller/metal/rendering.rb:53:in `process_action'
/Users/myuser/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/actionpack-7.0.4.3/lib/abstract_controller/callbacks.rb:234:in `block in process_action'
/Users/myuser/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.3/lib/active_support/callbacks.rb:118:in `block in run_callbacks'
/Users/myuser/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/actiontext-7.0.4.3/lib/action_text/rendering.rb:20:in `with_renderer'
/Users/myuser/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/actiontext-7.0.4.3/lib/action_text/engine.rb:69:in `block (4 levels) in <class:Engine>'
/Users/myuser/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.3/lib/active_support/callbacks.rb:127:in `instance_exec'
```

### B. `Thread.current.backtrace`

This command is helpful when you do not have enough information about the error. Imagine, for example, that you are rescuing an exception when a record is not found. If you want to get more details about the current call stack, you can use `Thread.current.backtrace`.

```
def find_project
 begin
   @project = Project.find!(params[:project_id])
 rescue
   p Thread.current.backtrace
 end
end


OUTPUT >>


["/Users/myuser/Documents/ombulabs/points/app/controllers/projects_controller.rb:113:in `backtrace'", "/Users/ashwini/Documents/ombulabs/points/app/controllers/projects_controller.rb:113:in `rescue in find_project'", "/Users/ashwini/Documents/ombulabs/points/app/controllers/projects_controller.rb:109:in `find_project'", "/Users/ashwini/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.3/lib/active_support/callbacks.rb:400:in `block in make_lambda'", "/Users/ashwini/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.3/lib/active_support/callbacks.rb:180:in `block (2 levels) in halting_and_conditional'", "/Users/ashwini/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/actionpack-7.0.4.3/lib/abstract_controller/callbacks.rb:34:in `block (2 levels) in <module:Callbacks>'", "/Users/ashwini/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.3/lib/active_support/callbacks.rb:181:in `block in halting_and_conditional'", "/Users/ashwini/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.3/lib/active_support/callbacks.rb:595:in `block in invoke_before'"...]
```

### 3\. `step` and `next` debug methods

The difference between `next` and `step` is that step stops at the next line of code executed, doing just a single step, while `next` moves to the next line without descending inside methods.

For example: We want to see what’s happening when we hit the method `CSV.parse` in our code. Let’s add the debugger before the method call and check. Here you can see how we have used the `next` and `step` methods to reach the `parse` method. We have used `step` to enter into `CSV.parse` and then used `next` to follow through the different calls.

```
[63, 72] in /Users/myuser/Documents/ombulabs/points/app/controllers/stories_controller.rb
  63:       flash[:error] = "Invalid File: Must be CSV"
  64:       redirect_to(@project) && return
  65:     end
  66:     file = begin
  67:       byebug
=> 68:       CSV.parse(params[:file].read, headers: true)
  69:     rescue
  70:       []
  71:     end
  72:     if file.empty?
(byebug) step


[1220, 1229] in /Users/myuser/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/actionpack-7.0.4.3/lib/action_controller/metal/strong_parameters.rb
  1220:   # for more information.
  1221:   module StrongParameters
  1222:     # Returns a new ActionController::Parameters object that
  1223:     # has been instantiated with the <tt>request.parameters</tt>.
  1224:     def params
=> 1225:       @_params ||= begin
  1226:         context = {
  1227:           controller: self.class.name,
  1228:           action: action_name,
  1229:           request: request,
(byebug) next


[639, 648] in /Users/myuser/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/actionpack-7.0.4.3/lib/action_controller/metal/strong_parameters.rb
  639:     #
  640:     #   params = ActionController::Parameters.new(person: { name: "Francesco" })
  641:     #   params[:person] # => #<ActionController::Parameters {"name"=>"Francesco"} permitted: false>
  642:     #   params[:none]   # => nil
  643:     def [](key)
=> 644:       convert_hashes_to_parameters(key, @parameters[key])
  645:     end
  646:
  647:     # Assigns a value to a given +key+. The given key may still get filtered out
  648:     # when +permit+ is called.
(byebug) next


[44, 53] in /Users/myuser/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/actionpack-7.0.4.3/lib/action_dispatch/http/upload.rb
  44:         @headers           = hash[:head]
  45:       end
  46:
  47:       # Shortcut for +tempfile.read+.
  48:       def read(length = nil, buffer = nil)
=> 49:         @tempfile.read(length, buffer)
  50:       end
  51:
  52:       # Shortcut for +tempfile.open+.
  53:       def open
(byebug) next


[1727, 1736] in /Users/myuser/.rbenv/versions/3.2.2/lib/ruby/3.2.0/csv.rb
  1727:     #
  1728:     # Raises an exception if the argument is not a \String object or \IO object:
  1729:     #   # Raises NoMethodError (undefined method `close' for :foo:Symbol)
  1730:     #   CSV.parse(:foo)
  1731:     def parse(str, **options, &block)
=> 1732:       csv = new(str, **options)
  1733:
  1734:       return csv.each(&block) if block_given?
  1735:
  1736:       # slurp contents, if no block is given
(byebug) next


[1729, 1738] in /Users/myuser/.rbenv/versions/3.2.2/lib/ruby/3.2.0/csv.rb
  1729:     #   # Raises NoMethodError (undefined method `close' for :foo:Symbol)
  1730:     #   CSV.parse(:foo)
  1731:     def parse(str, **options, &block)
  1732:       csv = new(str, **options)
  1733:
=> 1734:       return csv.each(&block) if block_given?
  1735:
  1736:       # slurp contents, if no block is given
  1737:       begin
  1738:         csv.read
```

### 4\. `Monkey Patching`

Did you know that you can open any class in Ruby and modify it? Yes, we can open any class of any gem or library to debug.

In the previous example, we showed you how to get into the `CSV.parse` method using `next/step`, but if you want to avoid those steps (sometimes there can be many method calls in between) you can open the `CSV` class and modify it.

Let’s see how.

Imagine you have a problem when parsing the imported CSV file in [this controller action. opens a new window](https://github.com/fastruby/points/blob/main/app/controllers/stories_controller.rb#L67 "Opens a new window")

Let’s start finding out where the `CSV.parse` method is defined. Add a `byebug` call and then use `source_location`.

```
(byebug)  CSV.method(:parse).source_location
["/Users/myuser/.rbenv/versions/3.2.2/lib/ruby/3.2.0/csv.rb", 1731]
```

We can monkeypatch the `parse` class method of the CSV module like this:

Take the code from [csv.rb opens a new window](https://github.com/ruby/ruby/blob/v3_2_2/lib/csv.rb#L1731 "Opens a new window") , create a file in your `lib` folder with the name, let’s say, `csv.rb`, and paste the following code in it. Now you can debug Ruby’s `CSV.parse` method, check different params, etc.

```
class CSV
 def self.parse(str, **options, &block)
   byebug
   csv = new(str, **options)


   return csv.each(&block) if block_given?


   # slurp contents, if no block is given
   begin
     csv.read
   ensure
     csv.close
   end
 end
end
```

### 5\. `methods.grep` to search for a method in an object

Sometimes you want to check if an object has a particular method but you don’t know the exact method name, only part of it. You can use the `grep` command and search for the method you want using a regular expression.

For example, given an object instance of the `Project` class, what are the different methods related to stories:

```
(byebug) Project.new.methods.grep /stories/
[:clone_stories_into, :autosave_associated_records_for_stories, :validate_associated_records_for_stories, :stories, :stories=]
```

### 6.`to_sql` to see what query ActiveRecord will generate

Sometimes it is hard to understand complex joins between different models. Or maybe you are not getting the result you are expecting. In such cases, it is always a good idea to see what the plain SQL query ActiveRecord is generating looks like. `to_sql` will print out the full query.

```
(byebug) Project.joins(:stories).where(stories: { title: "Story #0"}).to_sql
"SELECT \"projects\".* FROM \"projects\" INNER JOIN \"stories\" ON \"stories\".\"project_id\" = \"projects\".\"id\" WHERE \"stories\".\"title\" = 'Story #0'"
```

### 7\. `reload` ActiveRecord objects

Sometimes you save an ActiveRecord object in one place and you still see the old attributes in another place. Try reloading that object to make sure that the record in memory is in sync with the database. The `reload` method is defined by ActiveRecord; it can be used in any object instance of the `ActiveRecord::Base` class.

These are 7 strategies you can use to debug Rails applications. There are some more strategies explained in [this Rails Guide opens a new window](https://guides.rubyonrails.org/debugging_rails_applications.html "Opens a new window") .

## Conclusion

I hope that you found this article interesting and that you now know more about different debugging techniques we use while upgrading your app. If you are interested in getting an action plan to upgrade your Ruby or Rails application, [send us a message! opens a new window](https://www.fastruby.io/#contactus "Opens a new window") 🚀

Happy Learning!

source: https://www.fastruby.io/blog/how-to-improve-debugging-skills-in-rails.html
