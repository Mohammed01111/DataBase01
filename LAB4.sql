use ITI
--1
CREATE FUNCTION GetMonthName(@MonthName DATE)
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @MName NVARCHAR(10);
    
    -- Get the month name from the input date
    SELECT @MName = DATENAME(MONTH, @MonthName);
    
    RETURN @MName;
END;

-- Example usage
SELECT dbo.GetMonthName(GETDATE()) AS [Month Name];


--2
CREATE FUNCTION GetNumbersBetween(@FirstNo INT, @SecNo INT)
RETURNS @t TABLE (Number INT)
AS
BEGIN
    DECLARE @number INT;
    SET @number = @FirstNo;

    WHILE @number < @SecNo - 1
    BEGIN
        SET @number += 1;
        INSERT INTO @t VALUES (@number);
    END

    RETURN;
END;

-- Example usage
SELECT * FROM GetNumbersBetween(10, 100);

--3
CREATE FUNCTION StudentDeptName(@St_ID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        d.Dept_Name AS [Dept. Name], 
        s.St_Fname + ' ' + s.St_Lname AS [Student]
    FROM 
        Student s 
    INNER JOIN 
        Department d ON s.Dept_Id = d.Dept_Id
    WHERE 
        s.St_Id = @St_ID
);

-- Example usage
SELECT * FROM StudentDeptName(5);

--4
CREATE FUNCTION GetNameStatus(@St_Id INT)
RETURNS NVARCHAR(50)
BEGIN
    DECLARE @StatusMessage NVARCHAR(50);
    DECLARE @FirstName NVARCHAR(50);
    DECLARE @LastName NVARCHAR(50);

    -- Retrieve the first and last names in one query
    SELECT 
        @FirstName = St_Fname, 
        @LastName = St_Lname
    FROM 
        Student
    WHERE 
        St_Id = @St_Id;

    -- Determine the status message based on the names
    IF @FirstName IS NULL AND @LastName IS NULL
        SET @StatusMessage = 'First name & last name are null';
    ELSE IF @FirstName IS NULL
        SET @StatusMessage = 'First name is null';
    ELSE IF @LastName IS NULL
        SET @StatusMessage = 'Last name is null';
    ELSE
        SET @StatusMessage = 'First name & last name are not null';

    RETURN @StatusMessage;
END;

-- Example of calling the function
SELECT dbo.GetNameStatus(2);


--5
CREATE FUNCTION DisplayMngName(@Mgr_ID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        d.Dept_Name, 
        i.Ins_Name AS [Manager Name], 
        d.Manager_hiredate
    FROM 
        Department d
    INNER JOIN 
        Instructor i ON i.Ins_Id = d.Dept_Manager
    WHERE 
        d.Dept_Manager = @Mgr_ID
);

-- Example of calling the function
SELECT * FROM DisplayMngName(3);

--6
CREATE FUNCTION GetPartOfName(@NamePart NVARCHAR(10))
RETURNS @t TABLE
(
    id INT,
    StName NVARCHAR(30)
)
AS
BEGIN
    IF @NamePart = 'first name'   
        INSERT INTO @t 
        SELECT ISNULL(St_Id, 0), ISNULL(St_Fname, 'N/A') 
        FROM Student;
    ELSE IF @NamePart = 'last name'
        INSERT INTO @t 
        SELECT ISNULL(St_Id, 0), ISNULL(St_Lname, 'N/A') 
        FROM Student;
    ELSE IF @NamePart = 'full name'
        INSERT INTO @t 
        SELECT ISNULL(St_Id, 0), 
               ISNULL(St_Fname, 'N/A') + ' ' + ISNULL(St_Lname, 'N/A') 
        FROM Student;

    RETURN;
END;

-- Example of calling the function
SELECT * FROM GetPartOfName('full name');
SELECT * FROM GetPartOfName('last name');

--7
USE Company_SD;

DECLARE EmpCursor CURSOR FOR 
SELECT Salary
FROM HumanResource.Employee
FOR UPDATE;

DECLARE @EmpSal INT;

OPEN EmpCursor;

FETCH NEXT FROM EmpCursor INTO @EmpSal;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @EmpSal < 3000
    BEGIN
        UPDATE HumanResource.Employee
        SET Salary += @EmpSal * 0.1
        WHERE CURRENT OF EmpCursor;
    END
    ELSE
    BEGIN
        UPDATE HumanResource.Employee
        SET Salary += @EmpSal * 0.2
        WHERE CURRENT OF EmpCursor;
    END

    FETCH NEXT FROM EmpCursor INTO @EmpSal;
END

CLOSE EmpCursor;
DEALLOCATE EmpCursor;

-- Display updated SSN and Salary
SELECT SSN, Salary 
FROM HumanResource.Employee;

--8
USE ITI;


DECLARE DepMgrCursor CURSOR FOR 
SELECT 
    i.Ins_Name, 
    d.Dept_Name
FROM 
    Instructor i 
INNER JOIN 
    Department d ON d.Dept_Manager = i.Ins_Id
FOR READ ONLY;

DECLARE @MgrName NVARCHAR(30), @DeptName NVARCHAR(10);

OPEN DepMgrCursor;

FETCH NEXT FROM DepMgrCursor INTO @MgrName, @DeptName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @MgrName AS [Manager Name], @DeptName AS [Dept. Name];
    FETCH NEXT FROM DepMgrCursor INTO @MgrName, @DeptName;
END

CLOSE DepMgrCursor;
DEALLOCATE DepMgrCursor;


--9
DECLARE InsCursor CURSOR FOR 
SELECT 
    Ins_Name
FROM 
    Instructor
WHERE 
    Ins_Name IS NOT NULL
FOR READ ONLY;

DECLARE @InsName NVARCHAR(10), @NameCell NVARCHAR(200) = '';
DECLARE @CheckFirst BIT = 0;

OPEN InsCursor;

FETCH NEXT FROM InsCursor INTO @InsName;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @CheckFirst = 0
        SET @NameCell = CONCAT(@NameCell, @InsName);
    ELSE
        SET @NameCell = CONCAT(@NameCell, ', ', @InsName);

    FETCH NEXT FROM InsCursor INTO @InsName;
    SET @CheckFirst = 1;
END

SELECT @NameCell AS [Names];

CLOSE InsCursor;
DEALLOCATE InsCursor;


