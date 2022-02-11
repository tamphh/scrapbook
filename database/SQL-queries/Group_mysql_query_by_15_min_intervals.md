
#### Group mysql query by 15 min intervals

grouping of records of 15 minutes interval, you can change ```15*60``` to the interval in seconds you need

```sql
SELECT
	FLOOR(UNIX_TIMESTAMP(timestamp) / (15 * 60)) AS timekey
FROM
	TABLE
GROUP BY
	timekey;
  
---------------------------------------------------------------------------------------------------

SELECT
	sec_to_time(time_to_sec(datefield) - time_to_sec(datefield) % (15 * 60)) AS intervals
FROM
	tablename
GROUP BY
	intervals;
```
