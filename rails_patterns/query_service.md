# Bottom point of Query Interface is that you don’t call any other relation after it!
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
