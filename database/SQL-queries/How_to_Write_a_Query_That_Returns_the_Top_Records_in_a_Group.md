```SQL
SELECT order_number, customer_number, customer_name, order_date,
  YEAR(order_date) AS order_year, 
  MONTH(order_date) AS order_month, 
  order_amount, 
  @order_rank := IF(@current_month = MONTH(order_date),
  @order_rank + 1, 1) AS order_rank,
  @current_month := MONTH(order_date) 
FROM orders
ORDER BY order_year, order_month, order_amount DESC;
```
In our example SELECT statement we’re getting all the fields from the table along with getting the YEAR from the order date as well as the MONTH. 
Since our goal is to rank the orders by month 
I’m creating a temporary MySQL variable called ```@current_month``` that will keep track of each month. 
On every change of month we reset the ```@order_rank``` variable to one, otherwise we increment by one.

**Note** using the := operand allows us to create a variable on the fly without requiring the SET command.

**2nd Note** keep in mind this SELECT statement will rank all of the records in our table. 
Normally you’d want to have a WHERE clause that limits the size of the result set. 
Perhaps by customer or date range.

You can see that the orders are sorted by year and month and then by order amount in descending sequence. The new order_rank column is included that ranks every order in 1–2–3 sequence by month.
Now we can include this query as a subquery to a SELECT that only pulls the top 3 orders out of every group. That final query looks like this:
```SQL
SELECT customer_number, customer_name, order_number, order_date, order_amount 
FROM 
  (SELECT order_number, customer_number, customer_name, order_date,
    YEAR(order_date) AS order_year, 
    MONTH(order_date) AS order_month,
    order_amount, 
    @order_rank := IF(@current_month = MONTH(order_date), 
    @order_rank + 1, 1) AS order_rank,
    @current_month := MONTH(order_date) 
   FROM orders
   ORDER BY order_year, order_month, order_amount DESC) ranked_orders 
WHERE order_rank <= 3;
```
Source: https://towardsdatascience.com/mysql-how-to-write-a-query-that-returns-the-top-records-in-a-group-12865695f436
