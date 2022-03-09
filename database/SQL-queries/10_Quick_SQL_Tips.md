## 10 Quick SQL Tips After Writing Daily in SQL for 3 Years
### These tips address common SQL problems you will encounter as a data professional

I have been a data professional for 3 years now and it still amazes me to see others who are looking at getting into a data-related field with little to no prior SQL knowledge or experience. I can’t stress this enough, SQL is fundamental regardless of the specific data-role you aspire to get.
Granted, I’ve seen exceptions of people who have spectacular skills in other areas besides SQL get the job, but then they still have to learn SQL after getting hired. I think it’s near impossible to be a data professional without ever having to learn SQL.
These SQL tips are meant for everyone regardless of how much experience you have. These are SQL tips I actually frequently have used, not something novel that may be interesting but doesn’t actually fit in your workflow very well. I listed these in order of difficulty for convenience.
I will be using this SQLite sandbox database for my code examples: https://www.sql-practice.com/.

### 1. Checking Distinct Counts in Your Table
```SQL
SELECT count(*), count(distinct patient_id) FROM patients
```
This first example shows how you would check if your column is a primary key in your table. Of course, this is typically going to be used in tables you create since most databases have the option to list the primary key in the information schema metadata.
If the numbers from the two columns are equal, then the column you counted in the second part of the query could be the primary key. It’s not a guarantee, but it could help you figure it out.
This gets only slightly more complicated when you have multiple columns that create a primary key. To solve this, simply concatenate the columns that make the primary key after the DISTINCT keyword. A simple example is concatenating first and last name from the sandbox table to create a primary key.
```SQL
SELECT count(*), count(distinct first_name || last_name) FROM patients
```
### 2. Finding Examples of a Duplicate Record

```SQL
SELECT 
    first_name 
    , count(*) as ct
    
FROM patients
GROUP BY
    first_name
HAVING
    count(*) > 1
ORDER BY 
    COUNT(*) DESC
;
```
The sandbox table is an oversimplified version of databases you will use in your work. A lot of the time, you will want to look into reasons for duplicate values in the database. That’s where this next query comes in handy.
You can use the HAVING keyword to sort those values that are duplicated. In the sandbox database, you can see that the first name ‘John’ is duplicated the most often. You would then run another query where you filter to ‘John’ to see the reason for the duplicate values and you can quickly see that they all have different last names and patient ID’s.

### 3. Handling NULLS with DISTINCT
```SQL
with new_table as (
select patient_id from patients
UNION
select null
)

select 
    count(*)
  , count(distinct patient_id)
  , count(patient_id) 

from new_table
```
The output of this query will be 4531 for the COUNT(*) column and 4530 for the two remaining columns. When you specify a column, the COUNT keyword will exclude counting nulls. However, when you use the asterisk, the NULLS are included in the count. This can be confusing when checking if a column is a primary key, which is why I wanted to mention it.


### 4. CTE > Sub-queries
```SQL
-- Use of CTE
with combined_table as (
select
  *
 
FROM patients p
JOIN admissions a 
  on p.patient_id = a.patient_id
)

, name_most_admissions as (
select
    first_name || ' ' || last_name as full_name
  , count(*)                       as admission_ct
  
FROM combined_table
)

select * from name_most_admissions
;

-- Use of sub-queries :(
select * from 
   (select
        first_name || ' ' || last_name as full_name
      , count(*)                       as admission_ct
  
    FROM (select
             *
 
          FROM patients p
          JOIN admissions a 
              on p.patient_id = a.patient_id
          ) combined_table
    ) name_most_admissions
;
```
When I first started as a data analyst 3 years ago, I wrote SQL queries with more sub-queries than I would like to admit. I learned quickly that this does not result in readable code. In most situations you want to use a CTE (common table expression) instead of a sub-query. Reserve sub-queries for one-liners that you want to include.

