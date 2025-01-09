# 8 Steps in Writing Analytical SQL Queries  Crunchy Data Blog

It is never immediately obvious how to go from a simple SQL query to a complex one -- especially if it involves intricate calculations. One of the “dangers” of SQL is that you can create an executable query but return the wrong data. For example, it is easy to inflate the value of a calculated field by joining to multiple rows.

Use Crunchy Playground to follow allow with this blog post using a Postgres terminal:

[Postgres Playground w/ Sample Data](https://www.crunchydata.com/developers/playground?sql=https://gist.githubusercontent.com/Winslett/328f3332f3a54ef5ea5f70f8fe72afb3/raw/09387ac8cd5075b1f8179a25b951870b97a4e84e/fake-data.sql)

Let’s take a look at a sample query. This appears to look for a summary total of invoice amounts across teams. If you look closely, you might see that the joins would inflate a team’s yearly invoice spend for each team member.

```sql
SELECT
	teams.id,
	json_agg(accounts.email),
	SUM(invoices.amount)
FROM teams
	INNER JOIN team_members ON teams.id = team_members.team_id
	INNER JOIN accounts ON teams.id = team_members.team_id
	INNER JOIN invoices ON teams.id = invoices.team_id
WHERE lower(invoices.period) > date_trunc('year', current_date)
GROUP BY 1;
```

The query is joining `invoices` to `teams` after already joining `team_members` to `teams`. If a team has multiple members and multiple invoices, each invoice amount could be counted multiple times in the `SUM(invoices.amount)` calculation.

## [Building SQL from the ground up](https://www.crunchydata.com/blog/8-steps-in-writing-analytical-sql-queries?ref=dailydev#building-sql-from-the-ground-up)

The above error may not be immediately obvious. This is why it’s better to start small and use building blocks.

Writing complex SQL isn’t as much “writing a query” as it is “building a query.” By combining the building blocks, you get the data that you think you are getting. To write a complex query, loop through the following steps until you get to the intended data:

1.  Using words, define the data
2.  Investigate available data
3.  Return the simplest data
4.  Confirm the simple data
5.  Augment the data with joins
6.  Perform summations
7.  Augment with details or aggregates
8.  Debugging

Let’s step through this above query example, getting sum aggregate totals, to learn my method for building a query.

### [Step 1: In human words, write what you want](https://www.crunchydata.com/blog/8-steps-in-writing-analytical-sql-queries?ref=dailydev#step-1-in-human-words-write-what-you-want)

Write a description, and know it is okay if it changes. Data exploration may mean the data is different than expected. But, it’s a starting point. I usually do this by adding a comment at the top of the editor:

```
-- Return all teams, email addresses for the team, and the
-- year-to-date total spend
```

### [Step 2: Investigate the data in the tables](https://www.crunchydata.com/blog/8-steps-in-writing-analytical-sql-queries?ref=dailydev#step-2-investigate-the-data-in-the-tables)

Even when familiar with the date set, I spend time to ensure the data has not changed. First, if using `psql`, list the tables:

```
psql&gt; \dt
psql&gt; \d invoices
```

There are many SQL clients, and all of them should enable listing and viewing tables and table structures. To further inspect, write a simple query to sample the data:

```sql
SELECT * FROM invoices;
```

Try this on a few different tables. By inspecting column names and columns data, I can see a pattern of relationships. When exploring a dataset created by someone else, it can be difficult to determine relationships. Data isn’t always clean. Columns may not be incorrectly named. "Magic strings" and "magic integers" may not make sense. Multiple application developers implement different philosophies with data structures.

To verify table structures, I take a two step approach: 1) compare it to known data, and 2) ask people involved with the project. When asking a person about the structure of data, they will never respond with "yes" or "no" -- the data structure always has a story. It’s important to verify relationships -- it is possible to join two non-related fields.

### [Step 3: Find the simplest data first](https://www.crunchydata.com/blog/8-steps-in-writing-analytical-sql-queries?ref=dailydev#step-3-find-the-simplest-data-first)

