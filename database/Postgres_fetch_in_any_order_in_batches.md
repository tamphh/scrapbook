# Postgres fetch in any order in batches using pg cursor rails
If the table in postgres has large amount of data, you should avoid loading records all at once. In that case, batch processing methods ```ActiveRecord#find_each``` allow you to work with the records in batches, thereby greatly reducing memory consumption.

The disadvantage of using ```ActiveRecord#find_each``` is that it's not possible to set the order of records in the query, it automatically sets the order of records to ascending on the primary key (“id ASC”).

If you want the records in some other order than primary key you should be using ```postgresql_cursor```. However, ```postgresql_cursor``` does not natively support eager loading. If you need to efficiently preload an association you can trigger it manually:

```ruby
batch_size = 1000
data = Model.order("field")

data.each_instance(block_size: batch_size).lazy.each_slice(batch_size) do |batch|
  ActiveRecord::Associations::Preloader.new.preload(batch, [:associated_models])
    batch.each do |source_object|
      your logic goes here
    end
end
```
keep Coding !!!  
Ref: https://www.inkoop.io/blog/querying-large-postgres-data-with-order-using-postgres-cursor/
