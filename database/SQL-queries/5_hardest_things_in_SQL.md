![The 5 Hardest Things to do in SQL](https://www.kdnuggets.com/wp-content/uploads/berry_5_hardest_things_sql_1-scaled.jpg)  
[Sql vector created by freepik - www.freepik.com](https://www.freepik.com/vectors/sql)

 

Many of us have experienced the core power of speed and efficiency delivered by centralizing compute within the Cloud Data Warehouse. While this is true, many of us have also realized that, like with anything, this value comes with its own set of downsides. 

One of the primary drawbacks of this approach is that you must learn and execute queries in different languages, specifically SQL. While writing SQL is faster and less expensive than standing up a secondary infrastructure to run python (on your laptop or in-office servers), it comes with many different complexities depending on what information the data analyst wants to extract from the cloud warehouse. The switch over to cloud data warehouses increases the utility of complex SQL versus python. Having been through this experience myself, I decided to record the specific transformations that are the most painful to learn and perform in SQL and provide the actual SQL needed to alleviate some of this pain for my readers. 

To aid in your workflow, you’ll notice that I provide examples of the data structure before and after the transform is executed, so you can follow along and validate your work. I have also provided the actual SQL needed to perform each of the 5 hardest transformations. You’ll need new SQL to perform the transformation across multiple projects as your data changes. We’ve provided links to dynamic SQL for each transformation so you can continue to capture the SQL needed for your analysis on an as needed basis! 

## Date Spines

It is not clear where the term date spine originated, but even those who don’t know the term are probably familiar with what it is.

Imagine you are analyzing your daily sales data, and it looks like this:

<table><tbody><tr><td>sales_date</td><td>product</td><td>sales</td></tr><tr><td>2022-04-14</td><td>A</td><td>46</td></tr><tr><td>2022-04-14</td><td>B</td><td>409</td></tr><tr><td>2022-04-15</td><td>A</td><td>17</td></tr><tr><td>2022-04-15</td><td>B</td><td>480</td></tr><tr><td>2022-04-18</td><td>A</td><td>65</td></tr><tr><td>2022-04-19</td><td>A</td><td>45</td></tr><tr><td>2022-04-19</td><td>B</td><td>411</td></tr></tbody></table>

No sales happened on the 16th and 17th, so the rows are completely missing. If we were trying to calculate _average daily sales_, or build a time series forecast model, this format would be a major problem. What we need to do is insert rows for the missing days.

Here is the basic concept:

1.  Generate or select unique dates
2.  Generate or select unique products
3.  Cross Join (cartesian product) all combinations of 1&2
4.  Outer Join #3 to your original data

[Customizable SQL for Datespine](https://app.rasgoml.com/sql?transformName=%22datespine_groups%22&tableState=%7B%22tables%22%3A%5B%7B%22name%22%3A%22My_First_Table%22%2C%22columns%22%3A%5B%7B%22name%22%3A%22sales_date%22%2C%22dataType%22%3A%22date%22%7D%2C%7B%22name%22%3A%22product%22%2C%22dataType%22%3A%22string%22%7D%2C%7B%22name%22%3A%22sales%22%2C%22dataType%22%3A%22number%22%7D%5D%7D%5D%2C%22baseTableName%22%3A%22My_First_Table%22%2C%22ddl%22%3A%22%22%7D&formState=%7B%22arguments%22%3A%7B%22group_by%22%3A%7B%22argType%22%3A%22column_list%22%2C%22cols%22%3A%5B%7B%22id%22%3A1%2C%22columnName%22%3A%22product%22%2C%22displayName%22%3A%22product%22%2C%22dataType%22%3A%22string%22%2C%22dwColumnId%22%3A1%7D%5D%7D%2C%22date_col%22%3A%7B%22argType%22%3A%22column%22%2C%22col%22%3A%7B%22id%22%3A0%2C%22columnName%22%3A%22sales_date%22%2C%22displayName%22%3A%22sales_date%22%2C%22dataType%22%3A%22date%22%2C%22dwColumnId%22%3A0%7D%7D%2C%22start_timestamp%22%3A%7B%22argType%22%3A%22timestamp%22%2C%22value%22%3A%222020-01-01T00%3A00%22%7D%2C%22end_timestamp%22%3A%7B%22argType%22%3A%22timestamp%22%2C%22value%22%3A%222023-01-01T00%3A00%22%7D%2C%22interval_type%22%3A%7B%22argType%22%3A%22date_part%22%2C%22value%22%3A%22day%22%7D%2C%22group_bounds%22%3A%7B%22argType%22%3A%22value%22%2C%22value%22%3A%22mixed%22%7D%7D%2C%22transformName%22%3A%22datespine_groups%22%7D)


```sql
WITH GLOBAL_SPINE AS (
  SELECT 
    ROW_NUMBER() OVER (
      ORDER BY 
        NULL
    ) as INTERVAL_ID, 
    DATEADD(
      'day', 
      (INTERVAL_ID - 1), 
      '2020-01-01T00:00' :: timestamp_ntz
    ) as SPINE_START, 
    DATEADD(
      'day', INTERVAL_ID, '2020-01-01T00:00' :: timestamp_ntz
    ) as SPINE_END 
  FROM 
    TABLE (
      GENERATOR(ROWCOUNT => 1097)
    )
), 
GROUPS AS (
  SELECT 
    product, 
    MIN(sales_date) AS LOCAL_START, 
    MAX(sales_date) AS LOCAL_END 
  FROM 
    My_First_Table 
  GROUP BY 
    product
), 
GROUP_SPINE AS (
  SELECT 
    product, 
    SPINE_START AS GROUP_START, 
    SPINE_END AS GROUP_END 
  FROM 
    GROUPS G CROSS 
    JOIN LATERAL (
      SELECT 
        SPINE_START, 
        SPINE_END 
      FROM 
        GLOBAL_SPINE S 
      WHERE 
        S.SPINE_START >= G.LOCAL_START
    )
) 
SELECT 
  G.product AS GROUP_BY_product, 
  GROUP_START, 
  GROUP_END, 
  T.* 
FROM 
  GROUP_SPINE G 
  LEFT JOIN My_First_Table T ON sales_date >= G.GROUP_START 
  AND sales_date < G.GROUP_END 
  AND G.product = T.product;
```

The end result will look like this:

<table><tbody><tr><td>sales_date</td><td>product</td><td>sales</td></tr><tr><td>2022-04-14</td><td>A</td><td>46</td></tr><tr><td>2022-04-14</td><td>B</td><td>409</td></tr><tr><td>2022-04-15</td><td>A</td><td>17</td></tr><tr><td>2022-04-15</td><td>B</td><td>480</td></tr><tr><td>2022-04-16</td><td>A</td><td>0</td></tr><tr><td>2022-04-16</td><td>B</td><td>0</td></tr><tr><td>2022-04-17</td><td>A</td><td>0</td></tr><tr><td>2022-04-17</td><td>B</td><td>0</td></tr><tr><td>2022-04-18</td><td>A</td><td>65</td></tr><tr><td>2022-04-18</td><td>B</td><td>0</td></tr><tr><td>2022-04-19</td><td>A</td><td>45</td></tr><tr><td>2022-04-19</td><td>B</td><td>411</td></tr></tbody></table>

## Pivot / Unpivot

Sometimes, when doing an analysis, you want to restructure the table. For instance, we might have a list of students, subjects, and grades, but we want to break out subjects into each column. We all know and love Excel because of its pivot tables. But have you ever tried to do it in SQL? Not only does every database have annoying differences in how PIVOT is supported, but the syntax is unintuitive and easily forgettable. 

Before:

<table><tbody><tr><td>Student</td><td>Subject</td><td>Grade</td></tr><tr><td>Jared</td><td>Mathematics</td><td>61</td></tr><tr><td>Jared</td><td>Geography</td><td>94</td></tr><tr><td>Jared</td><td>Phys Ed</td><td>98</td></tr><tr><td>Patrick</td><td>Mathematics</td><td>99</td></tr><tr><td>Patrick</td><td>Geography</td><td>93</td></tr><tr><td>Patrick</td><td>Phys Ed</td><td>4</td></tr></tbody></table>

[Customizable SQL for Pivot](https://app.rasgoml.com/sql?transformName=%22pivot%22&tableState=%7B%22tables%22%3A%5B%7B%22name%22%3A%22My_First_Table%22%2C%22columns%22%3A%5B%7B%22name%22%3A%22Student%22%2C%22dataType%22%3A%22string%22%7D%2C%7B%22name%22%3A%22Subject%22%2C%22dataType%22%3A%22string%22%7D%2C%7B%22name%22%3A%22Grade%22%2C%22dataType%22%3A%22number%22%7D%5D%7D%5D%2C%22baseTableName%22%3A%22My_First_Table%22%2C%22ddl%22%3A%22%22%7D&formState=%7B%22arguments%22%3A%7B%22dimensions%22%3A%7B%22argType%22%3A%22column_list%22%2C%22cols%22%3A%5B%7B%22id%22%3A0%2C%22columnName%22%3A%22Student%22%2C%22displayName%22%3A%22Student%22%2C%22dataType%22%3A%22string%22%2C%22dwColumnId%22%3A0%7D%5D%7D%2C%22pivot_column%22%3A%7B%22argType%22%3A%22column%22%2C%22col%22%3A%7B%22id%22%3A2%2C%22columnName%22%3A%22Grade%22%2C%22displayName%22%3A%22Grade%22%2C%22dataType%22%3A%22number%22%2C%22dwColumnId%22%3A2%7D%7D%2C%22value_column%22%3A%7B%22argType%22%3A%22column%22%2C%22col%22%3A%7B%22id%22%3A1%2C%22columnName%22%3A%22Subject%22%2C%22displayName%22%3A%22Subject%22%2C%22dataType%22%3A%22string%22%2C%22dwColumnId%22%3A1%7D%7D%2C%22agg_method%22%3A%7B%22argType%22%3A%22agg%22%2C%22value%22%3A%22AVG%22%7D%2C%22list_of_vals%22%3A%7B%22argType%22%3A%22string_list%22%2C%22values%22%3A%5B%22Mathematics%22%2C%22Geography%22%2C%22Phys%20Ed%22%5D%7D%7D%2C%22transformName%22%3A%22pivot%22%7D)

```sql
SELECT Student, MATHEMATICS, GEOGRAPHY, PHYS_ED
FROM ( SELECT Student, Grade, Subject FROM skool)
PIVOT ( AVG ( Grade ) FOR Subject IN ( 'Mathematics', 'Geography', 'Phys Ed' ) ) as p
( Student, MATHEMATICS, GEOGRAPHY, PHYS_ED );
```

Result:

<table><tbody><tr><td>Student</td><td>Mathematics</td><td>Geography</td><td>Phys Ed</td></tr><tr><td>Jared</td><td>61</td><td>94</td><td>98</td></tr><tr><td>Patrick</td><td>99</td><td>93</td><td>4</td></tr></tbody></table>

## One-hot Encoding

This one isn’t necessarily difficult but is time-consuming. Most data scientists don’t consider doing one-hot-encoding in SQL. Although the syntax is simple, they would rather transfer the data out of the data warehouse than the tedious task of writing a 26-line CASE statement. We don’t blame them! 

However, we recommend taking advantage of your data warehouse and its processing power. Here is an example using STATE as a column to one-hot-encode.

Before:

<table><tbody><tr><td>Babyname</td><td>State</td><td>Qty</td></tr><tr><td>Alice</td><td>AL</td><td>156</td></tr><tr><td>Alice</td><td>AK</td><td>146</td></tr><tr><td>Alice</td><td>PA</td><td>654</td></tr><tr><td>…</td><td>…</td><td>…</td></tr><tr><td>Zelda</td><td>NY</td><td>417</td></tr><tr><td>Zelda</td><td>AL</td><td>261</td></tr><tr><td>Zelda</td><td>CO</td><td>321</td></tr></tbody></table>

[Customizable SQL for One-Hot Encode](https://app.rasgoml.com/sql?transformName=%22one_hot_encode%22&tableState=%7B%22tables%22%3A%5B%7B%22name%22%3A%22My_First_Table%22%2C%22columns%22%3A%5B%7B%22name%22%3A%22BABYNAME%22%2C%22dataType%22%3A%22string%22%7D%2C%7B%22name%22%3A%22STATE%22%2C%22dataType%22%3A%22string%22%7D%2C%7B%22name%22%3A%22Qty%22%2C%22dataType%22%3A%22number%22%7D%5D%7D%5D%2C%22baseTableName%22%3A%22My_First_Table%22%2C%22ddl%22%3A%22%22%7D&formState=%7B%22arguments%22%3A%7B%22column%22%3A%7B%22argType%22%3A%22column%22%2C%22col%22%3A%7B%22id%22%3A1%2C%22columnName%22%3A%22STATE%22%2C%22displayName%22%3A%22STATE%22%2C%22dataType%22%3A%22string%22%2C%22dwColumnId%22%3A1%7D%7D%2C%22list_of_vals%22%3A%7B%22argType%22%3A%22string_list%22%2C%22values%22%3A%5B%22AL%22%2C%22AK%22%2C%22AZ%22%2C%22AR%22%2C%22CA%22%2C%22CO%22%2C%22CT%22%2C%22DE%22%2C%22FL%22%2C%22GA%22%2C%22HI%22%2C%22ID%22%2C%22IL%22%2C%22IN%22%2C%22IA%22%2C%22KS%22%2C%22KY%22%2C%22LA%22%2C%22ME%22%2C%22MD%22%2C%22MA%22%2C%22MI%22%2C%22MN%22%2C%22MS%22%2C%22MO%22%2C%22MT%22%2C%22NE%22%2C%22NV%22%2C%22NH%22%2C%22NJ%22%2C%22NM%22%2C%22NY%22%2C%22NC%22%2C%22ND%22%2C%22OH%22%2C%22OK%22%2C%22OR%22%2C%22PA%22%2C%22RI%22%2C%22SC%22%2C%22SD%22%2C%22TN%22%2C%22TX%22%2C%22UT%22%2C%22VT%22%2C%22VA%22%2C%22WA%22%2C%22WV%22%2C%22WI%22%2C%22WY%22%5D%7D%7D%2C%22transformName%22%3A%22one_hot_encode%22%7D)

```sql
SELECT *,
    CASE WHEN State = 'AL' THEN 1 ELSE 0 END as STATE_AL, 
    CASE WHEN State = 'AK' THEN 1 ELSE 0 END as STATE_AK, 
    CASE WHEN State = 'AZ' THEN 1 ELSE 0 END as STATE_AZ, 
    CASE WHEN State = 'AR' THEN 1 ELSE 0 END as STATE_AR, 
    CASE WHEN State = 'AS' THEN 1 ELSE 0 END as STATE_AS, 
    CASE WHEN State = 'CA' THEN 1 ELSE 0 END as STATE_CA, 
    CASE WHEN State = 'CO' THEN 1 ELSE 0 END as STATE_CO, 
    CASE WHEN State = 'CT' THEN 1 ELSE 0 END as STATE_CT, 
    CASE WHEN State = 'DC' THEN 1 ELSE 0 END as STATE_DC, 
    CASE WHEN State = 'FL' THEN 1 ELSE 0 END as STATE_FL, 
    CASE WHEN State = 'GA' THEN 1 ELSE 0 END as STATE_GA, 
    CASE WHEN State = 'HI' THEN 1 ELSE 0 END as STATE_HI, 
    CASE WHEN State = 'ID' THEN 1 ELSE 0 END as STATE_ID, 
    CASE WHEN State = 'IL' THEN 1 ELSE 0 END as STATE_IL, 
    CASE WHEN State = 'IN' THEN 1 ELSE 0 END as STATE_IN, 
    CASE WHEN State = 'IA' THEN 1 ELSE 0 END as STATE_IA, 
    CASE WHEN State = 'KS' THEN 1 ELSE 0 END as STATE_KS, 
    CASE WHEN State = 'KY' THEN 1 ELSE 0 END as STATE_KY, 
    CASE WHEN State = 'LA' THEN 1 ELSE 0 END as STATE_LA, 
    CASE WHEN State = 'ME' THEN 1 ELSE 0 END as STATE_ME, 
    CASE WHEN State = 'MD' THEN 1 ELSE 0 END as STATE_MD, 
    CASE WHEN State = 'MA' THEN 1 ELSE 0 END as STATE_MA, 
    CASE WHEN State = 'MI' THEN 1 ELSE 0 END as STATE_MI, 
    CASE WHEN State = 'MN' THEN 1 ELSE 0 END as STATE_MN, 
    CASE WHEN State = 'MS' THEN 1 ELSE 0 END as STATE_MS, 
    CASE WHEN State = 'MO' THEN 1 ELSE 0 END as STATE_MO, 
    CASE WHEN State = 'MT' THEN 1 ELSE 0 END as STATE_MT, 
    CASE WHEN State = 'NE' THEN 1 ELSE 0 END as STATE_NE, 
    CASE WHEN State = 'NV' THEN 1 ELSE 0 END as STATE_NV, 
    CASE WHEN State = 'NH' THEN 1 ELSE 0 END as STATE_NH, 
    CASE WHEN State = 'NJ' THEN 1 ELSE 0 END as STATE_NJ, 
    CASE WHEN State = 'NM' THEN 1 ELSE 0 END as STATE_NM, 
    CASE WHEN State = 'NY' THEN 1 ELSE 0 END as STATE_NY, 
    CASE WHEN State = 'NC' THEN 1 ELSE 0 END as STATE_NC, 
    CASE WHEN State = 'ND' THEN 1 ELSE 0 END as STATE_ND, 
    CASE WHEN State = 'OH' THEN 1 ELSE 0 END as STATE_OH, 
    CASE WHEN State = 'OK' THEN 1 ELSE 0 END as STATE_OK, 
    CASE WHEN State = 'OR' THEN 1 ELSE 0 END as STATE_OR, 
    CASE WHEN State = 'PA' THEN 1 ELSE 0 END as STATE_PA, 
    CASE WHEN State = 'RI' THEN 1 ELSE 0 END as STATE_RI, 
    CASE WHEN State = 'SC' THEN 1 ELSE 0 END as STATE_SC, 
    CASE WHEN State = 'SD' THEN 1 ELSE 0 END as STATE_SD, 
    CASE WHEN State = 'TN' THEN 1 ELSE 0 END as STATE_TN, 
    CASE WHEN State = 'TX' THEN 1 ELSE 0 END as STATE_TX, 
    CASE WHEN State = 'UT' THEN 1 ELSE 0 END as STATE_UT, 
    CASE WHEN State = 'VT' THEN 1 ELSE 0 END as STATE_VT, 
    CASE WHEN State = 'VA' THEN 1 ELSE 0 END as STATE_VA, 
    CASE WHEN State = 'WA' THEN 1 ELSE 0 END as STATE_WA, 
    CASE WHEN State = 'WV' THEN 1 ELSE 0 END as STATE_WV, 
    CASE WHEN State = 'WI' THEN 1 ELSE 0 END as STATE_WI, 
    CASE WHEN State = 'WY' THEN 1 ELSE 0 END as STATE_WY
FROM BABYTABLE;
```

Result:

<table><tbody><tr><td>Babyname</td><td>State</td><td>State_AL</td><td>State_AK</td><td>…</td><td>State_CO</td><td>Qty</td></tr><tr><td>Alice</td><td>AL</td><td>1</td><td>0</td><td>…</td><td>0</td><td>156</td></tr><tr><td>Alice</td><td>AK</td><td>0</td><td>1</td><td>…</td><td>0</td><td>146</td></tr><tr><td>Alice</td><td>PA</td><td>0</td><td>0</td><td>…</td><td>0</td><td>654</td></tr><tr><td>…</td><td>…</td><td></td><td></td><td>…</td><td></td><td>…</td></tr><tr><td>Zelda</td><td>NY</td><td>0</td><td>0</td><td>…</td><td>0</td><td>417</td></tr><tr><td>Zelda</td><td>AL</td><td>1</td><td>0</td><td>…</td><td>0</td><td>261</td></tr><tr><td>Zelda</td><td>CO</td><td>0</td><td>0</td><td>…</td><td>1</td><td>321</td></tr></tbody></table>

## Market Basket Analysis

When doing a market basket analysis or mining for association rules, the first step is often formatting the data to aggregate each transaction into a single record. This can be challenging for your laptop, but your data warehouse is designed to crunch this data efficiently.

Typical transaction data:

<table><tbody><tr><td>SALESORDERNUMBER</td><td>CUSTOMERKEY</td><td>ENGLISHPRODUCTNAME</td><td>LISTPRICE</td><td>WEIGHT</td><td>ORDERDATE</td></tr><tr><td>SO51247</td><td>11249</td><td>Mountain-200 Black</td><td>2294.99</td><td>23.77</td><td>1/1/2013</td></tr><tr><td>SO51247</td><td>11249</td><td>Water Bottle - 30 oz.</td><td>4.99</td><td></td><td>1/1/2013</td></tr><tr><td>SO51247</td><td>11249</td><td>Mountain Bottle Cage</td><td>9.99</td><td></td><td>1/1/2013</td></tr><tr><td>SO51246</td><td>25625</td><td>Sport-100 Helmet</td><td>34.99</td><td></td><td>12/31/2012</td></tr><tr><td>SO51246</td><td>25625</td><td>Water Bottle - 30 oz.</td><td>4.99</td><td></td><td>12/31/2012</td></tr><tr><td>SO51246</td><td>25625</td><td>Road Bottle Cage</td><td>8.99</td><td></td><td>12/31/2012</td></tr><tr><td>SO51246</td><td>25625</td><td>Touring-1000 Blue</td><td>2384.07</td><td>25.42</td><td>12/31/2012</td></tr></tbody></table>

[Customizable SQL for Market Basket](https://app.rasgoml.com/sql?transformName=%22market_basket%22&tableState=%7B%22tables%22%3A%5B%7B%22name%22%3A%22My_First_Table%22%2C%22columns%22%3A%5B%7B%22name%22%3A%22SALESORDERNUMBER%22%2C%22dataType%22%3A%22string%22%7D%2C%7B%22name%22%3A%22CUSTOMERKEY%22%2C%22dataType%22%3A%22string%22%7D%2C%7B%22name%22%3A%22ENGLISHPRODUCTNAME%22%2C%22dataType%22%3A%22string%22%7D%2C%7B%22name%22%3A%22LISTPRICE%22%2C%22dataType%22%3A%22float%22%7D%2C%7B%22name%22%3A%22WEIGHT%22%2C%22dataType%22%3A%22float%22%7D%2C%7B%22name%22%3A%22ORDERDATE%22%2C%22dataType%22%3A%22date%22%7D%5D%7D%5D%2C%22baseTableName%22%3A%22My_First_Table%22%2C%22ddl%22%3A%22%22%7D&formState=%7B%22arguments%22%3A%7B%22transaction_id%22%3A%7B%22argType%22%3A%22column%22%2C%22col%22%3A%7B%22id%22%3A0%2C%22columnName%22%3A%22SALESORDERNUMBER%22%2C%22displayName%22%3A%22SALESORDERNUMBER%22%2C%22dataType%22%3A%22string%22%2C%22dwColumnId%22%3A0%7D%7D%2C%22sep%22%3A%7B%22argType%22%3A%22value%22%2C%22value%22%3A%22%2C%20%22%7D%2C%22agg_column%22%3A%7B%22argType%22%3A%22column%22%2C%22col%22%3A%7B%22id%22%3A2%2C%22columnName%22%3A%22ENGLISHPRODUCTNAME%22%2C%22displayName%22%3A%22ENGLISHPRODUCTNAME%22%2C%22dataType%22%3A%22string%22%2C%22dwColumnId%22%3A2%7D%7D%7D%2C%22transformName%22%3A%22market_basket%22%7D)

```sql
WITH order_detail as (
  SELECT 
    SALESORDERNUMBER, 
    listagg(ENGLISHPRODUCTNAME, ', ') WITHIN group (
      order by 
        ENGLISHPRODUCTNAME
    ) as ENGLISHPRODUCTNAME_listagg, 
    COUNT(ENGLISHPRODUCTNAME) as num_products 
  FROM 
    transactions 
  GROUP BY 
    SALESORDERNUMBER
) 
SELECT 
  ENGLISHPRODUCTNAME_listagg, 
  count(SALESORDERNUMBER) as NumTransactions 
FROM 
  order_detail 
where 
  num_products > 1 
GROUP BY 
  ENGLISHPRODUCTNAME_listagg 
order by 
  count(SALESORDERNUMBER) desc;
```

Result:

<table><tbody><tr><td>NUMTRANSACTIONS</td><td>ENGLISHPRODUCTNAME_LISTAGG</td></tr><tr><td>207</td><td>Mountain Bottle Cage, Water Bottle - 30 oz.</td></tr><tr><td>200</td><td>Mountain Tire Tube, Patch Kit/8 Patches</td></tr><tr><td>142</td><td>LL Road Tire, Patch Kit/8 Patches</td></tr><tr><td>137</td><td>Patch Kit/8 Patches, Road Tire Tube</td></tr><tr><td>135</td><td>Patch Kit/8 Patches, Touring Tire Tube</td></tr><tr><td>132</td><td>HL Mountain Tire, Mountain Tire Tube, Patch Kit/8 Patches</td></tr></tbody></table>

## Time-Series Aggregations

Time series aggregations are not only used by data scientists but they’re used for analytics as well. What makes them difficult is that window functions require the data to be formatted correctly.

For example, if you want to calculate the average sales amount in the past 14 days, window functions require you to have all sales data broken up into one row per day. Unfortunately, anyone who has worked with sales data before knows that it is usually stored at the transaction level. This is where time-series aggregation comes in handy. You can create aggregated, historical metrics without reformatting the entire dataset. It also comes in handy if we want to add multiple metrics at one time:

-   Average sales in the past 14 days
-   Biggest purchase in last 6 months
-   Count Distinct product types in last 90 days

If you wanted to use window functions, each metric would need to be built independently with several steps.

A better way to handle this, is to use common table expressions (CTEs) to define each of the historical windows, pre-aggregated.

For example:

<table><tbody><tr><td>Transaction ID</td><td>Customer ID</td><td>Product Type</td><td>Purchase Amt</td><td>Transaction Date</td></tr><tr><td>65432</td><td>101</td><td>Grocery</td><td>101.14</td><td>2022-03-01</td></tr><tr><td>65493</td><td>101</td><td>Grocery</td><td>98.45</td><td>2022-04-30</td></tr><tr><td>65494</td><td>101</td><td>Automotive</td><td>239.98</td><td>2022-05-01</td></tr><tr><td>66789</td><td>101</td><td>Grocery</td><td>86.55</td><td>2022-05-22</td></tr><tr><td>66981</td><td>101</td><td>Pharmacy</td><td>14</td><td>2022-06-15</td></tr><tr><td>67145</td><td>101</td><td>Grocery</td><td>93.12</td><td>2022-06-22</td></tr></tbody></table>

[Customizable SQL for Time Series Aggregate SQL](https://app.rasgoml.com/sql?transformName=%22timeseries_agg%22&tableState=%7B%22tables%22%3A%5B%7B%22name%22%3A%22My_First_Table%22%2C%22columns%22%3A%5B%7B%22name%22%3A%22Transaction_ID%22%2C%22dataType%22%3A%22string%22%7D%2C%7B%22name%22%3A%22Customer_ID%22%2C%22dataType%22%3A%22string%22%7D%2C%7B%22name%22%3A%22Product_Type%22%2C%22dataType%22%3A%22string%22%7D%2C%7B%22name%22%3A%22Purchase_Amt%22%2C%22dataType%22%3A%22float%22%7D%2C%7B%22name%22%3A%22Transaction_Date%22%2C%22dataType%22%3A%22date%22%7D%5D%7D%5D%2C%22baseTableName%22%3A%22My_First_Table%22%2C%22ddl%22%3A%22%22%7D&formState=%7B%22arguments%22%3A%7B%22aggregations%22%3A%7B%22argType%22%3A%22agg_dict%22%2C%22aggDict%22%3A%7B%22Purchase_Amt%22%3A%7B%22AVG%22%3Atrue%2C%22MAX%22%3Atrue%7D%2C%22Transaction_ID%22%3A%7B%22COUNT%20DISTINCT%22%3Atrue%7D%7D%7D%2C%22date%22%3A%7B%22argType%22%3A%22column%22%2C%22col%22%3A%7B%22id%22%3A4%2C%22columnName%22%3A%22Transaction_Date%22%2C%22displayName%22%3A%22Transaction_Date%22%2C%22dataType%22%3A%22date%22%2C%22dwColumnId%22%3A4%7D%7D%2C%22offsets%22%3A%7B%22argType%22%3A%22int_list%22%2C%22values%22%3A%5B14%2C90%2C180%5D%7D%2C%22date_part%22%3A%7B%22argType%22%3A%22date_part%22%2C%22value%22%3A%22day%22%7D%2C%22group_by%22%3A%7B%22argType%22%3A%22column_list%22%2C%22cols%22%3A%5B%7B%22id%22%3A1%2C%22columnName%22%3A%22Customer_ID%22%2C%22displayName%22%3A%22Customer_ID%22%2C%22dataType%22%3A%22string%22%2C%22dwColumnId%22%3A1%7D%5D%7D%7D%2C%22transformName%22%3A%22timeseries_agg%22%7D)

```sql
WITH BASIC_OFFSET_14DAY AS (
  SELECT 
    A.CustomerID, 
    A.TransactionDate, 
    AVG(B.PurchaseAmount) as AVG_PURCHASEAMOUNT_PAST14DAY, 
    MAX(B.PurchaseAmount) as MAX_PURCHASEAMOUNT_PAST14DAY, 
    COUNT(DISTINCT B.TransactionID) as COUNT_DISTINCT_TRANSACTIONID_PAST14DAY
  FROM 
    My_First_Table A 
    INNER JOIN My_First_Table B ON A.CustomerID = B.CustomerID 
    AND 1 = 1 
  WHERE 
    B.TransactionDate >= DATEADD(day, -14, A.TransactionDate) 
    AND B.TransactionDate <= A.TransactionDate 
  GROUP BY 
    A.CustomerID, 
    A.TransactionDate
), 
BASIC_OFFSET_90DAY AS (
  SELECT 
    A.CustomerID, 
    A.TransactionDate, 
    AVG(B.PurchaseAmount) as AVG_PURCHASEAMOUNT_PAST90DAY, 
    MAX(B.PurchaseAmount) as MAX_PURCHASEAMOUNT_PAST90DAY, 
    COUNT(DISTINCT B.TransactionID) as COUNT_DISTINCT_TRANSACTIONID_PAST90DAY
  FROM 
    My_First_Table A 
    INNER JOIN My_First_Table B ON A.CustomerID = B.CustomerID 
    AND 1 = 1 
  WHERE 
    B.TransactionDate >= DATEADD(day, -90, A.TransactionDate) 
    AND B.TransactionDate <= A.TransactionDate 
  GROUP BY 
    A.CustomerID, 
    A.TransactionDate
), 
BASIC_OFFSET_180DAY AS (
  SELECT 
    A.CustomerID, 
    A.TransactionDate, 
    AVG(B.PurchaseAmount) as AVG_PURCHASEAMOUNT_PAST180DAY, 
    MAX(B.PurchaseAmount) as MAX_PURCHASEAMOUNT_PAST180DAY, 
    COUNT(DISTINCT B.TransactionID) as COUNT_DISTINCT_TRANSACTIONID_PAST180DAY
  FROM 
    My_First_Table A 
    INNER JOIN My_First_Table B ON A.CustomerID = B.CustomerID 
    AND 1 = 1 
  WHERE 
    B.TransactionDate >= DATEADD(day, -180, A.TransactionDate) 
    AND B.TransactionDate <= A.TransactionDate 
  GROUP BY 
    A.CustomerID, 
    A.TransactionDate
) 
SELECT 
  src.*, 
  BASIC_OFFSET_14DAY.AVG_PURCHASEAMOUNT_PAST14DAY, 
  BASIC_OFFSET_14DAY.MAX_PURCHASEAMOUNT_PAST14DAY, 
  BASIC_OFFSET_14DAY.COUNT_DISTINCT_TRANSACTIONID_PAST14DAY, 
  BASIC_OFFSET_90DAY.AVG_PURCHASEAMOUNT_PAST90DAY, 
  BASIC_OFFSET_90DAY.MAX_PURCHASEAMOUNT_PAST90DAY, 
  BASIC_OFFSET_90DAY.COUNT_DISTINCT_TRANSACTIONID_PAST90DAY, 
  BASIC_OFFSET_180DAY.AVG_PURCHASEAMOUNT_PAST180DAY, 
  BASIC_OFFSET_180DAY.MAX_PURCHASEAMOUNT_PAST180DAY, 
  BASIC_OFFSET_180DAY.COUNT_DISTINCT_TRANSACTIONID_PAST180DAY 
FROM 
  My_First_Table src 
  LEFT OUTER JOIN BASIC_OFFSET_14DAY ON BASIC_OFFSET_14DAY.TransactionDate = src.TransactionDate 
  AND BASIC_OFFSET_14DAY.CustomerID = src.CustomerID 
  LEFT OUTER JOIN BASIC_OFFSET_90DAY ON BASIC_OFFSET_90DAY.TransactionDate = src.TransactionDate 
  AND BASIC_OFFSET_90DAY.CustomerID = src.CustomerID 
  LEFT OUTER JOIN BASIC_OFFSET_180DAY ON BASIC_OFFSET_180DAY.TransactionDate = src.TransactionDate 
  AND BASIC_OFFSET_180DAY.CustomerID = src.CustomerID;
```

Result:

<table><tbody><tr><td>Transaction ID</td><td>Customer ID</td><td>Product Type</td><td>Purchase Amt</td><td>Transaction Date</td><td>Avg Sales Past 14 Days</td><td>Max Purchase Past 6 months</td><td>Count Distinct Product Type last 90 days</td></tr><tr><td>65432</td><td>101</td><td>Grocery</td><td>101.14</td><td>2022-03-01</td><td>101.14</td><td>101.14</td><td>1</td></tr><tr><td>65493</td><td>101</td><td>Grocery</td><td>98.45</td><td>2022-04-30</td><td>98.45</td><td>101.14</td><td>2</td></tr><tr><td>65494</td><td>101</td><td>Automotive</td><td>239.98</td><td>2022-05-01</td><td>169.21</td><td>239.98</td><td>2</td></tr><tr><td>66789</td><td>101</td><td>Grocery</td><td>86.55</td><td>2022-05-22</td><td>86.55</td><td>239.98</td><td>2</td></tr><tr><td>66981</td><td>101</td><td>Pharmacy</td><td>14</td><td>2022-06-15</td><td>14</td><td>239.98</td><td>3</td></tr><tr><td>67145</td><td>101</td><td>Grocery</td><td>93.12</td><td>2022-06-22</td><td>53.56</td><td>239.98</td><td>3</td></tr></tbody></table>

## Conclusion

I hope this piece helps shed some light on the different troubles that a data practitioner will encounter when operating within the modern data stack. SQL is a double-edged sword when it comes to querying the cloud warehouse. While centralizing the compute in the cloud data warehouse increases speed, it sometimes requires some extra SQL skills. I hope that this piece has helped answer questions and provides the syntax and background needed to tackle these problems. 

  **[Josh Berry](https://www.linkedin.com/in/joshberry022/)** ([**@Twitter**](https://mobile.twitter.com/itsamejoshabee)) leads Customer Facing Data Science at Rasgo and has been in the data and analytics profession since 2008. Josh spent 10 years at Comcast where he built the data science team and was a key owner of the internally developed Comcast feature store - one of the first feature stores to hit the market. Following Comcast, Josh was a critical leader in building out Customer Facing Data Science at DataRobot. In his spare time Josh performs complex analysis on interesting topics such as baseball, F1 racing, housing market predictions, and more.
  
source: https://www.kdnuggets.com/2022/07/5-hardest-things-sql.html
