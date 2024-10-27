use ITI
--1
SELECT 
    i.Ins_Name AS [Name], 
    d.Dept_Name AS [Department Name]
FROM 
    Instructor i 
LEFT JOIN 
    Department d ON i.Dept_Id = d.Dept_Id;


--2
SELECT 
    s.St_Fname + ' ' + s.St_Lname AS [Student Name], 
    c.Crs_Name AS [Course]
FROM 
    Student s 
INNER JOIN 
    Course c ON c.Crs_Id IN (
        SELECT Crs_Id
        FROM Stud_Course
        WHERE St_Id = s.St_Id
        AND Grade IS NOT NULL
    );

--3
SELECT 
    t.Top_Name AS [Topic], 
    COUNT(c.Crs_Id) AS [Courses Number]
FROM 
    Topic t 
INNER JOIN 
    Course c ON c.Top_Id = t.Top_Id
GROUP BY 
    t.Top_Name;

--4
SELECT 
    MAX(Salary) AS [Max Salary], 
    MIN(Salary) AS [Min Salary]
FROM 
    Instructor;


--5
SELECT 
    Dept_Name
FROM 
    Department
WHERE 
    Dept_Id = (
        SELECT TOP 1 Dept_Id
        FROM Instructor
        ORDER BY Salary
    );

--6
SELECT 
    Ins_Name, 
    COALESCE(CONVERT(NVARCHAR(10), Salary), 'Bonus') AS [Salary]
FROM 
    Instructor;


--7
SELECT 
    Dept_Id, 
    Salary
FROM (
    SELECT 
        Dept_Id, 
        Salary, 
        ROW_NUMBER() OVER (PARTITION BY Dept_Id ORDER BY Salary DESC) AS RN
    FROM 
        Instructor
) AS NewTable
WHERE 
    RN < 3 AND Salary IS NOT NULL;


--8
SELECT 
    St_Fname + ' ' + St_Lname AS [Student Name]
FROM (
    SELECT *, ROW_NUMBER() OVER (ORDER BY NEWID()) AS RN
    FROM 
        Student
) AS NewTable
WHERE 
    RN = 1;


--PART2
use AdventureWorks2012
--1
select *
from Production.Product
where Name like 'B%'

--2
UPDATE Production.ProductDescription
SET Description = 'Chromoly steel_High of defects'
WHERE ProductDescriptionID = 3

select *
from Production.ProductDescription
where Description like '%[_]%'

--3
select OrderDate ,SUM(TotalDue) as TotalDue
from Sales.SalesOrderHeader
where OrderDate between '20010701' and '20140731'
group by OrderDate
order by OrderDate

--4
select AVG(distinct ListPrice) as [Average Price]
from Production.Product

--5
select CONCAT('The ', Name, ' is only! $', ListPrice) as [Product Price List]
from Production.Product
where ListPrice between 100 and 120
order by ListPrice

--6
select FORMAT(GETDATE(), 'MMMM dd, yyyy')
union
select FORMAT(GETDATE(), 'dddd MM - dd - yyyy')
union
select FORMAT(GETDATE(), 'dd / MM / yyyy')
union
select FORMAT(GETDATE(), 'yyyy - MM - dd')
union
select FORMAT(GETDATE(), 'yyyy / MM / dd ~ dddd')