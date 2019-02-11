## Database notes around SQL, queries, core concepts,...
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
Simpler solution:
```sql
SELECT TOP 1 salary FROM (
   SELECT TOP 2 salary 
   FROM employees 
   ORDER BY salary DESC) AS emp 
ORDER BY salary ASC
```
