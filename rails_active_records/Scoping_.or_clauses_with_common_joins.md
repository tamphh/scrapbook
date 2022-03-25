# Scoping .or clauses with common joins
**ActiveRecord has an .or method that allows you to create a query that matches one of multiple conditions.**

source: https://thoughtbot.com/blog/scoping-or-clauses-with-common-joins

```ruby
ost.where(author: first_author).or(Post.where(author: second_author))
# SELECT `posts`.* FROM `posts` WHERE ((author_id = 1) OR (author_id = 2))
```
One gotcha is that the two relations must be structurally compatible. Most commonly this means that the base relations must have the same `.joins` clauses, but it applies to anything that isn’t a `where` clause or `having` clause.

This often leads to queries like this
```ruby
Post
  .joins(:category).where(categories: {name: "ruby"})
  .or(Post.joins(:category).where(categories: {name: "rails"})
```

The `joins(:category)` bit must be repeated. This can feel a little verbose.

Enter `.scoping`! This method scopes all queries within the block to the current scope. We can use this to call our joins once, and within the block the relations are automatically scoped with the join.
```ruby
Post.joins(:category).scoping do
  Post.where(categories: {name: "ruby"})
    .or(Post.where(categories: {name: "rails"})
end
```

If this is already in the Post class it’s even tidier!

```ruby
joins(:category).scoping do
  where(categories: {name: "ruby"}).or(where(categories: {name: "rails"}))
end
```

This has helped me make sense of more complex queries that join multiple associations and merge conditions from other models. Being able to extract the common structure makes it easier to see what conditions are being applied.

```ruby
def self.in_progress
  left_joins(:status, :delivery).scoping do
    merge(OrderStatus.pending).or(merge(Delivery.active))
  end
end
```

Happy scoping! 🤗

