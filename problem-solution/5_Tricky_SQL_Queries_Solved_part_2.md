# 5 Tricky SQL Queries Solved — Part II
It’s time to raise the bar. Let us try to solve more complex SQL queries.

> “Celebrate what you’ve accomplished, but raise the bar a little higher each time you succeed” — Mia Hamm

In my previous article 5 Tricky SQL Queries Solved (https://www.kdnuggets.com/2020/11/5-tricky-sql-queries-solved.html), I explained the approach to solve a few complex queries. After receiving a good response I decided to raise the bar, by describing my approach to solving a few more complicated queries which are more practical and challenging.

source: https://pub.towardsai.net/5-tricky-sql-queries-solved-part-ii-8acceec170b0

## Query 1

![1_2bajKYubJNm1t8JW6ZDU_A](https://user-images.githubusercontent.com/12711066/158302154-3b0d2de2-9a5b-4cd9-82be-1f27c0e8566d.png)

We are given two tables.
**Accounts** table — Each row of this table contains the account number and name of each user in the bank.
**Transactions** table — Each row of this table contains the transactions of all accounts. Amount is positive if the user received money and negative if they transferred money. All the accounts start with an initial balance of zero.
We need to write an SQL query to return the name and balance of all users having a balance greater than 10,000.
`Balance = Total received money-Total transferred money`

**My solution**
Firstly we need to join the two tables. Since we need to find the balance of each account we can use the `GROUP BY` clause on the `Account ID` column. We can find the **sum** of amount column grouped by `Account ID` and filter rows having sum>10000.

```sql
SELECT    
a.name AS name,    
sum(b.amount) AS balance
FROM Users AS a JOIN Transactions AS b
on a.account = b.account
GROUP BY    a.account
HAVING balance > 10000;
```

## Query 2
Given a table of students and their GRE test scores, write a query to return the two students with the _closest_ test scores and their **score difference**. 
If there exists more than one pair, sort their names in ascending order and then return the _first_ resulting pair.

![1_NKjJsNd6zsg2i9lidF7QZA](https://user-images.githubusercontent.com/12711066/158302427-a536693b-f129-4d85-a161-de3e8e60564b.png)


**My Solution**

This requires some creative thinking in SQL. Since there is only one table with two columns we need to self-reference different creations of the same table. We can solve these kinds of problems by visualizing two tables having the same values.
Let us have two same copies of the above scores table named s1 and s2. Since we need to compare every student with every other student. We can perform inner join by setting:

```sql
scores AS s1 INNER JOIN scores AS s2
 ON s1.ID != s2.ID
 ```
 
This way we are comparing every student with every other student and are also avoiding comparing a student to his/herself. However, if we run the final query using the above join condition, observe the output.

![1_CNoJ-Pi9TXBWQGQXN788LQ](https://user-images.githubusercontent.com/12711066/158302554-04e3082e-7314-4395-8775-60f29b93eeb9.png)

Since we are comparing every student in s1 with every other student in s2, **duplication** is happening. 
And if there exist a million rows our query will be **inefficient**. To _optimize_ the query let us add a condition **s1.id > s2.id** to ensure that comparison happens only once.
Therefore all we need to do now is subtract each score from each other score and order this difference in ascending order using the **ORDER BY** clause. 
Since we need the closest score, we will print only the first row using the **LIMIT** clause.

```sql
SELECT 
    s1.name AS s1_name
    , s2.name AS s2_name
    , ABS(s1.score - s2.score) AS score_diff
FROM scores AS s1
INNER JOIN scores AS s2
    ON s1.id != s2.id
        AND s1.id > s2.id
ORDER BY score_diff ASC, s1_name ASC
LIMIT 1
```

## Query 3

![1_-IR5NLr__CFluGRuzTH9CQ](https://user-images.githubusercontent.com/12711066/158302753-19283f2e-909a-4f70-84ed-03219472232d.png)

Given the above two tables employees and departments, select the top department which consists of the _highest percentage_ of employees who earn over 1500 in salary and have _at least_ 2 employees.

**My Solution**

We can break down the given question into separate clauses.
1) Top department.
2) % of employees making over 1500 in salary.
3) Department must have at least 2 employees.
Before solving the above clauses let us have a combined representation of the two tables where each employee is associated with their department names. Since both tables have a common column department_id we can perform a join using
```sql
employees AS e INNER JOIN departments AS d
ON e.department_id = d.id
```

![1_kClJjtYPhx7DE8dIq2tGBQ](https://user-images.githubusercontent.com/12711066/158302823-e41a54a7-44a1-4f8d-a195-af3f73dd6fe9.png)

Now that we have this full representation, we can start filtering, aggregating to get our output. 
We know that we need to calculate the total number of employees that are making over 1500 by each department. 
We can use the **GROUP BY** clause on dept_name since we need one row for each department.

To find the percentage of people earning over 1500 we can use —
`(Number of people making over 1500) / (Total number of people in that department)`

Finally, we need to find the count the number of Employee IDs to filter departments having more than 2 employees.

```sql
SELECT 
       d.Dept_Name AS d_name, 
      SUM(CASE WHEN e.salary > 1500 THEN 1 ELSE 0 END)/COUNT(DISTINCT e.id) AS pct_above_1500,
      COUNT(DISTINCT e.id) AS number_of_employees
FROM employees e JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d_name
HAVING number_of_employees >= 2
ORDER BY pct_above_1500 DESC
LIMIT 1
```
We use the **SUM** and **CASE** clause to find the number of employees with a salary greater than 1500.

![1_qnM4nOF-0agr45LrKtulHg](https://user-images.githubusercontent.com/12711066/158302958-c5d4b6b8-8598-4c87-b1e3-d25b01845573.png)

## Query 4

![1_ZK2Kw51nGf_79BoDIJzqrQ](https://user-images.githubusercontent.com/12711066/158303085-68ce63e4-dc89-4f3e-b29c-abf85ac49043.png)

In the above table, we are given scores of IDs. W need to write a SQL Query to output the **rank** of these scores. 
Incase, the scores are tied, the _same rank_ must be assigned to both the scores.
**My Solution**
Firstly, let us segregate the distinct scores and create another copy of the input table.

![1_XhxCnbuGpJFCiXhRTxkx9g](https://user-images.githubusercontent.com/12711066/158303154-19c8bca7-a6f2-4a24-83db-0a96aa19587c.png)

For **each score** in the S: Scores Table, we want to find out the number of Scores in the S2:Scores table that are greater than or equal. We can group by ID and compare the scores.

![1_elve6HItqw4lUsa71YlKzQ](https://user-images.githubusercontent.com/12711066/158303165-2459c4ba-5c20-4e01-ba78-bb1d5b1f2eb9.png)

This is nothing but the rank of that particular score!
```sql
SELECT S.Score, COUNT(S2.Score) AS Rank FROM Scores S,
(SELECT DISTINCT Score FROM Scores) AS S2
WHERE S.Score<=S2.Score
GROUP BY S.Id 
ORDER BY S.Score DESC;
```

## Query 5

![1_q7Ahv8fG_ROPm4mlmJAV3w](https://user-images.githubusercontent.com/12711066/158303270-7c80b8d2-4c22-458e-a66a-7acacd1063c9.png)

The above table consists of Visitor ID, Visitor Date, and number of Visitors on that particular date. No two same dates exist. 
Write an SQL query to display three or more consecutive ID's, having visitors more than or equal to 100 sorted by their visiting date. 
IDs will be consecutive and unique.
You may argue that ID 2 and 3 also have more than 100 visitors and are not displayed in the output. The main condition is to display 3 or more IDs with visitors more than 100 here. Hence, 5,6,7,8 are displayed.

**My Solution**

I found this question to be tricky as the title of this article suggests :) Similar to Query 2 we need to create a self join on the stadium table. We can compare IDs and compute our results. A given row s1 can be the first, middle, or last one in the 3 consecutive rows.
- s1 in the beginning: (s1.id + 1 = s2.id AND s1.id + 2 = s3.id)
- s1 in the middle: (s1.id — 1 = s2.id AND s1.id + 1 = s3.id)
- s1 in the end: (s1.id — 2 = s2.id AND s1.id — 1 = s3.id)

```sql
SELECT s1.* FROM stadium AS s1, stadium AS s2, stadium as s3
    WHERE 
    ((s1.id + 1 = s2.id
    AND s1.id + 2 = s3.id)
    OR 
    (s1.id - 1 = s2.id
    AND s1.id + 1 = s3.id)
    OR
    (s1.id - 2 = s2.id
    AND s1.id - 1 = s3.id)
    )
    AND s1.people>=100 
    AND s2.people>=100
    AND s3.people>=100
GROUP BY s1.id
ORDER BY s1.visit_date
```

Do watch this no-sound video for clear understanding.
https://youtu.be/vzxaWnzzH6I

### Conclusion
Mastering SQL takes time and practice. I took five more challenging questions in this article and explained the ways to solve them. The speciality of SQL is that it is possible to write each query in many different ways. Feel free to share your strategies in the answers. I hope that today you’ve learned something new!
