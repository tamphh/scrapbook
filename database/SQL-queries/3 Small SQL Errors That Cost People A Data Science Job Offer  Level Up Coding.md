# 3 Small SQL Errors That Cost A Data Science Job Offer
source: https://levelup.gitconnected.com/3-small-sql-errors-that-cost-a-data-science-job-offer-7ee920084aed

## One cost me a potential $212K job

In my previous mini-series, [SQL Tricks Every Data Scientist Should Know](https://towardsdatascience.com/6-sql-tricks-every-data-scientist-should-know-f84be499aea5), I shared 10 SQL tips to level up your analytics work. For today’s post, I’d like to take a different perspective, discussing 3 SQL logic mistakes that could cost a lot!

The first error is one I made while interviewing with a FAANG company, which I “paid a big price” to learn. The last two errors, however, are what I’ve seen fresher data scientists make as an interviewer later in my career.

![](https://miro.medium.com/max/1400/1*Imo-K9m8zy2et9VjFMnsgg.jpeg)

Image Source: [Pexels](https://www.pexels.com/photo/design-desk-display-eyewear-313690/)

For my own job interview, here is the package the recruiter summed up:

-   $140k base salary
-   $30k sign-on bonus
-   $125k RSU fully vested in 4 years
-   $20k annual bonus (estimated)

Total package came out to $221k annual. I went from recruiter call, hiring manager technical screening, 1st round technical/coding, all the way through to the final technical round. Then unfortunately, I made a fatal error answering the trojan horse question that cost me the potential offer.

Let me demonstrate with the following toy data table; it is not the exact data I came across in my interview, but close enough to work with,

![](https://miro.medium.com/max/1306/1*naLqm7HhDTFGqpWmlkBjMg.png)

Transaction table of online marketplace

This is a transaction table with records of user logins to an online marketplace. It contains user ID, user name, login date and login location, organized in a time-series format for each user ID. For demonstration purposes, all code is implemented in the MS SQL Server 2017.

**_\*\*\* Watch a fun video version on my channel here 🎥,_**

### Error # 1: Misuse** `**IN**` **operator to match multiple conditions

The `IN` operator is useful to check whether a specific value matches any value in a list. It is a **condensed version of multiple OR conditions**. Understood this quite well, but I mistakenly used the `IN` operator in a problem implying the logic AND.

So my interview task is to find users who have logins in **_NYC_ and _Illinois_**. Without a second thought, I wrote the query below:
```sql
/** 1. User logins in both NYC and Illinois **/
SELECT 
  DISTINCT id_var, user_var  
FROM 
  userlogin 
WHERE 
  location_var IN ('NYC', 'Illinois')
```
which gave,

![](https://miro.medium.com/max/682/1*V1ABy188f_AyNm3R7cQBww.png)

Output from the IN operator

This answer was marked incorrect as we shouldn’t see ID 0180/User DEF because this user had only one single login in _NYC_, yet NO login in _Illinois._

**How I’d avoid this error?**

In fact, only using the `IN` operator is over-simplifying this problem since the underlying logic is AND (i.e., _NYC_ login **&** _Illinois_ login) rather than OR. Here is what I would do to fix this error,

```sql
/** 1.2 User logins in both NYC and Illinois -- logic AND **/
SELECT 
  id_var, user_var
FROM 
(
  SELECT 
    id_var, 
    user_var, 
    SUM(CASE WHEN location_var = 'NYC' THEN 1 ELSE 0 END) AS nyc_cnt, 
    SUM(CASE WHEN location_var = 'Illinois' THEN 1 ELSE 0 END) AS illinois_cnt
  FROM 
    userlogin 
  GROUP BY id_var, user_var
) dat 
WHERE 
  nyc_cnt > 0 
    AND illinois_cnt > 0
```

First, checking each condition individually with a counter (i.e., SUM over rows increment by 1); Then, selecting cases with both counters > 0. This way, we are able to implement the logic AND, ensuring that the output contains users who hopped onto the website in **BOTH** _NYC_ and _Illinois_,

![](https://miro.medium.com/max/660/1*FmNoehkR5RwYLxu06rzpHg.png)

Output from the counter with logic AND

### Error # 2: Poorly organized logical OR and AND operators:

With regard to multiple `OR` and `AND` operators, missing the **logical orders** will screw up our results. Let’s look at this query as an answer submitted by a candidate I interviewed,

```sql
/** 4. User logins in NYC and in Year 2018 or Num_Var >= 1000**/
SELECT *
FROM 
  userlogin 
WHERE 
  location_var = 'NYC'
    AND YEAR(date_var) = '2018' 
    OR num_var >= 1000
```

So the task I gave him was to get user logins that **(1) happened in _NYC_ and (2) happed in the Year 2018 or total Num\_Var ≥ 1000**. Below shows the return,

![](https://miro.medium.com/max/1184/1*PeVfV1RL2i4BQWnAnGaXKw.png)

Why the _Illinois_ record sneaked in (didn’t it violate the first condition of _NYC_ login)? Well, because it has Num\_Var ≥ 1000!

These mixed logical operators are executed in sequential order; thus, the WHERE clause above actually identified all user logins that (1) happened in _NYC_ and Year 2018 or (2) total Num\_Var ≥ 1000. This apparently isn’t what our task asked for.

**How I’d avoid this error?**

We can use parenthesis to overcome this obstacle,

```sql
/** 4.2 User logins in NYC and in Year 2018 or Num_Var >= 1000 -- parenthesis **/
WHERE 
  location_var = 'NYC'
    AND (
          YEAR(date_var) = '2018' 
            OR num_var >= 1000
        )
```

Now, everything looks good,

![](https://miro.medium.com/max/1188/1*NpiXGFsmv_YUZ7FmQm-nqQ.png)

### Error # 3: Fail to account for the NULL values

Lastly, let’s explore individual user cases, e.g., ID 0155/user ABC. This candidate was asked to count this user’s **_California_ logins** vs. **_non-California_ logins.** Below shows his answer:

```sql
/** 5. NULL values **/
SELECT 
  COUNT(*) AS total_cnt, 
  COUNT(CASE WHEN location_var = 'California' THEN id_var END) AS california_CNT, 
  COUNT(CASE WHEN location_var <> 'California' THEN id_var END) AS non_california_CNT
FROM 
  userlogin
WHERE id_var = '0155'
```

This query returns,

![](https://miro.medium.com/max/852/1*musiNn337TD_PVBBuol7NA.png)

Output with = and <>

Again, something weird with the result — these numbers don’t add up! Checking the raw data table, we noticed that there is one missing value (coded as **NULL**) for ID 0155.

**How I’d avoid this error?**

Comparing NULL with an actual value will return a missing value, and a missing value is neither `= ‘California’` nor `<> ‘California’`. Hence, we need one more `CASE WHEN`,

```sql
/** 5.2 NULL values **/
COUNT(CASE WHEN location_var is NULL THEN id_var END) AS NULL_CNT
```

here’s the return as expected,

![](https://miro.medium.com/max/1134/1*Wf72egLXCkFSDMELzIDI1A.png)

Output with CASE WHEN NULL

**Conclusion**

These 3 **Logic Errors** in SQL, although being small, will throw your analytics results completely out of whack. When you come across similar questions in your next SQL interview, hopefully, this blog will help you produce more reliable and efficient code. As always, all code can be found in my [Github repo here](https://github.com/YiLi225/SQL_Python_R/blob/master/SQL_errors.sql). 😀

**_Want more data science and programming tips? Use_** [**_my link_**](https://yilistats.medium.com/membership) **_to sign up to Medium and gain full access to all my content._**

**_Also subscribe to my newly created YouTube channel 🎥_** [**_“Data Talks with Kat”_**](https://www.youtube.com/channel/UCbGx9Om38Ywlqi0x8RljNdw)**_,_**

**Other blogs you may find inspiring,**
