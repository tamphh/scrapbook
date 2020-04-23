### Constructing a select * from subquery using ActiveRecord
```ruby
# This example builds equivalent SQL to the previous raw_sql example 
# with the SELECT * FROM (DISTINCT ON ...)
inner_query = User
  .all
  .joins(attendances: { concert: :artist })
  .select("DISTINCT ON(artists.id)
    artists.name as artist,
    users.name as attendee,
    concerts.start_time as latest_time
  ")
  .order("
    artists.id, 
    latest_time DESC
  ")

User
  .unscoped
  .select("*")
  .from(inner_query, :inner_query)
  .order("inner_query.latest_time DESC")
  ```
Note that in the above query we use the second argument in the from clause to 
specify the alias for the table ```.from(inner_query, :inner_query)```. 
This allows us to more easily order by the latest_time in the order by clause.

source: http://joshfrankel.me/blog/constructing-a-sql-select-from-subquery-in-activerecord/

