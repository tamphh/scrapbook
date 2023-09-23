_This post is part of the "SQL Recipes" series, where I provide short patterns for solving common SQL data analysis tasks._

Suppose we want to create a ranking, where the position of each record is determined by the value of one or more columns.

The solution is to use the `rank()` function over an SQL window ordered by target columns.

## Example

Let's rank `employees` by salary:

```
select
  rank() over w as "rank",
  name, department, salary
from employees
window w as (order by salary desc)
order by "rank", id;
```

The `rank()` function assigns each employee a rank according to their salary (`order by salary desc`). Note that employees with the same salary receive the same rank (Henry and Irene, Cindy and Dave).

## Alternatives

We can use `dense_rank()` instead of `rank()` to avoid "gaps" in the ranking:

```
select
  dense_rank() over w as "rank",
  name, department, salary
from employees
window w as (order by salary desc)
order by "rank", id;
```

Note that Alice is ranked #3 and Grace is ranked #5, whereas previously they were ranked #4 and #7, respectively.

## Compatibility

All major vendors support the `rank()` and `dense_rank()` window functions. Some of them, such as MS SQL and Oracle, do not support the `window` clause. In these cases, we can inline the window definition:

```
select
  rank() over (
    order by salary desc
  ) as "rank",
  name, department, salary
from employees
order by "rank", id;
```

We can also rewrite the query without window functions:

```
select
  (
    select count(*)
    from employees as e2
    where e2.salary > e1.salary
  ) + 1 as "rank",
  e1.name, e1.department, e1.salary
from employees as e1
order by "rank", e1.id;
```

| rank | name | department | salary |
| --- | --- | --- | --- |
| 1 | Frank | it | 120 |
| 2 | Henry | it | 104 |
| 2 | Irene | it | 104 |
| 4 | Alice | sales | 100 |
| 5 | Cindy | sales | 96 |
| 5 | Dave | sales | 96 |
| 7 | Grace | it | 90 |
| 8 | Emma | it | 84 |
| 9 | Bob | hr | 78 |
| 10 | Diane | hr | 70 |

Want to learn more about window functions? Read my book — [**SQL Window Functions Explained**](https://antonz.org/sql-window-functions-book/)

 _[**Subscribe**](https://antonz.org/subscribe/) to keep up with new posts._
