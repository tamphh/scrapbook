# Rails Cheat Sheet: Create Models, Tables and Migrations
### Create a new table in Rails
```sh
bin/rails g model Supplier name:string
bin/rails g model Product name:string:index sku:string{10}:uniq count:integer description:text supplier:references popularity:float 'price:decimal{10,2}' available:boolean availableSince:datetime image:binary
```
**Resulting migrations:**
```ruby
class CreateSuppliers < ActiveRecord::Migration[6.0]
  def change
    create_table :suppliers do |t|
      t.string :name

      t.timestamps
    end
  end
end

class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :sku, limit: 10
      t.integer :count
      t.text :description
      t.references :supplier, foreign_key: true
      t.float :popularity
      t.decimal :price, precision: 10, scale: 2
      t.boolean :available
      t.datetime :availableSince
      t.binary :image

      t.timestamps
    end
    add_index :products, :name
    add_index :products, :sku, unique: true
  end
end
```
### Rails migration to add a column
```sh
bin/rails g migration AddKeywordsSizeToProduct keywords:string size:string
```
**Resulting migration:**

```ruby
class AddKeywordsSizeToProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :keywords, :string
    add_column :products, :size, :string
  end
end
```

### Rails migration to remove a column
```sh
bin/rails g migration RemoveKeywordsFromProduct keywords
```

**Resulting migration:**

```ruby
class RemoveKeywordsFromProduct < ActiveRecord::Migration[6.0]
  def change
    remove_column :products, :keywords, :string
  end
end
```

### Rails migration to rename a column
```sh
bin/rails g migration RenameProductPopularityToRanking
```

You need to add the ```rename_column``` command manually to the resulting migration:

```ruby
class RenameProductPopularityToRanking < ActiveRecord::Migration[6.0]
  def change
    rename_column :products, :popularity, :ranking
  end
end
```

### Rails migration to change a column type
```sh
bin/rails g migration ChangeProductPopularity
```
You need to add the ```change_column``` command manually to the resulting migration:

```ruby
class ChangeProductPopularity < ActiveRecord::Migration[6.0]
  def change
      change_column :products, :ranking, :decimal, precision: 10, scale: 2
  end
end
```

#### Running migrations
```sh
bin/rake db:migrate
```

In production:

```sh
bin/rake db:migrate RAILS_ENV="production" 
```

Source: https://www.ralfebert.de/snippets/ruby-rails/models-tables-migrations-cheat-sheet/
