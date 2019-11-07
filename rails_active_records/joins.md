## Different nested joins
Beware of the way you use joins in ActiveRecord, say User has one Profile, and Profile has many Skills. By default it uses INNER JOIN but…

```ruby
# DON'T
User.joins(:profiles).merge(Profile.joins(:skills))
=> SELECT users.* FROM users 
   INNER JOIN profiles    ON profiles.user_id  = users.id
   LEFT OUTER JOIN skills ON skills.profile_id = profiles.id
```
**So you'd rather use:**

```ruby
# DO
User.joins(profiles: :skills)
=> SELECT users.* FROM users 
   INNER JOIN profiles ON profiles.user_id  = users.id
   INNER JOIN skills   ON skills.profile_id = profiles.id
```
