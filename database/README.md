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

### Table 'performance_schema.session_variables' doesn't exist error
```sh
mysql_upgrade -u root -p
service mysql restart
```
