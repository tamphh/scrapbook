```text
Selecting rows holding group-wise maximum of a field
Today there was a question on the Freenode MySQL channel about a classical problem: Rows holding group-wise maximum of a column. This is a problem that I keep encountering every so often, so I thought I would write up something about it.

A good example of the problem is a table like the following holding versioned objects:

CREATE TABLE object_versions (
  object_id INT NOT NULL,
  version INT NOT NULL,
  data VARCHAR(1000),
  PRIMARY KEY(object_id, version)
) ENGINE=InnoDB
Now it is easy to get the latest version for an object:
SELECT data FROM object_versions WHERE object_id = ? ORDER BY version DESC LIMIT 1
The query will even be very fast as it can use the index to directly fetch the right row:
mysql> EXPLAIN SELECT data FROM object_versions
WHERE object_id = 42 ORDER BY version DESC LIMIT 1;
+----+-------------+-----------------+------+---------------+---------+---------+-------+------+-------------+
| id | select_type | table           | type | possible_keys | key     | key_len | ref   | rows | Extra       |
+----+-------------+-----------------+------+---------------+---------+---------+-------+------+-------------+
|  1 | SIMPLE      | object_versions | ref  | PRIMARY       | PRIMARY | 4       | const |    3 | Using where | 
+----+-------------+-----------------+------+---------------+---------+---------+-------+------+-------------+
1 row in set (0.00 sec)
But what if we want to select the latest version of all (or some range of) objects? This is a problem that I think standard SQL (or any SQL dialect that I know of, including MySQL) has no satisfactory answer to.

Intuitively, the problem should be simple for the database engine to solve. Just traverse the BTree structure of the primary key (assume InnoDB clustered index storage here), and for each value of the first part of the primary key (object_id), pick the highest value of the second part (version) and return the corresponding row (this is similar to what I believe is sometimes called index skip scan). However, this idea is surprisingly difficult to express in SQL.

The first method suggested in the above link to the MySQL manual works in this case, but it is not all that great in my opinion. For example, it does not work well if the column that MAX is computed over is not unique per group (as it is in this example with versions); it will return all of the maximal rows which may or may not be what you wanted. And the query plan is not all that great either:

mysql> EXPLAIN SELECT data FROM object_versions o1 WHERE version =
(SELECT MAX(version) FROM object_versions o2 WHERE o1.object_id = o2.object_id);
+----+--------------------+-------+------+---------------+---------+---------+-----------------------+------+-------------+
| id | select_type        | table | type | possible_keys | key     | key_len | ref                   | rows | Extra       |
+----+--------------------+-------+------+---------------+---------+---------+-----------------------+------+-------------+
|  1 | PRIMARY            | o1    | ALL  | NULL          | NULL    | NULL    | NULL                  |    6 | Using where | 
|  2 | DEPENDENT SUBQUERY | o2    | ref  | PRIMARY       | PRIMARY | 4       | einstein.o1.object_id |    1 | Using index | 
+----+--------------------+-------+------+---------------+---------+---------+-----------------------+------+-------------+
2 rows in set (0.00 sec)
It is apparently doing a full table scan with an index lookup for every row in the table, which is not that bad, but certainly more expensive than necessary, especially if there are many versions per object. Still, it is probably the best method in most cases (or so I thought first, but see benchmarks below!).
The two other suggestions from the MySQL manual are not perfect either (though the first one is blazingly fast, see benchmarks below). One is to use an uncorrelated subquery with a join:

mysql> EXPLAIN SELECT o1.data FROM object_versions o1
INNER JOIN (SELECT object_id, MAX(version) AS version FROM object_versions GROUP BY object_id) o2
ON (o1.object_id = o2.object_id AND o1.version = o2.version);
+----+-------------+-----------------+--------+---------------+---------+---------+-------------------------+------+-------------+
| id | select_type | table           | type   | possible_keys | key     | key_len | ref                     | rows | Extra       |
+----+-------------+-----------------+--------+---------------+---------+---------+-------------------------+------+-------------+
|  1 | PRIMARY     | <derived2>      | ALL    | NULL          | NULL    | NULL    | NULL                    |    3 |             | 
|  1 | PRIMARY     | o1              | eq_ref | PRIMARY       | PRIMARY | 8       | o2.object_id,o2.version |    1 |             | 
|  2 | DERIVED     | object_versions | index  | NULL          | PRIMARY | 8       | NULL                    |    6 | Using index | 
+----+-------------+-----------------+--------+---------------+---------+---------+-------------------------+------+-------------+
At first, I actually did not know exactly how to interpret this plan output. After the benchmarks given below, I now think this plan is actually very good, apparently it is first using something like an index skip scan to compute the MAX() in the uncorrelated subquery, and then looking up each row using the primary key. It still has the issue with multiple rows if version was not unique per object.
The other suggestion uses an outer self-join:

mysql> EXPLAIN SELECT o1.data FROM object_versions o1
LEFT JOIN object_versions o2 ON o1.object_id = o2.object_id AND o1.version < o2.version
WHERE o2.object_id IS NULL;
+----+-------------+-------+------+---------------+---------+---------+-----------------------+------+--------------------------------------+
| id | select_type | table | type | possible_keys | key     | key_len | ref                   | rows | Extra                                |
+----+-------------+-------+------+---------------+---------+---------+-----------------------+------+--------------------------------------+
|  1 | SIMPLE      | o1    | ALL  | NULL          | NULL    | NULL    | NULL                  |    6 |                                      | 
|  1 | SIMPLE      | o2    | ref  | PRIMARY       | PRIMARY | 4       | einstein.o1.object_id |    1 | Using where; Using index; Not exists | 
+----+-------------+-------+------+---------------+---------+---------+-----------------------+------+--------------------------------------+
2 rows in set (0.00 sec)
The plan again looks reasonable, but not optimal. And somehow, all three methods feel unnatural for something that ought to be simple to express.
And in fact, there is a nice way to express this in SQL, except that it does not work (at least not in MySQL):

SELECT MAX(version, data) FROM object_versions GROUP BY object_id;
If there was just support for computing MAX() over multiple columns like this, this query would be a nice, natural, and simple way to express our problem. And it would be relatively easy for database engines to create the optimal plan, I think index skip scan is fairly standard already for single-column MAX() with GROUP BY. And the syntax feels very natural, even though it does bend the rules somehow by a single expression (MAX(version, data)) returning multiple columns. I have half a mind to try to implement it myself in MySQL or Drizzle one day ...
In fact, one can almost use this technique by an old trick-of-the-trade:

mysql> SELECT MAX(CONCAT(version, ":", data)) FROM object_versions GROUP BY object_id;
+---------------------------------+
| max(concat(version, ":", data)) |
+---------------------------------+
| 2:foo2                          | 
| 1:bar                           | 
| 3:baz2                          | 
+---------------------------------+
3 rows in set (0.00 sec)

mysql> EXPLAIN SELECT MAX(CONCAT(version, ":", data)) FROM object_versions GROUP BY object_id;
+----+-------------+-----------------+-------+---------------+---------+---------+------+------+-------+
| id | select_type | table           | type  | possible_keys | key     | key_len | ref  | rows | Extra |
+----+-------------+-----------------+-------+---------------+---------+---------+------+------+-------+
|  1 | SIMPLE      | object_versions | index | NULL          | PRIMARY | 8       | NULL |    6 |       | 
+----+-------------+-----------------+-------+---------------+---------+---------+------+------+-------+
1 row in set (0.00 sec)
Though I consider this (and variations thereof) a hack with limited practical usage.
And speaking of hacks, there is actually another way to solve the problem, one which I learned about recently at a customer:

mysql> EXPLAIN SELECT data FROM
(SELECT * FROM object_versions ORDER BY object_id DESC, version DESC) t GROUP BY object_id;
+----+-------------+-----------------+-------+---------------+---------+---------+------+------+---------------------------------+
| id | select_type | table           | type  | possible_keys | key     | key_len | ref  | rows | Extra                           |
+----+-------------+-----------------+-------+---------------+---------+---------+------+------+---------------------------------+
|  1 | PRIMARY     | <derived2>      | ALL   | NULL          | NULL    | NULL    | NULL |    6 | Using temporary; Using filesort | 
|  2 | DERIVED     | object_versions | index | NULL          | PRIMARY | 8       | NULL |    6 |                                 | 
+----+-------------+-----------------+-------+---------------+---------+---------+------+------+---------------------------------+
Get it? This cleverly/evilly (ab)uses the MySQL non-standard extension which allows SELECT of columns not in the GROUP BY clause even without using aggregate functions. MySQL will return a value for the column from an "arbitrary" row in the group. In practise, it chooses it deterministically from the first row in the group, which is why this trick seems to work well in practise. But it is clearly documented to not be supported, so not really something to recommend, though interesting to see.
Bonus benchmark
As a free bonus, I decided to run some quick benchmarks. As it turns out, the results are quite surprising!

So I filled the table above with 1,000,000 rows, 1000 objects each with 1000 versions. Total table size is about 50Mb or so. I then ran each of the five above queries:

mysql> SELECT data FROM object_versions o1
WHERE version = (SELECT MAX(version) FROM object_versions o2 WHERE o1.object_id = o2.object_id);
1000 rows in set (4 min 22.86 sec)

mysql> SELECT o1.data FROM object_versions o1
INNER JOIN (SELECT object_id, MAX(version) AS version FROM object_versions GROUP BY object_id) o2
ON (o1.object_id = o2.object_id AND o1.version = o2.version);
1000 rows in set (0.01 sec)

mysql> SELECT o1.data FROM object_versions o1
LEFT JOIN object_versions o2 ON o1.object_id = o2.object_id AND o1.version < o2.version
WHERE o2.object_id IS NULL;
1000 rows in set (2 min 42.72 sec)

mysql> SELECT MAX(CONCAT(version, ":", data)) FROM object_versions GROUP BY object_id;
1000 rows in set (0.63 sec)

mysql> SELECT data FROM
(SELECT * FROM object_versions ORDER BY object_id DESC, version DESC) t GROUP BY object_id;
1000 rows in set (15.61 sec)
The differences are huge!

The clear winner is query 2, the uncorrelated subquery. Apparently it can do an index skip scan for the inner MAX/GROUP BY query, followed with a primary key join, so it only ever has to touch 1000 rows. An almost optimal plan.

Query 1 and 3 (correlated subquery and outer join) are spectacularly bad. It looks as if they are doing something like for each 1,000,000 rows in the full table scan, do a 1000 row index range scan in the subquery/join, for a total of 1 billion rows examined. Or something. Not good.

Query 4 and 5, the trick queries, are doing so-so, probably they get away with a sort of a full table scan of 1,000,000 rows.

Conclusions: Uncorrelated subquery is the undisputed winner!
```
source: https://kristiannielsen.livejournal.com/6745.html
