_This post is part of the "SQL Recipes" series, where I provide short patterns for solving common SQL data analysis tasks._

Suppose we want to compare each data record with its neighbors based on some column value. For example:

-   Compare sales from one month to the previous month (month-over-month or MoM change) or to the same month a year ago (year-over-year or YoY change).
-   Compare financial results for a given period to the same period in the previous year (like-for-like or LFL analysis).
-   Observe the daily difference in stock prices to understand market trends.
-   Calculate the difference in traffic between days of the week to plan capacity changes.

The solution is to use the `lag()` function over an SQL window ordered by target columns.

## Example

Let's compare the company's `expenses` for each month to the previous month in absolute terms:

```
select
  year, month,
  expense,
  expense - lag(expense) over w as diff
from expenses
window w as (order by year, month)
order by year, month;
```

The `lag(value, offset)` function returns the `value` of the record that is `offset` rows behind the current one. By default, the offset is 1 and can be omitted.

Now let's calculate the relative change from month to month:

```
select
  year, month, expense,
  round(
    (expense - lag(expense) over w)*100.0 / lag(expense) over w
  ) as "diff %"
from expenses
window w as (order by year, month)
order by year, month;
```

## Alternatives

Suppose we want to compare quarterly `sales` with the previous year. This is where the `offset` parameter comes in handy:

```
with data as (
  select
    year, quarter,
    lag(amount, 4) over w as prev,
    amount as current,
    round(amount*100.0 / lag(amount, 4) over w) as "increase %"
  from sales
  window w as (order by year, quarter)
)
select
  quarter,
  prev as y2019,
  current as y2020,
  "increase %"
from data
where year = 2020
order by quarter;
```

Looking back 4 quarters with `lag(amount, 4)` gives us the same quarter but from the previous year.

There is also a `lead()` function. It works just like `lag()`, except that it looks forward instead of backward.

## Compatibility

All major vendors support the `lag()` and `lead()` window functions. Some of them, such as MS SQL and Oracle, do not support the `window` clause. In these cases, we can inline the window definition:

```
select
  year, month, expense,
  expense - lag(expense) over (
    order by year, month
  ) as diff
from expenses
order by year, month;
```

We can also rewrite the query without window functions:

```
select
  cur.year, cur.month, cur.expense,
  cur.expense - prev.expense as diff
from expenses cur
left join expenses prev on
  cur.year = prev.year and
  cur.month - 1 = prev.month
order by cur.year, cur.month;
```

Want to learn more about window functions? Read my book — [**SQL Window Functions Explained**](https://antonz.org/sql-window-functions-book/)

 _[**Subscribe**](https://antonz.org/subscribe/) to keep up with new posts._
