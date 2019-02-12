
-- The Warehouse
-- lINK: https://en.wikibooks.org/wiki/SQL_Exercises/The_warehouse
--3.1 Select all warehouses.
select * from Warehouses;

--3.2 Select all boxes with a value larger than $150.
select * from Boxes
  where Value > 150;

--3.3 Select all distinct contents in all the boxes.
select distinct Contents from Boxes;

--3.4 Select the average value of all the boxes.
select avg(Value) from Boxes;

--3.5 Select the warehouse code and the average value of the boxes in each warehouse.
select Warehouse, avg(Value) from Boxes
group by Warehouse;

--3.6 Same as previous exercise, but select only those warehouses where the average value of the boxes is greater than 150.
select Warehouse, avg(Value) Avg_Value from Boxes
group by Warehouse
having Avg_Value > 150;

--3.7 Select the code of each box, along with the name of the city the box is located in.
select b.Code, w.Location
  from Boxes b
  inner join Warehouses w on w.Code = b.Warehouse;

--3.8 Select the warehouse codes, along with the number of boxes in each warehouse. 
    -- Optionally, take into account that some warehouses are empty (i.e., the box count should show up as zero, instead of omitting the warehouse from the result).
 select w.location, w.code, coalesce(wt.count, 0) count 
  from Warehouses w
    left join
      (
        select Warehouse code, count(*) count
          from Boxes
          group by Warehouse
      ) as wt
    on wt.code = w.code;

--3.9 Select the codes of all warehouses that are saturated (a warehouse is saturated if the number of boxes in it is larger than the warehouse's capacity).
select w.location, w.code, w.Capacity, wt.count
  from Warehouses w
    inner join
      (
        select Warehouse code, count(*) count
            from Boxes
          group by Warehouse
      ) as wt
    on wt.code = w.code and wt.count > w.Capacity
where count is not null;

select * from Warehouses w
where Capacity < (
  select count(*) from Boxes where Warehouse = w.Code
);

--3.10 Select the codes of all the boxes located in Chicago.
select Code 
  from Boxes
  where Warehouse in (
    select w.Code from Warehouses w where location='Chicago'
  );

select b.Code
  from Boxes b
  inner join Warehouses w on w.Code = b.Warehouse and w.Location = 'Chicago';

--3.11 Create a new warehouse in New York with a capacity for 3 boxes.
insert into Warehouses(Code, Location, Capacity)
  values(7, 'New York', 3);

--3.12 Create a new box, with code "H5RT", containing "Papers" with a value of $200, and located in warehouse 2.
insert into Boxes(Code, Contents, Value, Warehouse)
  values('H5RT', 'Papers', 200, 2);

--3.13 Reduce the value of all boxes by 15%.
update Boxes
  set Value = Value * 0.85;

--3.14 Remove all boxes with a value lower than $100.
delete from Boxes where Code in
  (
    select tmp.Code from (select * from Boxes) tmp where tmp.Value < 100
  );

-- 3.15 Remove all boxes from saturated warehouses.
delete from Boxes
  where Warehouse in (
    select Code from Warehouses w
      where Capacity < (
        select count(*) from (select * from Boxes) b where Warehouse = w.Code
      )
    );

-- 3.16 Add Index for column "Warehouse" in table "boxes"
    -- !!!NOTE!!!: index should NOT be used on small tables in practice

-- 3.17 Print all the existing indexes
    -- !!!NOTE!!!: index should NOT be used on small tables in practice

-- 3.18 Remove (drop) the index you added just
    -- !!!NOTE!!!: index should NOT be used on small tables in practice
