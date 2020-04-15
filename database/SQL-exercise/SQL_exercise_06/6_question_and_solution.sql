-- https://en.wikibooks.org/wiki/SQL_Exercises/Scientists
-- 6.1 List all the scientists' names, their projects' names, 
    -- and the hours worked by that scientist on each project, 
    -- in alphabetical order of project name, then scientist name.
    select p.Name project_name, s.Name scientist_name, p.Hours hours from Scientists s
    left join AssignedTo a
      on a.Scientist = s.SSN
    left join Projects p
      on p.Code = a.Project
    order by project_name, scientist_name;
-- 6.2 Select the project names which are not assigned yet
    select * from Projects p
      left join AssignedTo a
        on a.Project = p.Code
    where a.Project is null;
