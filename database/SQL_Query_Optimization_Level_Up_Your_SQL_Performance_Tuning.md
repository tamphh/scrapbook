# SQL Query Optimization: Level Up Your SQL Performance Tuning
`Supercharge Your SQL Queries for Production Data Systems`

Data is an integral part of any application. Access to the data should be in the fastest way possible to enhance the user experience while using the application.

### Why is Query Optimization even needed?
SQL is one of the most powerful data-handling tools around. However, SQL is a declarative language, that is, each query declares what we want the SQL engine to do, but it doesn’t say how. As it turns out, the how — the “plan” — is what affects the efficiency of the queries, however, so it’s pretty important.
An inefficient query will drain the production database’s resources, and cause slow performance or loss of service for other users if the query contains errors. It’s vital you optimize your queries for minimum impact on database performance.
There is no step-by-step guide for the same. In turn, we must use general guidelines for writing queries, which operators to use. Then check for “execution plans” and find out that part of the query takes the most time and rewrite that part in some other way.

### Benefits of Query Optimization
- **Minimize production issues**: Inefficient queries require high CPU, memory, and I/O operations that mostly lead to deadlocks, failed transactions, system hangs, and other production issues.
- **Performance issues**: Slow query means slower response time of applications using the query, which results in poor user experience.
- **Save infra cost**: As non-optimized query requires more CPU and memory, they lead to higher infrastructure cost.

### Query Optimization Best Practices
- **Choose Datatype wisely**: Using Varchar(10) for storing fixed-length data (like Mobile Number) will incur a 20% higher query executing penalty when compared to using char(10) for fixed-length data.
- **Avoid using implicit conversion**: When a query compares different data types, it uses implicit datatype conversion. Hence, in queries, one should avoid comparing different datatype columns and values, like:
```sql
WHERE date >= "2022-01-01"
```
- **Avoid using Function-based conditional clause**: When a query uses a function in the WHERE or JOIN clause on the column, it would not utilize the index, hence slowing down the execution.
```sql
-- WHERE date(ship_date) = '2022–01–01'
-- JOIN T2 ON CONCAT(first_name,' ',last_name) = 'garvit arya'
```
- **Avoid using `DISTINCT` and `GROUP BY` at the same time**: If you already have `GROUP BY` in your query, there is no need of having `DISTINCT` separately.
- **Avoid using `UNION DISTINCT` and `SELECT DISTINCT` at the same time**: For queries with `UNION DISTINCT`, it removes duplicate records natively, and hence there is no need of using `SELECT DISTINCT`.
- **Don’t use `SELECT *` ever**: Selecting unnecessary columns would be a waste of memory and CPU cycle. It is always better to select column names instead of * or extra columns.
- **Avoid sub-query where possible**: Sub-query creates temp tables to store data and sometimes it creates temp tables on the disk thereby slowing the query execution. Prefer WITH clause over nested sub-queries.
- **Avoid using `Order` by in the Sub-query**: Ordering in sub-queries are mostly redundant and lead to significant performance issues.
- **Don’t `GROUP` numbers**: Avoid grouping by columns of type DOUBLE or FLOAT, as this may lead to unexpected behavior due to rounding & precision issues.
- **Minimize use of `SELF` Joins**: Self joins are computationally more expensive and can be replaced with Window function in many cases.
- **Don’t join tables with `OR` condition**: It can be optimized by using `UNION ALL` in place of `OR` based joins
- **Avoid join with not equal condition**: When a query joins with NOT EQUAL operator it searches all rows and uses a full table scan which is highly inefficient.
- **Avoid Full-Text Search**: When a query searches for keywords with a wildcard in the beginning it does not utilize an index, and the database is tasked with searching all records for a match anywhere within the selected field. Hence, if needed prefer to use wildcards at the end of a phrase only.
```sql
SELECT user_name
FROM test
WHERE user_name LIKE '%abc%'
```
- Use `WHERE` instead of `HAVING`: Prefer usage of where instead of having as `HAVING` statements are calculated after `WHERE` statements.

### Final Thoughts
Understanding execution plans and optimizing SQL queries can be tedious and take a while to learn. I’ve been using SQL for several years and still learn new techniques all the time!
If you diligently follow the query optimization techniques detailed above, you could benefit from improved query performance, lesser production issues and save cost by minimizing resources.
Try these techniques and let me know how well they work for you in the comments section below!

source: https://betterprogramming.pub/sql-query-optimization-level-up-your-sql-performance-tuning-d93af175b24b
