Use ITI


--1
CREATE VIEW StudentCourseGrades AS
SELECT 
    s.st_fname + ' ' + s.st_lname AS StudentFullName,
    c.crs_name AS CourseName,
    sc.Grade
FROM 
    Student AS s
JOIN 
    Stud_Course AS sc ON s.st_id = sc.st_id
JOIN 
    Course AS c ON sc.crs_id = c.crs_id
WHERE 
    sc.Grade > 50;

select * from StudentCourseGrades;


--2
create view VMGR_Topics
with encryption
as
	select distinct i.Ins_Name as [Name], t.Top_Name as [Topic]
	from Instructor i inner join Ins_Course ic on i.Ins_Id = ic.Ins_Id
	inner join Topic t on t.Top_Id = (select Top_Id
										from Course
										where Crs_Id = ic.Crs_Id)
	where exists (select Dept_Manager
							from Department
							where i.Ins_Id = Dept_Manager)

select * from VMGR_Topics;

--3
CREATE VIEW InstructorDepartment AS
SELECT
    i.Ins_Name AS InstructorName,
    d.dept_name AS DepartmentName
FROM 
    Instructor AS i
JOIN 
    Department AS d ON i.dept_id = d.dept_id
WHERE 
    d.dept_name IN ('SD', 'Java');

select * from InstructorDepartment;

--4
CREATE VIEW V1 AS
SELECT 
    *
FROM 
    Student
WHERE 
    st_address IN ('Alex', 'Cairo');

select * from V1;


--5
use Company_SD

create view ProjectWorkers
as
	select p.Pname as [Project], COUNT(w.ESSn) as [Number of Employees]
	from Project p inner join Works_for w on p.Pnumber = w.Pno
	group by p.Pname

select * from ProjectWorkers;
--6

CREATE SCHEMA Company;
ALTER SCHEMA Company TRANSFER dbo.Departments;
ALTER SCHEMA Company TRANSFER dbo.Project;


CREATE SCHEMA HumanResource
ALTER SCHEMA HumanResource transfer dbo.Employee

--7
use ITI

select TABLE_SCHEMA, TABLE_NAME, TABLE_CATALOG, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_SCHEMA not in ('information_schema', 'sys')
order by TABLE_SCHEMA, TABLE_NAME