# Includes
*participant* belongs to *comment_thread* which has one *last_comment*, polymorphic with *source_type, source_id*
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
