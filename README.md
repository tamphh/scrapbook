# scrapbook
Web development note, mostly for Rails

# Conditions passed with question mark interpolation
```
User.where("users.first_name = ? and users.last_name = ?", 'Oliver', 'Sykes')
# SELECT "users".* FROM "users" WHERE (users.first_name = 'Oliver' and users.last_name = 'Sykes')
# => [] # User::ActiveRecord_Relation 

User.joins(:lessons).where("users.first_name = ? and lessons.title LIKE ?", 'Tomas', '%test%')
# SELECT "users".* FROM "users" INNER JOIN "lessons" ON "lessons"."user_id" = "users"."id"  WHERE (users.first_name = 'Tomas' and lessons.title LIKE '%test%')
# => [] # User::ActiveRecord_Relation
```
Remember **NEVER EVER** to do direct string interpolation with “#{}”!
```
## DON'T !!!
name = "I'm going to hack you;"
User.where("users.first_name = '#{name}'") # NEVER DO THIS !!!
```
…this would open your App to [SQL injection Attack](http://guides.rubyonrails.org/security.html#sql-injection).

# Merge different model scopes
Let say User can be accesed via a public uid
```
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
```
class DocumentVersion
  scope :order_by_latest, ->{ order("document_versions.id DESC") } 
end

class Document
  scope :order_by_latest, ->{ joins(:document_versions).merge(DocumentVersion.order_by_latest) }
end

Document.order_by_latest
```
# Bottom point of Query Interface is that you don’t call any other relation after it!
So no:
```
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
```
module AdminQueryInterface 
  # ...
  def comments_including_for_approval_paginated(organization:, limit: )
    comments_including_for_approval(organization: organization).limit(limit)
  end
end
```


