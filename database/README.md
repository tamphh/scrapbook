## Database notes around SQL, queries, core concepts,...
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
