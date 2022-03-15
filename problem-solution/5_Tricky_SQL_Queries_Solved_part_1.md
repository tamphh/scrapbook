# 5 Tricky SQL Queries Solved

SQL(Structured Query Language) is a very important tool in a data scientist’s toolbox. Mastering SQL is not only essential in an interview point of view, but a good understanding of SQL by being able to solve complex queries will keep us above everyone in the race.

In this article, I will talk about 5 tricky questions I found and my approaches to solve them.


source: https://www.kdnuggets.com/2020/11/5-tricky-sql-queries-solved.html

### Query 1
 
We are given a table consisting of two columns, Name, and Profession. We need to query all the names immediately followed by the first letter in the profession column enclosed in parenthesis.

![sura-sql-tricky-1](https://user-images.githubusercontent.com/12711066/158300867-7de88590-5366-485d-92d8-339eb39cd967.png)

**My Solution**
```sql
SELECT
CONCAT(Name, ’(‘, SUBSTR(Profession, 1, 1), ’)’) 
FROM table;
```

Since we need to combine the name and profession we can useCONCAT. We also need to have only one letter inside the parenthesis. Hence we will use SUBSTRand pass the column name, start index, end index. Since we need only the first letter we will pass 1,1(start index is inclusive and the end index is not inclusive)

### Query 2
 
Tina was asked to compute the average salary of all employees from the EMPLOYEES table she created but realized that the zero key in her keyboard is not working after the result showed a very less average. She wants our help in finding out the difference between miscalculated average and actual average.

![sura-sql-tricky-2](https://user-images.githubusercontent.com/12711066/158300944-7a36f3be-e5ab-4558-9683-e5b760dba416.png)

We must write a query finding the error( Actual AVG — Calculated AVG).
**My Solution**
```sql
SELECT  
AVG(Salary) - AVG(REPLACE(Salary, 0, ’’))  
FROM table;
```

A point to note here is that we have only one table that consists of actual salary values. To create the error scenario we use REPLACE to replace 0’s. We will pass the column name, value to be replaced, and the value with which we will replace the REPLACE method. Then we find the difference in averages using the aggregate function AVG.

### Query 3
 
We are given a table, which is a Binary Search Tree consisting of two columns Node and Parent. We must write a query that returns the node type ordered by the value of nodes in ascending order. There are 3 types.
- Root — if the node is a root
- Leaf — if the node is a leaf
- Inner — if the node is neither root nor leaf.

![sura-sql-tricky-3](https://user-images.githubusercontent.com/12711066/158301122-5cd25b6a-5db2-4118-8f7e-06e53a1d0171.png)

**My Solution**

Upon initial analysis, we can conclude that if a given node N has its corresponding P-value as NULL it is the root. And for a given Node N if it exists in the P column it is not an inner node. Based on this idea let us write a query.
```sql
SELECT CASE
    WHEN P IS NULL THEN CONCAT(N, ' Root')
    WHEN N IN (SELECT DISTINCT P from BST) THEN CONCAT(N, ' Inner')
    ELSE CONCAT(N, ' Leaf')
    END
FROM BST
ORDER BY N asc;
```

We can use CASE which acts as a switch function. As I mentioned if P is null for a given node N then N is the root. Hence we usedCONCAT for combining the node value and label. Similarly, if a given node N is in column P it is an inner node. To get all nodes from column P we wrote a subquery which returns all the distinct nodes in column P. Since we were asked to order the output by node values in ascending order we used the ORDER BY Clause.

### Query 4
 
We are given a transaction table that consists of `transaction_id`, `user_id`, `transaction_date`, `product_id`, and `quantity`. We need to query the number of users who purchased products on multiple days(Note that a given user can purchase multiple products on a single day).

![sura-sql-tricky-4](https://user-images.githubusercontent.com/12711066/158301291-892f5e23-0a0e-4135-9221-732ce0262fb7.png)

**My Solution**

To solve this query, we cannot directly count the occurrence of user_id’s and if it is more than one return that user_id because a given user can have more than one transaction on a single day. Hence if a given user_id has more than one distinct date associated with it means he purchased products on multiple days. Following the same approach, I wrote a query. (Inner query)
```sql
SELECT COUNT(user_id)
FROM
(
SELECT user_id
 FROM orders
 GROUP BY user_id
 HAVING COUNT(DISTINCT DATE(date)) > 1
) t1
```

Since the question asked for the number of user_ids and not the user_id’s itself we use COUNT in the outer query.

### Query 5
 
We are given a subscription table which consists of subscription start and end date for each user. We need to write a query that returns true/false for each user based on the overlapping of dates with other users. For instance, If user1's subscription period overlaps with any other user the query must return `True` for **user1**.

![sura-sql-tricky-5](https://user-images.githubusercontent.com/12711066/158301409-0cd1b601-0c05-46b6-9abf-451d16ebaaef.png)

**My Solution**

Upon initial analysis, we understand that we must compare every subscription against every other one. Let us consider start and end dates of **userA** as **startA** and **endA**, similarly for **userB**,**startB** and **endB**.

If **startA≤endB and endA≥startB** then we can say the two date ranges overlap. Let us take two examples. Let us compare U1 AND U3 first.
`
startA = 2020–01–01
endA = 2020–01–31
startB = 2020–01–16
endB = 2020–01–26
`
Here we can see **startA**(2020–01–01) is less than **endB**(2020–01–26) and similarly, **endA**(2020–01–31) is greater than **startB**(2020–01–16) and hence can conclude that the dates overlap. Similarly, if you compare U1 and U4 the above condition fails and will return false.

We must also ensure that a user is not compared to his own subscription. We also want to run a left join on itself to match a user with each other user that satisfies our condition. We will create two replicas s1 and s2 of the same table now.

```sql
SELECT *
FROM subscriptions AS s1
LEFT JOIN subscriptions AS s2
    ON s1.user_id != s2.user_id
        AND s1.start_date <= s2.end_date
        AND s1.end_date >= s2.start_date
```

Given the conditional join, a `user_id` from s2 should exist for each user_id in s1 on the condition where there exists an overlap between the dates.

**Output**
![sura-sql-tricky-6](https://user-images.githubusercontent.com/12711066/158301626-e12eb460-87ce-4663-bfcb-86354d73bcbb.png)

We can see there exists another user for each user in case the dates overlap. For user1 there are 2 rows indicating that he matches with 2 users. For user 4 the corresponding id is null indicating that he does not match with any other user.

Wrapping it all together now, we can group by the s1.user_id field and just check if any value exists true for a user where `s2.user_id` IS `NOT NULL`.

**Final query**
```sql
SELECT
    s1.user_id
    , (CASE WHEN s2.user_id IS NOT NULL THEN 1 ELSE 0 END) AS overlap
FROM subscriptions AS s1
LEFT JOIN subscriptions AS s2
    ON s1.user_id != s2.user_id
        AND s1.start_date <= s2.end_date
        AND s1.end_date >= s2.start_date
GROUP BY s1.user_id
```

We used the `CASE` clause to label 1 and 0 depending on the s2.user_id value for a given user. The final output looks like this -
![sura-sql-tricky-7](https://user-images.githubusercontent.com/12711066/158301705-b89e24ee-1092-4dc5-8cfa-7736ad9ca59b.png)

Before concluding, I would like to suggest a good book on SQL which I thoroughly enjoyed and found very useful. `SQL Cookbook: Query Solutions and Techniques for Database Developers (Cookbooks (O’Reilly))`

### Conclusion
 
Mastering SQL requires lots of practice. In this article, I took 5 tricky questions and explained the approaches to solve them. The specialty of SQL is that each query can be written in many different ways. Do feel free to share your approaches in the responses. I hope you learned something new today!
