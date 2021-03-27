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

## Advanced Active Record: Using Subqueries in Rails
source: https://pganalyze.com/blog/active-record-subqueries-rails

### The Where Subquery
#### SQL:
```sql
SELECT *
FROM employees
WHERE
  employees.salary > (
    SELECT avg(salary)
    FROM employees)
```
#### Rails
```ruby
Employee.where('salary > (:avg)', avg: Employee.select('avg(salary)'))
```
Take note that we had to wrap the placeholder condition :avg in brackets, because the database wants subqueries wrapped in brackets as well.

### Where Not Exists
#### SQL:
```sql
SELECT *
FROM employees
WHERE
  NOT EXISTS (
    SELECT 1
    FROM vacations
    WHERE vacations.employee_id = employees.id)
```
#### Rails
```ruby
Employee.where(
  'NOT EXISTS (:vacations)',
  vacations: Vacation.select('1').where('employees.id = vacations.employee_id')
)
```

### The Select Subquery
#### SQL:
```sql
SELECT
  *,
  (SELECT avg(salary)
    FROM employees) avg_salary,
  salary - (
    SELECT avg(salary)
    FROM employees) above_avg
FROM employees
```
#### Rails
```ruby
avg_sql = Employee.select('avg(salary)').to_sql

Employee.select(
  '*',
  "(#{avg_sql}) avg_salary",
  "salary - (#{avg_sql}) avg_difference"
)
```

### The From Subquery
#### SQL:
```sql
SELECT avg(avg_score) reviewer_avg
FROM (
  SELECT reviewer_id, avg(score) avg_score
  FROM performance_reviews
  GROUP BY reviewer_id) reviewer_avgs
```
#### Rails
```ruby
from_sql =
  PerformanceReview.select(:reviewer_id, 'avg(score) avg_score').group(
    :reviewer_id
  ).to_sql

PerformanceReview.select('avg(avg_score) reviewer_avg').from(
  "(#{from_sql}) as reviewer_avgs"
).take.reviewer_avg
```

### The Having Subquery
#### SQL:
```sql
SELECT
  employees.*,
  avg(score) avg_score,
  (SELECT avg(score)
    FROM performance_reviews) company_avg
FROM
  employees
  INNER JOIN performance_reviews
    ON performance_reviews.reviewer_id = employees.id
GROUP BY employees.id
HAVING
  avg(score) < 0.75 *
    (SELECT avg(score)
    FROM performance_reviews)
```
#### Rails
```ruby
avg_sql = PerformanceReview.select('avg(score)').to_sql

Employee.joins(:employee_reviews).select(
  'employees.*',
  'avg(score) avg_score',
  "(#{avg_sql}) company_avg"
).group('employees.id').having("avg(score) < 0.75 * (#{avg_sql})")
```