### 5. Using SUM and CASE WHEN Together
```SQL
select 
     sum(case when allergies = 'Penicillin' and city = 'Burlington' then 1 else 0 end) as allergies_burl
   , sum(case when allergies = 'Penicillin' and city = 'Oakville' then 1 else 0 end)   as allergies_oak
  
from patients
```
A WHERE clause can work if you wanted to sum the amount of patients that meet certain conditions. But if you wanted to check multiple conditions, you can use SUM and CASE WHEN keywords together. This condenses the code and is easy to read as well.
This combination can also be used in the WHERE clause, like in the example below.

```SQL
select
  * 
FROM patients
WHERE TRUE
  and 1 = (case when allergies = 'Penicillin' and city = 'Burlington' then 1 else 0 end)
```

### 6. Be Careful with Dates
```SQL
with new_table as (
select
    patient_id
  , first_name
  , last_name
  , time(birth_date, '+1 second') as birth_date

from patients
where TRUE
   and patient_id = 1

UNION
  
select
    patient_id
  , first_name
  , last_name
  , birth_date 

from patients
WHERE TRUE
  and patient_id != 1
)

select 
  birth_date 
  
from new_table 
where TRUE 
  and birth_date between '1953-12-05' and '1953-12-06'
```
This sandbox dataset has all dates truncated to the day. This means that the time components of the birth_date column in this example are all 00:00:00. In real-world datasets however, this is typically not the case.
Depending on your SQL development IDE, your settings might hide displaying the time component. But just because the time is hidden, doesn’t mean it isn’t a part of the data.
In the example above, I artificially added a second to patient #1. As you can see, this 1 second was enough to exclude the patient from the results when using the BETWEEN keyword.
Another common example I see data professionals missing is joining on dates that still have the time component. Most of the time they actually intend to join on the truncated date and they end up not getting the result they were looking for; or even worse, they don’t realize they didn’t get the correct result.

### 7. Don’t Forget About Window Functions
```SQL
select
    p.*
  , MAX(weight) over (partition by city) as maxwt_by_city
   
 from patients p
```
Window functions are a great way to keep all of the data rows and then append another column with important aggregate details. In this case, we were able to keep all of the data, but add a max weight by city column.
I have seen some analysts try work-arounds when a window function would make the code shorter and more readable and most likely save them time too.
There are plenty of different window functions, but the example above is a common and simple use case.

### 8. Avoiding DISTINCT if Possible
The following final 3 tips don’t have specific code snippets to show, but are just as important as the above examples. I have found in my career so far that too often data professionals will add a distinct to prevent duplicates without understanding the data.
This is a mistake. If you can’t explain why there are duplicates in the data to begin with, you could be excluding some useful information from your analysis. You should always be able to explain why you put a distinct on a table and why there are duplicates. A WHERE clause is typically preferred since you can then see what is being excluded.

### 9. SQL Formatting
This has been said quite a bit, but bears repeating. Make sure to format your SQL. It’s better to create more lines with good formatting, than to try to condense all of your code on just a few lines. It will make your development and others development faster.
You can see in my code snippets above, I used the TRUE keyword in my WHERE clause. This was to make it so all arguments in the WHERE clause started with AND. This way, the arguments start at the same point.
Another quick tip is adding commas at the beginning of your column in your SELECT clause. This makes any missing commas really easy to find since they are all lined up.
10. Debugging Tip
Some SQL queries can be really difficult debugging problems. What helped me the most when I have ran into these in the past is being very diligent at documenting my steps.
To document my steps, I will number a section of code in the comments before the query. The comment describes what I am trying to do in that query section. Then I will write my answer below the comment heading after running the query.
It’s really easy to see what you have already tried as you debug and I promise you will solve it faster with this approach.

### Conclusion
Hopefully you learned something useful with those tips. What are some useful tips you have found when coding in SQL? I look forward to hearing your tips as well and please link any other useful articles in the comments, thanks!
source: https://towardsdatascience.com/10-quick-sql-tips-after-writing-daily-in-sql-for-3-years-37bdba0637d0
