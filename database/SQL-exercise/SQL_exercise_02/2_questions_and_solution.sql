-- LINK : https://en.wikibooks.org/wiki/SQL_Exercises/Employee_management
-- 2.1 Select the last name of all employees.
select LastName from Employees;

-- 2.2 Select the last name of all employees, without duplicates.
select distinct LastName from Employees;

-- 2.3 Select all the data of employees whose last name is "Smith".
select * from Employees where LastName = 'Smith';

-- 2.4 Select all the data of employees whose last name is "Smith" or "Doe".
select * from Employees where LastName in ('Smith', 'Doe');

-- 2.5 Select all the data of employees that work in department 14.
select * from Employees where Department = 14;

-- 2.6 Select all the data of employees that work in department 37 or department 77.
select * from Employees where Department in (37, 77);

-- 2.7 Select all the data of employees whose last name begins with an "S".
select * from Employees where LastName like 'S%';

-- 2.8 Select the sum of all the departments' budgets.
select SUM(Budget) from Departments;

-- 2.9 Select the number of employees in each department (you only need to show the department code and the number of employees).
select Department, count(SSN)
from Employees
group by Department;
-- 2.10 Select all the data of employees, including each employee's department's data.
select *
from Employees e
  inner join Departments d on d.code = e.Department;

-- 2.11 Select the name and last name of each employee, along with the name and budget of the employee's department.
select e.Name, e.LastName, d.Name, d.budget
from Employees e
  inner join Departments d on d.code = e.Department;

-- 2.12 Select the name and last name of employees working for departments with a budget greater than $60,000.
select e.Name, e.LastName, d.Name, d.budget
from Employees e
  inner join Departments d on d.code = e.Department and d.budget > 60000;
  
-- 2.13 Select the departments with a budget larger than the average budget of all the departments.
select * from Departments
  where Budget > (
    select avg(Budget) from Departments
  );
    
-- 2.14 Select the names of departments with more than two employees.
select d.Name
from Employees e
  inner join Departments d on d.Code = e.Department
group by Department
having count(e.Department) > 2;

-- 2.15 Very Important - Select the name and last name of employees working for departments with second lowest budget.
-- ref: https://www.programmerinterview.com/index.php/database-sql/find-nth-highest-salary-sql/
select e.Name, e.LastName
  from Employees e
  inner join Departments d on d.Code = e.Department
  where d.budget = (
      select Budget from Departments
      order by Budget ASC
      limit 1,1
    );

/* With subquery */
SELECT e.Name, e.LastName
FROM Employees e 
WHERE e.Department = (
       SELECT sub.Code 
       FROM (SELECT * FROM Departments d ORDER BY d.budget LIMIT 2) sub 
       ORDER BY budget DESC LIMIT 1);
       
-- 2.16  Add a new department called "Quality Assurance", with a budget of $40,000 and departmental code 11. 
-- And Add an employee called "Mary Moore" in that department, with SSN 847-21-9811.

-- 2.17 Reduce the budget of all departments by 10%.

-- 2.18 Reassign all employees from the Research department (code 77) to the IT department (code 14).

-- 2.19 Delete from the table all employees in the IT department (code 14).

-- 2.20 Delete from the table all employees who work in departments with a budget greater than or equal to $60,000.
