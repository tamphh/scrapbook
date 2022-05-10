# 5 Most Common SQL mistakes you should avoid
### Learn how to speed up the execution of your SQL queries

SQL is one of the most used programming languages for querying relational big data. In SQL, there could be multiple ways of creating your data table but it is important to know and follow the right (optimal) way so that you don't have to wait for hours for the execution of your code.

In this blog, I will take you through the 5 most common SQL programming mistakes that you should avoid in order to optimize your SQL queries.

## 1. Don’t use `Select *`: 
`Select *` outputs all the columns of a data table, it is an expensive operation and increases the execution time of the query. The ideal way is to select only the relevant columns in your subquery or the output table.
For example, imagine if we want to get the order id from the Orders table then we should select only the OrderID column instead of selecting all the columns using `select *.`
```sql
# Wrong way  
SELECT * FROM Orders

# Optimal way 
SELECT OrderID FROM Orders
```

## 2. Don’t use `having` instead of `where`: 
`Having` clause is used to apply a filter on the aggregated columns (sum, min, max, etc.) created using the group by operation. But sometimes, programmers use the `having` clause (instead of the `where` clause) to filter the non aggregated columns too.

For example, in order to find the total orders executed by the employee with employee id 3, filtering using the ‘having’ clause will give unexpected results.
```sql
# Wrong way - having should not be used to apply filter on non-aggregated column (EmployeeID in this example)
SELECT OrderDate, count(OrderID) FROM Orders
group by OrderDate
having EmployeeID = 3


# Right Way - Where should be used to apply filter on non-aggregated column. 
SELECT OrderDate, count(OrderID) FROM Orders
where EmployeeID = 3
group by OrderDate
```

## 3. Don’t Use `where` for joining: 
Some people perform the inner join using the `where` clause, instead of using the `inner join` clause. Although the performance is similar for both the syntax (the result of query optimization), it is not recommended to join using the `where` clause due to the following reasons:

i. Using the `where` clause for both filtering and joining affects readability and understanding.

ii. The usage of the `where` clause for joining is very limited as it cannot perform any other join apart from the inner join.

```sql
# Wrong way - using where clause 
SELECT  Orders.OrderID, Orders.CustomerID, Customers.ContactName
FROM Orders, Customers
where Orders.CustomerID = Customers.CustomerID


# Right way - using inner join clause 
SELECT  Orders.OrderID, Orders.CustomerID, Customers.ContactName
FROM Orders
inner join 
Customers
on Orders.CustomerID = Customers.CustomerID
```

## 4. Don’t Use Distinct: 
The Distinct clause is used to find the distinct rows corresponding to the selected columns by dropping the duplicate rows. The `Distinct` clause is a time-consuming operation in SQL and the alternative is to use `group by`. For example, the below queries find the count of orders from the order details table:
```sql
# Expensive operation - count distinct order ids - using distinct 
SELECT count(distinct OrderID)
FROM OrderDetails

# Right way - count distinct order ids - using groupby  
select count(*) 
from
(SELECT OrderID
FROM OrderDetails
group by OrderID)
```

## Avoid Predicates in filtering: 
Predicate is an expression that equates to a boolean value i.e. True or False. Using predicates to perform filtering operation slows down the execution time as the predicates do not use the indexes (SQL index is a lookup table for quick retrieval). So, other alternatives should be used for filtering. For example, if we want to find the suppliers who have a phone number starting with (171) code.

```sql

# expensive way 
SELECT SupplierID,SupplierName FROM Suppliers
where SUBSTR(Phone, 1, 5) = '(171)'

# right way 
SELECT SupplierID,SupplierName FROM Suppliers
where Phone like  '(171)%'
```

source: https://towardsdatascience.com/5-most-common-sql-mistakes-you-should-avoid-dd4eb4088f0c




