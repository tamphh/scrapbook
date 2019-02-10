-- LINK : https://en.wikibooks.org/wiki/SQL_Exercises/Employee_management
-- 2.1 Select the last name of all employees.
select 
  LastName 
from 
  Employees;
-- 2.2 Select the last name of all employees, without duplicates.
select 
  distinct LastName 
from 
  Employees;
-- 2.3 Select all the data of employees whose last name is "Smith".
select 
  * 
from 
  Employees 
where 
  LastName = 'Smith';
-- 2.4 Select all the data of employees whose last name is "Smith" or "Doe".
select 
  * 
from 
  Employees 
where 
  LastName in ('Smith', 'Doe');
-- 2.5 Select all the data of employees that work in department 14.
select 
  * 
from 
  Employees 
where 
  Department = 14;
-- 2.6 Select all the data of employees that work in department 37 or department 77.
select 
  * 
from 
  Employees 
where 
  Department in (37, 77);
-- 2.7 Select all the data of employees whose last name begins with an "S".
select 
  * 
from 
  Employees 
where 
  LastName like 'S%';