In this scenario, the easiest data is returning the invoice. We also want to calculate the team spend for the year. First, reduce to invoices that should go into the calculations:

```sql
SELECT
	*
FROM invoices
WHERE lower(period) > date_trunc('year', current_date);
```

Look over the data and confirm the returned rows match expected data: included and excluded. When viewing the data, add a where conditional for attributes that should be excluded. A common issue with missing rows on conditionals is NULL values. The following conditional will also exclude when `deleted_at` is `NULL`:

```sql
AND deleted_at < date_trunc('year', current_date)
```

To include `NULL` values, the conditional will need to be expanded to:

```sql
AND (deleted_at < date_trunc('year', current_date) OR deleted_at IS NULL)
```

### [Step 4: Confirm the simple data](https://www.crunchydata.com/blog/8-steps-in-writing-analytical-sql-queries?ref=dailydev#step-4-confirm-the-simple-data)

When working through complex queries that require precision like financial reports, you may need to audit the results row by row. Step through each row and confirm the results. Then, step through a known set of good data and ensure data is not missing. Many mis-written SQL queries are found via this 2-sided verification.

### [Step 5: Add joins, but do not add calculations yet](https://www.crunchydata.com/blog/8-steps-in-writing-analytical-sql-queries?ref=dailydev#step-5-add-joins-but-do-not-add-calculations-yet)

