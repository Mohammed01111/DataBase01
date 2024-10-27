Use Company_SD


--1
SELECT D.DEPENDENT_NAME, D.SEX
FROM Dependent D
JOIN Employee E ON D.ESSN = E.SSN
WHERE D.SEX = 'F' AND E.SEX = 'F'
UNION
SELECT D.DEPENDENT_NAME, D.SEX
FROM Dependent D
JOIN Employee E ON D.ESSN = E.SSN
WHERE D.SEX = 'M' AND E.SEX = 'M';


--2
SELECT P.Pname, SUM(W.HOURS) AS TotalHours
FROM Project P
JOIN Works_for W ON P.Pnumber = W.Pno
GROUP BY P.PNAME;


--3

SELECT d.*
FROM Departments d
JOIN Employee e ON d.Dnum = e.DNO
WHERE e.SSN = (SELECT MIN(SSN) FROM Employee);


--4
SELECT D.Dname, MAX(E.Salary) AS MaxSalary, MIN(E.Salary) AS MinSalary, AVG(E.Salary) AS AvgSalary
FROM Departments D
JOIN Employee E ON D.Dnum = E.Dno
GROUP BY D.Dnum, D.Dname;


--5
SELECT E.Fname + ' ' + E.Lname AS FullName
FROM Employee E
WHERE E.SSN IN (SELECT Dno FROM Departments) AND E.SSN NOT IN (SELECT ESSN FROM Dependent);


--6
SELECT D.Dnum, D.Dname, COUNT(*) AS EmployeeCount
FROM Departments D
JOIN Employee E ON D.Dnum = E.Dno
GROUP BY D.Dnum, D.DNAME
HAVING AVG(E.SALARY) < (SELECT AVG(SALARY) FROM Employee);


--7
SELECT E.LNAME + ', ' + E.FNAME AS EmployeeName, P.PNAME AS ProjectName
FROM Employee E
JOIN Works_for W ON E.SSN = W.ESSN
JOIN Project P ON W.PNO = P.Pnumber
ORDER BY E.DNO, E.LNAME, E.FNAME;


--8
SELECT MAX(SALARY) AS MaxSalary
FROM Employee
WHERE SALARY < (SELECT MAX(SALARY) FROM Employee);


--9
SELECT E.Fname + ' ' + E.Lname AS FullName
FROM Employee E
WHERE E.FNAME + ' ' + E.LNAME IN (SELECT DEPENDENT_NAME FROM Dependent);


--10
SELECT E.SSN, E.FNAME + ' ' + E.LNAME AS FullName
FROM Employee E
WHERE EXISTS (SELECT 1 FROM Dependent D WHERE D.ESSN = E.SSN);


--11
INSERT INTO Departments (Dnum, Dname, MGRSSN, [MGRStart Date])
VALUES (100, 'DEPT IT', 112233, '2006-11-01');


--12
UPDATE Departments
SET MGRSSN = 968574, [MGRStart Date] = '2006-11-01'
WHERE Dnum = 100;


--13
UPDATE Departments
SET MGRSSN = 102672, 
    [MGRStart Date] = (SELECT TOP 1 [MGRStart Date] FROM Departments WHERE MGRSSN = 968574 ORDER BY [Dnum])
WHERE Dnum = 20;



--14
UPDATE Employee
SET SUPERSSN = 102672
WHERE SSN = 102660;


--15
DELETE FROM Works_for
WHERE ESSN = 223344;

DELETE FROM Dependent
WHERE ESSN = 223344;

DELETE FROM Employee
WHERE SSN = 223344;


--16
UPDATE Employee
SET SALARY = SALARY * 1.3
WHERE SSN IN (SELECT ESSN FROM Works_for WHERE Pno = (SELECT Pno FROM Project WHERE Pname = 'Al Rabwah'));