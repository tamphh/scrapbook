### Data sample

```SQL
CREATE TABLE orders(
  id BINARY(16),
  order_number INT,
  customer_number INT,
  customer_name VARCHAR(90),
  order_date DATE,
  order_amount DECIMAL(13,2),
  PRIMARY KEY (`id`)
);
 
INSERT INTO orders VALUES
  (UNHEX('11E92BDEA738CEB7B78E0242AC110002'), 100, 5001, 'Wayne Enterprises', STR_TO_DATE('11-14-2018','%m-%d-%Y'), 100.00),
  (UNHEX('11E92BDEA73910BBB78E0242AC110002'), 101, 6002, 'Star Labs', STR_TO_DATE('11-15-2018','%m-%d-%Y'), 200.00),
  (UNHEX('11E92BDEA7395C95B78E0242AC110002'), 102, 7003, 'Daily Planet', STR_TO_DATE('11-15-2018','%m-%d-%Y'), 150.00),
  (UNHEX('11E92BDEA739A057B78E0242AC110002'), 103, 5001, 'Wayne Enterprises', STR_TO_DATE('11-21-2018','%m-%d-%Y'), 110.00),
  (UNHEX('11E92BDEA739F892B78E0242AC110002'), 104, 6002, 'Star Labs', STR_TO_DATE('11-22-2018','%m-%d-%Y'), 175.00),
  (UNHEX('11E92BE00BADD97CB78E0242AC110002'), 105, 6002, 'Star Labs', STR_TO_DATE('11-23-2018','%m-%d-%Y'), 117.00),
  (UNHEX('11E92BE00BAE15ACB78E0242AC110002'), 106, 7003, 'Daily Planet', STR_TO_DATE('11-24-2018','%m-%d-%Y'), 255.00),
  (UNHEX('11E92BE00BAE59FEB78E0242AC110002'), 107, 5001, 'Wayne Enterprises', STR_TO_DATE('12-07-2018','%m-%d-%Y'), 321.00),
  (UNHEX('11E92BE00BAE9D7EB78E0242AC110002'), 108, 6002, 'Star Labs', STR_TO_DATE('12-14-2018','%m-%d-%Y'), 55.00),
  (UNHEX('11E92BE00BAED1A4B78E0242AC110002'), 109, 7003, 'Daily Planet', STR_TO_DATE('12-15-2018','%m-%d-%Y'), 127.00),
  (UNHEX('11E92BE021E2DF22B78E0242AC110002'), 110, 6002, 'Star Labs', STR_TO_DATE('12-15-2018','%m-%d-%Y'), 133.00),
  (UNHEX('11E92BE021E31638B78E0242AC110002'), 111, 5001, 'Wayne Enterprises', STR_TO_DATE('12-17-2018','%m-%d-%Y'), 145.00),
  (UNHEX('11E92BE021E35474B78E0242AC110002'), 112, 7003, 'Daily Planet', STR_TO_DATE('12-21-2018','%m-%d-%Y'), 111.00),
  (UNHEX('11E92BE021E39950B78E0242AC110002'), 113, 6002, 'Star Labs', STR_TO_DATE('12-31-2018','%m-%d-%Y'), 321.00),
  (UNHEX('11E92BE021E3CEC5B78E0242AC110002'), 114, 6002, 'Star Labs', STR_TO_DATE('01-03-2019','%m-%d-%Y'), 223.00),
  (UNHEX('11E92BE035EF4BE5B78E0242AC110002'), 115, 6002, 'Star Labs', STR_TO_DATE('01-05-2019','%m-%d-%Y'), 179.00),
  (UNHEX('11E92BE035EF970DB78E0242AC110002'), 116, 5001, 'Wayne Enterprises', STR_TO_DATE('01-14-2019','%m-%d-%Y'), 180.00),
  (UNHEX('11E92BE035EFD540B78E0242AC110002'), 117, 7003, 'Daily Planet', STR_TO_DATE('01-21-2019','%m-%d-%Y'), 162.00),
  (UNHEX('11E92BE035F01B8AB78E0242AC110002'), 118, 5001, 'Wayne Enterprises', STR_TO_DATE('02-02-2019','%m-%d-%Y'), 133.00),
  (UNHEX('11E92BE035F05EF0B78E0242AC110002'), 119, 7003, 'Daily Planet', STR_TO_DATE('02-05-2019','%m-%d-%Y'), 55.00),
  (UNHEX('11E92BE0480B3CBAB78E0242AC110002'), 120, 5001, 'Wayne Enterprises', STR_TO_DATE('02-08-2019','%m-%d-%Y'), 25.00),
  (UNHEX('11E92BE25A9A3D6DB78E0242AC110002'), 121, 6002, 'Star Labs', STR_TO_DATE('02-08-2019','%m-%d-%Y'), 222.00);
```

### Query
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

**Note** using the ```:= operand``` allows us to create a variable on the fly without requiring the SET command.

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
