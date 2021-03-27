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

### Joins across tables
Let’s say we add an Address model where a company has many addresses. If we wanted to grab all employees who are at companies that have addresses, we would perform the following query:
```ruby
Employee.joins(company: [:addresses])
```
If we want to grab all active employees at companies that are verified in the state of California, we would perform this query:
```ruby
Employee
  .where(status: "active")
  .joins(company: [:addresses])
  .where(addresses: { state: 'CA'}, companies: { verified: true })
```
Nested joins and where clauses can be tacked on til the cows come home.

source: https://medium.com/swlh/getting-really-good-at-rails-joins-93fd5b33fa8e

## Using ```joins``` with OR
There is a requirement when you use the Rails 5 ```.or``` method: both sides of the query must have a compatible structure. What does it mean?

```ruby
User.joins(:profile).where(name: "John").or(User.where(name: "Tom")).count
# => ArgumentError: Relation passed to #or must be structurally compatible. Incompatible values: [:joins]

User.joins(:profile).where(name: "John").or(User.joins(:profile).where(name: "Tom")).count
# => 2
```
Oh, this also happens with .includes as you probably imagined.

In fact, the only difference that can exist between both sides of the ```OR``` are the ```WHERE``` and ```HAVING``` clauses. Any other difference will throw out an ```ArgumentError``` claiming an incompatible structure.

source: http://codeatmorning.com/rails-5-meet-the-active-record-or-query/
