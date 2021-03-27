## INSERTing 50,000 records into a database in ActiveRecord, Arel, SQL, activerecord-import and Sequel.
### 1-activerecord
```ruby
require "active_record"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Migration.class_eval do
  create_table(:records) do |t|
    t.string :column
  end
end

data = 50_000.times.map { |i| Hash[column: "Column #{i}"] }

# =============================================================

class Record < ActiveRecord::Base
end

Record.create(data)

# Takes 60 seconds, because it's instantiating all the ActiveRecord::Base objects
```

### 2-arel

```ruby
require "active_record"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Migration.class_eval do
  create_table(:records) do |t|
    t.string :column
  end
end

data = 50_000.times.map { |i| Hash[column: "Column #{i}"] }

# =============================================================

data.each do |hash|
 insert          = Arel::Nodes::InsertStatement.new
 insert.relation = Arel::Table.new(:records)
 insert.columns  = hash.keys.map { |k| Arel::Table.new(:records)[k] }
 # insert.values   = Arel::Nodes::Values.new(hash.values, insert.columns)
 insert.values   = Arel::Nodes::ValuesList.new([record.values])

 ActiveRecord::Base.connection.execute(insert.to_sql)
end

# Takes 20 seconds, because of 50,000 INSERT statements, since Arel doesn't support
# INSERTing multiple records in a single query. This code is obviously really ugly.
```

```ruby
manager = Arel::InsertManager.new
table = Arel::Table.new(:notifications)
manager.into(table)
manager.insert(
  [
    [table[:created_at], Time.current],
    [table[:updated_at], Time.current],
    [table[:receiver_id], 1],
    [table[:platform], 'mobiles'],
    [table[:notification_type], 'notification_type'],
    [table[:source_type], 'source_type'],
    [table[:source_id], 123]
  ]
)
ActiveRecord::Base.connection.execute(manager.to_sql)
```

### 3-sql
```ruby
require "active_record"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Migration.class_eval do
  create_table(:records) do |t|
    t.string :column
  end
end

data = 50_000.times.map { |i| Hash[column: "Column #{i}"] }

# =============================================================

columns = data.first.keys
values_list = data.map do |hash|
  hash.values.map do |value|
    ActiveRecord::Base.connection.quote(value)
  end
end

ActiveRecord::Base.connection.execute <<-SQL
INSERT INTO records (#{columns.join(",")}) VALUES
#{values_list.map { |values| "(#{values.join(",")})" }.join(", ")}
SQL

# Takes 2 seconds, because it does a single multi INSERT statement.
# But the code is even uglier than with Arel.
```

### 4-activerecord-import.rb
```ruby
require "active_record"
require "activerecord-import" # https://github.com/zdennis/activerecord-import

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Migration.class_eval do
  create_table(:records) do |t|
    t.string :column
  end
end

data = 50_000.times.map { |i| Hash[column: "Column #{i}"] }

# =============================================================

class Record < ActiveRecord::Base
end

Record.import(data.first.keys, data.map(&:values), validate: false)

# Takes 2 seconds (like the SQL version), but it's an additional dependency.
```

### 5-sequel
```ruby
require "sequel"

DB = Sequel.sqlite
DB.create_table(:records) do
  primary_key :id
  String :column
end

data = 50_000.times.map { |i| Hash[column: "Column #{i}"] }

# =============================================================

DB[:records].multi_insert(data)

# Takes 2 seconds (like the SQL and activerecord-import versions), and it's a simple one-liner.
```
source: https://gist.github.com/janko/d76a138cf4cc1d1ecaab
