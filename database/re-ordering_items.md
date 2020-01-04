There're some features which contain multiple questions with drag/drop support. The challenge is that the question order is arbitrary and can change when the user rearranges items. Currently, we’re applying the integer position & linked-list approach for other features which has some downsides like multiple records updating, require frequent renumberings, or overhead fetching. Here we’ll discuss another more effective approach called user-specified ordering with fractions.

## User-specified ordering with fractions

Basically, the idea is that we’ll somehow to find a solution that hit DB at least as possible while doing re-order. For example, we move item at 5th position to 2nd one. If somehow we could get some value between 2 & 3 and update that one to position of moving item then we finish the work. The point is how to get new position value efficiently. Using floats and picking the midpoints between adjacent values also runs out of space rapidly. So far as we research, we could use value from Stern–Brocot tree. It provides a mediant number between 2 ones and renumbering values is only rarely required.

Basically, the idea is that we’ll try to hit DB at least as possible while doing re-order. For example, we move item at 5th position to 2nd one. If somehow we could get some value between 2 & 3 and update that one to position of moving item then we finish the work. The point is how to get new position value efficiently. So far as I research, we could use value from [Stern–Brocot tree](https://en.wikipedia.org/wiki/Stern%E2%80%93Brocot_tree). It provides a mediant number between 2 ones.

### Draft implementation:	
#### 1. Database design: 
   Need 2 columns to store ```numerator``` and ```denominator```.
```sql
CREATE TABLE tasks (
   id          INT     PRIMARY KEY     NOT NULL,
   name        TEXT    NOT NULL,
   numerator   INT     NOT NULL,
   denominator INT     NOT NULL,
);

```
   How to use:
	For example: we have some tasks in DB as below. 

| id | name   | numerator | denominator |
|----|--------|-----------|-------------|
| 1  | task 1 | 2         | 1           |
| 2  | task 2 | 3         | 1           |
| 3  | task 3 | 4         | 1           |

We need to move ```task 3``` to position between 1st & 2nd, from [Stern–Brocot tree](https://en.wikipedia.org/wiki/Stern%E2%80%93Brocot_tree), the mediant value for 2/1 & 3/1 is 5/2, them update record, we'll end with:

| id | name   | numerator | denominator |
|----|--------|-----------|-------------|
| 1  | task 1 | 2         | 1           |
| 2  | task 2 | 3         | 1           |
| 3  | task 3 | 5         | 2           |

##### How to fetch:
Some query like:
```sql
SELECT * FROM tasks ORDER BY (numerator::float8/denominator);
```

#### 2. Ruby code: 
we define method to get mediant value, actually I already converted code from reference link to ruby code

```ruby
def find_intermediate(p1, q1, p2, q2)
  pl = 0
  ql = 1
  ph = 1
  qh = 0
  if(p1 * q2 + 1) != (p2 * q1)
    loop do
      p = pl + ph
      q = ql + qh
      if(p * q1 <= q * p1)
        pl = p; ql = q
      elsif(p2 * q <= q2 * p)
        ph = p; qh = q
      else
        break
      end
    end
  else
    p = p1 + p2
    q = q1 + q2
  end
  [p, q]
end
```
Example:
```ruby
find_intermediate(2, 1, 3, 1)
# => [5, 2]
```

### Implementation notes for Flexible survey questions:

To help you understand our approach and how to apply in some edge cases, we use:

- template_group_mappings as example

- Default initialized values for numerator = nth_position * 10 (eg: 10, 20, 30,…) and always > 1

- Default initialized values for numerator = 1

- In case of moving record to the first position, we’ll implicitly use numerator = 1, denominator = 1 as the higher limit, and current first record as lower limit

- When fetching, value from numerator/denominator is used to order, and we limit to four digit float. For ex: 2.3333

- In case of moving some record into between ones which exceed four digit value. For example:

| id | survey\_template\_id | template\_group\_id | numerator/denominator |
|----|----------------------|---------------------|-----------------------|
| 1  | 12                   | 21                  | 1\.3333               |
| 2  | 23                   | 32                  | 1\.3334               |
| 3  | 34                   | 43                  | 4\.111                |

We need to move record with id 3 between 1st & 2nd one, but after calculation and upper round to 4 digits, we got the value which is not mediant value (eg: 1.3334), then we renumbering values for all records in this group as below:

| id | survey\_template\_id | template\_group\_id | numerator | denominator |
|----|----------------------|---------------------|-----------|-------------|
| 1  | 12                   | 21                  | 10        | 1           |
| 2  | 23                   | 32                  | 20        | 1           |
| 3  | 34                   | 43                  | 30        | 1           |


Reference:
- [Stern–Brocot tree](https://en.wikipedia.org/wiki/Stern%E2%80%93Brocot_tree)
- [User-specified ordering with fractions](https://wiki.postgresql.org/wiki/User-specified_ordering_with_fractions)