Start with the most reasonable [joins](https://www.crunchydata.com/developers/playground/joins-in-postgres) first. This being an example, the idea that we don't know the data is false. In the real world, this step requires additional experimentation and data validation from team members:

```sql
SELECT
	*
FROM invoices
	INNER JOIN teams ON invoices.team_id = teams.id
WHERE lower(period) > date_trunc('year', current_date);
```

After adding the joins, run the query and inspect the data. By joining the data, the query is returning more columns. Start limiting the response to the columns to be used. Remove the `*` and go with column names:

```sql
SELECT
	invoices.period,
	invoices.amount,
	teams.id,
	teams.name
FROM invoices
	INNER JOIN teams ON invoices.team_id = teams.id
WHERE lower(period) > date_trunc('year', current_date);
```

Once that works, add additional joins until it breaks. In this example, experiment by adding `team_members`:

```sql
SELECT
	invoices.period,
	invoices.amount,
	teams.id,
	teams.name
FROM invoices
	INNER JOIN teams ON invoices.team_id = teams.id
	INNER JOIN team_members ON teams.id = team_members.team_id
WHERE lower(period) > date_trunc('year', current_date);
```

But that has duplicate rows -- previously, the query returned 602 rows and now it returns 3749 rows. Why? When joining teams and team\_members, one-to-many relationship adds one row for each additional team member. In this case, we would step back to go forward. Remove the latest value and encapsulate the value.

Common issues during this phase include:

-   typos in join conditional -- when working with tables with similar names, it is easy to insert an incorrect join condition. For instance, the following query will execute, and will return completely the wrong data, can you spot the error?

```sql
SELECT
	invoices.period, invoices.amount, teams.id, teams.name
FROM invoices
	INNER JOIN teams ON invoices.id = teams.id
WHERE lower(period) > date_trunc('year', current_date);
```

The other question is: what kind of join should I use? Quick refresher:

-   `INNER JOIN` is an exclusive join. Only rows with matching rows in the joined table, then the value is not returned.
-   `LEFT JOIN` is a non-exclusive join. All rows from the previously requested table will be returned, and the joined table will be returned if it exists
-   `OUTER JOIN` all rows from all tables will be returned, if unfound the other table will return NULL.

### [Step 6: Perform summations](https://www.crunchydata.com/blog/8-steps-in-writing-analytical-sql-queries?ref=dailydev#step-6-perform-summations)

Let’s rewind back to what works, and package it into a [CTE](https://www.crunchydata.com/developers/playground/ctes-and-window-functions) that we can use as a join. As you make changes, you'll make some wrong steps -- that is common. Know how to get back to a working query. Often that requires undo-ing changes to a working state.

Once I get to a working state, then I package the bit of data into a CTE (or common table expression):

```sql
WITH team_yearly_spend AS (
	SELECT
		invoices.period AS invoice_period,
		invoices.amount AS invoice_amount,
		teams.id AS team_id,
		teams.name AS team_name
	FROM invoices
		INNER JOIN teams ON invoices.team_id = teams.id
	WHERE lower(period) > date_trunc('year', current_date)
)

SELECT * FROM team_yearly_spend;
```

Notice the use of `AS` to declare unique names for a column. When building complex queries, I favor verbosity to limit mistakes.

Let's add aggregations to the CTE:

```sql
WITH team_yearly_spend AS (
	SELECT
		teams.id AS team_id,
		teams.name AS team_name,
		SUM(invoices.amount) AS team_yearly_spend
	FROM invoices
		INNER JOIN teams ON invoices.team_id = teams.id
	WHERE lower(period) > date_trunc('year', current_date)
	GROUP BY 1
)

SELECT
	*
FROM team_yearly_spend;
```

### [Step 7: Lastly, augment data to include details](https://www.crunchydata.com/blog/8-steps-in-writing-analytical-sql-queries?ref=dailydev#step-7-lastly-augment-data-to-include-details)

To include team member emails as specified at the beginning, we will join the team members to the statement outside the CTE:

```sql
WITH team_yearly_spend AS (
	SELECT
		teams.id AS team_id,
		teams.name,
		SUM(invoices.amount) AS spend
	FROM invoices
		INNER JOIN teams ON invoices.team_id = teams.id
	WHERE lower(period) > date_trunc('year', current_date)
	GROUP BY 1
)

SELECT
	team_yearly_spend.team_id,
	team_yearly_spend.spend,
	COUNT(DISTINCT accounts.id) AS accounts_count,
	JSON_AGG(accounts.email) AS account_emails
FROM team_yearly_spend
LEFT JOIN team_members ON team_yearly_spend.team_id = team_members.team_id
LEFT JOIN accounts ON team_members.account_id = accounts.id
GROUP BY 1, 2
;
```

### [Step 8: Debugging](https://www.crunchydata.com/blog/8-steps-in-writing-analytical-sql-queries?ref=dailydev#step-8-debugging)

To debug output errors, I find it easier to remove the calculations to get to the raw data. When using a query editing tool that allows running of the a visually selected query (like DBeaver), I comment out the aggregations and add a `*` to return more values:

```sql
-- WITH team_yearly_spend AS (
	SELECT
		teams.id AS team_id,
		teams.name,
		*
--		SUM(invoices.amount) AS spend
	FROM invoices
		INNER JOIN teams ON invoices.team_id = teams.id
	WHERE lower(period) > date_trunc('year', current_date)
--	GROUP BY 1
--)
```

With this response, look for:

-   rows duplicated by joins,
-   rows that should be present, yet are missing due to a bad conditional,
-   rows that are included that should be filtered out with a conditional.

Debugging SQL queries is a simple process, but it’s not an easy process. It requires a data audit, usually best to compare against a known value.

## [Why is SQL complex?](https://www.crunchydata.com/blog/8-steps-in-writing-analytical-sql-queries?ref=dailydev#why-is-sql-complex)

The schema for the example above was an example of an application data structure with OLTP in mind. The SQL that we have just written can use that schema and generate values for report generation or for display to application users. That is the great thing about SQL -- no matter how the underlying structure is represented, we can get the data we want to get out of it.

SQL is powerful because it’s built using simple, standardized blocks of logic.

Writing SQL is a non-linear process. I've never seen someone start at the top of a long-SQL query and type through to the end. It is a process that involves multiple levels of extraction, verification, and summation.

source: https://www.crunchydata.com/blog/8-steps-in-writing-analytical-sql-queries?ref=dailydev
