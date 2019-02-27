# Includes
```participant``` belongs to ```comment_thread``` which has one ```last_comment```, and polymorphic with ```source_type```, ```source_id```
```ruby
def scope
  Participant
    .where(receiver_id: receiver.id)
    .joins(:comment_thread)
    .includes(comment_thread: [:last_comment, :source])
end
```

# Directly execute sql
```ruby
ActiveRecord::Base.establish_connection
ActiveRecord::Base.connection.execute('select * from ...')
```

# Scopes and Arel tricks
```ruby
scope :visible, where("hidden != ?", true)
scope :published, lambda { where("published_at <= ?", Time.zone.now) }
scope :recent, visible.published.order("published_at desc")
scope :desc_order, order(created_at: :desc)

#bad
has_one :custom_form, -> { order('created_at DESC') }, class_name: CustomForm
# SELECT ORDER BY created_at DESC LIMIT 

#good
has_one :custom_form, -> { order(created_at: :desc) }, class_name: CustomForm
# SELECT .... ORDER BY "custom_forms"."created_at" DESC LIMIT 1
```
**Complex scope example**
```ruby
class Document
  scope :with_latest_super_owner, lambda{ |o|
    raise "must be client or user instance" unless [User, Client].include?(o.class)
    joins(:document_versions, document_creator: :document_creator_ownerships).
    where(document_creator_ownerships: {owner_type: o.class.model_name, owner_id: o.id}).
    where(document_versions: {latest: true}).group('documents.id')
  }
end
# it can get kinda complex :)
```

# Find duplicate email records with Rails
Rails + SQL do the heavy lifting
```ruby
User.find_by_sql("SELECT email FROM users GROUP BY email HAVING COUNT(email) > 1;")
```
Ruby/Rails doing all the heavy lifting solution:
```ruby
# occurences of emails
email_counts = User.pluck(:email).each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }.select { |k,v| v >1 }
puts email_counts

# uniq emails
puts email_counts.map{|k,v| k}.uniq


# all together
User.pluck(:email).each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }.select { |k,v| v >1 }.map{|k,v| k}.uniq
```

# Aggregations
**Get receiver who has most cheers.**

Result: *receiver_id* paired with *cheers_count*
```ruby
receiver_id, cheers_count = cheers.group(:receiver_id).count.max_by { |(_receiver_id, total_cheer)| total_cheer }
```
Source
- http://www.rubycuts.com/developer-resources/ruby-enumerable-module/max_by-method/

# Validations
```ruby
:name, presence: true, uniqueness: { case_sensitive: true }

validates :in_stock,
  inclusion: { in: [true, false] },
  allow_nil: true  # there is also allow_blank: true

validates :in_stock,
  exclusion: { in: [nil] },
  on: :create  # on create means only when creating resource

validates :email, format: { with: /\ A([ ^@\ s] +)@((?:[-a-z0-9] +\.) +[a-z]{ 2,})\ Z/ i }

validates_length_of :essay,
  minimum: 100,
  too_short: 'Your essay must be at least 100 words.',
  tokenizer: ->(str) { str.scan(/\w+/) } # Specifies how to split up the
             # attribute string. (e.g. tokenizer: ->(str) { str.scan(/\w+/) } to count
             # words). Defaults to ->(value) { value.split(//) }
             # which counts individual characters.
```
#### &nbsp;&nbsp;Uniqueness for multiple columns
&nbsp;&nbsp;Validate the presence and uniqueness of combination of ```receiver_id``` & ```comment_thread_id``` columns.
```ruby
validates :receiver_id, presence: true, uniqueness: { scope: :comment_thread_id }
```
# Order
```ruby
User.order(email: :desc)
=> SELECT "users".* FROM "users" ORDER BY "users"."email" DESC
```
In relation after joining with other tables
```ruby
scope.order("comment_threads.last_commented_at DESC")
```
# Performance related
**Another poor performance statement using ActiveRecord is:**
```ruby
if Actor.count == 0
  puts "No actors"
end
```
This code performs a count query on the SQL server. However, we don’t need to count *all* the actors on the table. The only thing we want is to know if there is at least one.

The SQL count query can be slower than we think. It possibly makes a sequential scan of the table. This means the database will go through each row, until the very last one, just to return the number of actors. A better approach is:
```ruby
# Here we are telling to the database to stop the query after finding the first one 
# and return the result immediately. 
# It’s much more performant this way!
if Actor.limit(1).count == 0
  puts "No actors"
end
```
*Count only until you need*. It’s also applicable to compare the count with other numbers:
```ruby
if Actor.limit(2).count > 1
  puts "Many actors"
end

if Actor.limit(101).count > 100
  puts "More than 10 pages of 10 actors"
end
```
Source:
- https://alexcastano.com/the-hidden-cost-of-the-invisible-queries-in-rails/

**When once is better than twice**
Imagine we want to print two movie lists, one with the published movies and another with the unpublished movies. If we do:
```ruby
puts "Published movies"
# First query
director.movies.where(published: true).each do |movie|
  puts movie.name
end

puts "Unpublished movies"
# Second query
director.movies.where(published: false).each do |movie|
  puts movie.name
end
```
We are doing two queries, but we are loading all the movies for this director anyway. It has better performance if we just load all movies at once and then we use them like an array:
```ruby
# This is an array now
movies = director.movies.to_a

puts "Published movies"
movies.select { |m| m.published }.each do |movie|
  puts movie.name
end

puts "Unpublished movies"
movies.reject { |m| m.published }.each do |movie|
  puts movie.name
end
```
