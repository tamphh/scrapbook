## Database notes around SQL, queries, core concepts,...
### Awesome blog:
- https://blog.jooq.org/sql/
### Disabling ONLY_FULL_GROUP_BY

If you are upgrading your database server and want to avoid any possible breaks you can disable by removing it from your ```sql_mode```.
#### Changing in runtime
```sql
SET @@GLOBAL.sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'
```
A restart is not necessary, but a reconnection is.

#### Change permanently
If you want to disable it permanently, add/edit the following in your ```my.cnf``` file:

```sql
sql_mode = "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
```
For this change a service restart is required:
```sh
$ mysql service restart
```

### How to get second-highest salary employees in a table
```sql
;WITH T AS
(
SELECT *,
       DENSE_RANK() OVER (ORDER BY Salary Desc) AS Rnk
FROM Employees
)
SELECT Name
FROM T
WHERE Rnk=2;
```
### Find the nth highest salary in MySQL
```sql
SELECT Salary FROM Employee 
ORDER BY Salary DESC LIMIT n-1,1
```
### How to get count of employees with total employee with group by year
You need a running total using a user defined variable and a derived table cause running totals don't work with group by statement.

```sql
SET @SUM = 0;
SELECT
  YEAR,
  NoOfEmployee,
  (@SUM := @SUM + NoOfEmployee) AS Total
FROM (
  SELECT
    YEAR(joindate) AS YEAR,
    COUNT(*) AS NoOfEmployee
  FROM
    employees
  GROUP BY
    YEAR(joindate)
  ) O
  JOIN (SELECT @SUM:=0) r
```
source: https://stackoverflow.com/questions/34063127/how-to-get-count-of-employees-with-total-employee-with-group-by-year?answertab=oldest#tab-top

### How to get count of employees with total employee with group by year
Order results by id and put the one with ```id=7412``` to top.
```sql
select * 
  from goals
  order by id = 7412 desc, id desc;
```

### ```EXISTS``` clause
- What kind of store is present in one or more cities?
```sql
SELECT DISTINCT store_type FROM stores
  WHERE EXISTS (SELECT * FROM cities_stores
                WHERE cities_stores.store_type = stores.store_type);
```

- What kind of store is present in no cities?
```sql
SELECT DISTINCT store_type FROM stores
  WHERE NOT EXISTS (SELECT * FROM cities_stores
                    WHERE cities_stores.store_type = stores.store_type);
```

- What kind of store is present in all cities?
```sql
SELECT DISTINCT store_type FROM stores s1
  WHERE NOT EXISTS (
    SELECT * FROM cities WHERE NOT EXISTS (
      SELECT * FROM cities_stores
       WHERE cities_stores.city = cities.city
       AND cities_stores.store_type = stores.store_type));
```
The last example is a double-nested NOT EXISTS query. That is, it has a NOT EXISTS clause within a NOT EXISTS clause. Formally, it answers the question “does a city exist with a store that is not in Stores”? But it is easier to say that a nested NOT EXISTS answers the question “is x TRUE for all y?”

source: https://dev.mysql.com/doc/refman/8.0/en/exists-and-not-exists-subqueries.html

### Table 'performance_schema.session_variables' doesn't exist error
```sh
mysql_upgrade -u root -p
service mysql restart
```

### How to get surveys which has only one text question
- We need to get surveys with only one question and its question type is text
- ```GROUP_CONCAT(questions. `type`) IS NOT NULL``` could be replaced with ```GROUP_CONCAT(questions. `type`) = 'Question::TextQuestion'```

```sql
SELECT
  MAX(survey_question_scores.survey_id) AS sent_survey_id,
  COUNT(*),
  GROUP_CONCAT(survey_question_scores.question_id),
  GROUP_CONCAT(questions. `type`)
FROM
  `survey_question_scores`
  LEFT JOIN `surveys` ON `surveys`.`id` = `survey_question_scores`.`survey_id`
  LEFT JOIN `questions` ON `questions`.`id` = `survey_question_scores`.`question_id`
    AND `questions`.`type` = 'Question::TextQuestion'
WHERE
  `surveys`.`organization_id` = 40857
GROUP BY
  survey_question_scores.survey_id
HAVING
  COUNT(*) = 1
  AND GROUP_CONCAT(questions. `type`) IS NOT NULL;
```
