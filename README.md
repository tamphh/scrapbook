# scrapbook
Web development note, mostly for Rails

### SELECT list is not in GROUP BY clause and contains nonaggregated column … incompatible with sql_mode=only_full_group_by
```sql
mysql -u root -p
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
```

### JSON pretty print
```ruby
puts JSON.pretty_generate(my_object)
```

### Conditions passed with question mark interpolation
```ruby
User.where("users.first_name = ? and users.last_name = ?", 'Oliver', 'Sykes')
# SELECT "users".* FROM "users" WHERE (users.first_name = 'Oliver' and users.last_name = 'Sykes')
# => [] # User::ActiveRecord_Relation 

User.joins(:lessons).where("users.first_name = ? and lessons.title LIKE ?", 'Tomas', '%test%')
# SELECT "users".* FROM "users" INNER JOIN "lessons" ON "lessons"."user_id" = "users"."id"  WHERE (users.first_name = 'Tomas' and lessons.title LIKE '%test%')
# => [] # User::ActiveRecord_Relation
```
Remember **NEVER EVER** to do direct string interpolation with “#{}”!
```ruby
## DON'T !!!
name = "I'm going to hack you;"
User.where("users.first_name = '#{name}'") # NEVER DO THIS !!!
```
…this would open your App to [SQL injection Attack](http://guides.rubyonrails.org/security.html#sql-injection).

### Merge different model scopes
Let say User can be accesed via a public uid
```ruby
class User < ActiveRecord::Base
  has_many :articles
  scope :for_public_uid, ->(uids) { where(id: uids) }
end


User.for_public_uid('abcd1234')
# SELECT "users".* FROM "users" WHERE "users"."public_uid" = $1  [["public_uid", 'abcd1234']]
=> #<ActiveRecord::Relation []>

User.for_public_uid(['abcd1234', 'xyzff235'])
# SELECT "users".* FROM "users" WHERE "users"."public_uid" IN ('abcd1234', 'xyzff235')
=> #<ActiveRecord::Relation []>
```
Merge can be implemented on any scope returning “ActiveRecord::Relation”:
```ruby
class DocumentVersion
  scope :order_by_latest, ->{ order("document_versions.id DESC") } 
end

class Document
  scope :order_by_latest, ->{ joins(:document_versions).merge(DocumentVersion.order_by_latest) }
end

Document.order_by_latest
```
### Bottom point of Query Interface is that you don’t call any other relation after it!
So no:
```ruby
# DONT
class MyController < ApplicationController
  # ...
  def index
    # ...
    c = AdminQueryInterface
      .comments_including_for_approval(organization: organization)
      .limit(10) # DONT!
    # ...
  end
  # ...
end
```
If you need “similar” example with just one altertaion then just define new Query Interface method and use that one and test it separatly:
```ruby
module AdminQueryInterface 
  # ...
  def comments_including_for_approval_paginated(organization:, limit: )
    comments_including_for_approval(organization: organization).limit(limit)
  end
end
```
### Sample for many to many through relationship:
```ruby
class Physician < ApplicationRecord
  has_many :appointments
  has_many :patients, through: :appointments
end
 
class Appointment < ApplicationRecord
  belongs_to :physician
  belongs_to :patient
end
 
class Patient < ApplicationRecord
  has_many :appointments
  has_many :physicians, through: :appointments
end
```


