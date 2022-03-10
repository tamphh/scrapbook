## A Look at the SQL Speaking Python… Pandas!
From SQL to Pandas — know the equivalents

Pandas is a widely used library for data manipulation and analysis. Speaking of data, the most common way to store data is in a database and we would use SQL(Structured Query Language) for querying it.
We can use pandas for inserting/retrieving and modifying data to/from the database. Pandas can also be used with raw SQL queries. Let’s look at SQL and its pandas equivalent below.

Before proceeding, we will get the data from a table table1 and store it in a DataFrame called table.
```python
-- SQL
SELECT * FROM table1;

--Pandas
table = pd.read_sql('SELECT * FROM TABLE1', con=engine/connection_string)
The engine is an SQLAlchemy engine.
```
**Note:** A DataFrame is a data structure that is 2-dimensional, having data in the form of rows and columns. It can be considered to be similar to an excel spreadsheet. To know more about DataFrame, kindly refer the pandas official documentation on it.

### 1. Select
Select all columns from a table:
```python
--SQL 
SELECT * FROM table1;

--Pandas
table
```

Select coulmn1, column2 from a table:
```python
--SQL 
SELECT column1, column2 FROM table1;

--Pandas
table[[column1,column2]]
```
Select all unique records from a column
```python
--SQL 
SELECT DISTINCT(column1) FROM table1;

--Pandas
table[column1].unique()
```
Select the count of all unique records from a column
```python
--SQL
SELECT COUNT(DISTINCT(column1)) FROM table1;

--Pandas
table[column1].nunique()
```
### 2. Select with a Where clause
Select records where column1 is equal to value:
```python
--SQL 
SELECT * FROM table1 WHERE column1 = value;

--Pandas
table.loc[table[column1]==value]
```

Select record where column1 is greater than value1 and column2 is less than value2:
```python
--SQL 
SELECT * FROM table1 WHERE column1 = value1 AND column2 = value2;

--Pandas
table.loc[(table[column1] > value1) & (table[column2]< value2)]
```

Select records where column1 contains a string ‘Hello’:
```python
--SQL
SELECT * FROM table1 WHERE column1 LIKE '%Hello%';

--Pandas
table.loc[table[column1].str.contains('Hello')]
```

Select records which are not null:
```python
--SQL
SELECT * FROM table1 WHERE column1 IS NOT NULL;

--Pandas
table.loc[table[column1].notnull()]
```

### 3. Select with Group By clause
Select column1 and sum of column2 grouping on column1:
```python
--SQL 
SELECT coulmn1, SUM(column2) FROM table1 GROUP BY column1;

--Pandas
table.groupby(column1).sum()
```

Select column1 and minimum of column2 grouping on column1 where the minimum value of column2 is greater than value:
```python
--SQL 
SELECT coulmn1, MIN(column2) as min FROM table1 GROUP BY column1 HAVING MIN(column2)> value;

--Pandas
table_group = table.groupby(column1).min()
table_group[table_group[column2] > value]
```

### 4. SELECT with Order By clause (Sorting)
Sort the results in ascending order based on a single column:
```python
--SQL
SELECT * FROM table1 ORDER BY column1 ASC;

--Pandas
table.sort_values(by=column1,ascending=True,inplace=True)
```

Sort the results in descending order based on a single column:
```python
--SQL
SELECT * FROM table1 ORDER BY column1 DESC;

--Pandas
table.sort_values(by=column1,ascending=False,inplace=True)
```

Sort the results in ascending order based on multiple columns:
```python
--SQL
SELECT * FROM table1 ORDER BY column1, column2 ASC;

--Pandas
table.sort_values(by=[column1,column2],ascending=True,inplace=True)
```

Sort the results of column1 in ascending order and column2 in descending order:
```python
--SQL
SELECT * FROM table1 ORDER BY column1 ASC, column2 DESC;

--Pandas
table.sort_values(by=[column1,column2],ascending=[True,False],inplace=True)
```

### 5. JOINS
INNER JOIN:
```python
--SQL 
SELECT * FROM table1 INNER JOIN table2 ON table1.column1 = table2.column1;

--Pandas
join_table = table1.merge(table2, on=column1, how='inner')
# We can also use the join method as given below.
join_table = table1.join(table2.set_index(column1), on=column1, how=inner)
```

LEFT JOIN on multiple columns:
```python
--SQL 
SELECT * FROM table1 LEFT JOIN table2 ON table1.column1 = table2.column1 AND table1.column2=table2.column2;

--Pandas
join_table = table1.merge(table2, how='left', left_on=[column1,column2], right_on=[column1,column2])
```

RIGHT JOIN:
```python
--SQL 
SELECT * FROM table1 RIGHT JOIN table2 ON table1.column1 = table2.column1;

--Pandas
join_table = table1.merge(table2, on=column1, how='right')
```

### 6. Update
Updating a column based on criteria:
```python
--SQL 
UPDATE table1 SET column2 = 1 WHERE column1 = 'YES';

--Pandas
table.loc[table[column1]=='YES', column2] = 1
```

Updating a column based on multiple criteria:
```python
--SQL
UPDATE table1 SET column3 = 1 WHERE column1 = 'YES' AND column2 = 'ACTIVE';

--Pandas
table.loc[(table[column1] == 'YES') & (table[column2] == 'ACTIVE'), column3] = 1
```

### 7. Insert
Inserting the data from the dataframe into a database table.
```python
--SQL
INSERT INTO table1 VALUES (column1,column2,column3)

--Pandas
table.to_sql(table1, con=engine/connection_string)
```



