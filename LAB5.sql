USE ITI

---1
CREATE PROCEDURE GetStudentPerDepartment
AS
BEGIN
    SELECT d.Dept_Name, COUNT(s.St_Id) AS StudentCount
    FROM Student s
    JOIN Department d ON s.Dept_Id = d.Dept_Id
    GROUP BY d.Dept_Name;
END;
	
EXEC GetStudentPerDepartment

---2
USE Company_SD
CREATE PROCEDURE CheckEmployeesInProjectP1
AS
BEGIN
    DECLARE @EmployeeCount INT;

    
    SELECT @EmployeeCount = COUNT(*)
    FROM Employee e
    JOIN Works_For w ON e.SSN = w.ESSn
    WHERE w.Pno = '400';

    
    IF @EmployeeCount >= 3
    BEGIN
        PRINT 'The number of employees in the project p1 is 3 or more';
    END
    ELSE
    BEGIN
        PRINT 'The following employees work for the project p1:';

        
        SELECT e.Fname, e.Lname
        FROM Employee e
        JOIN Works_For w ON e.SSN = w.ESSn
        WHERE w.Pno = '400'; 
    END
END;


EXEC CheckEmployeesInProjectP1


--3
USE Company_SD
CREATE PROCEDURE ReplaceEmployeeInProject
    @OldEmpNumber INT,
    @NewEmpNumber INT,
    @ProjectNumber INT
AS
BEGIN
    
    UPDATE Works_for
    SET ESSn = @NewEmpNumber
    WHERE ESSn = @OldEmpNumber AND Pno = @ProjectNumber;

    
    IF @@ROWCOUNT > 0
    BEGIN
        PRINT 'Successfully replaced employee in the project.';
    END
    ELSE
    BEGIN
        PRINT 'No records found for the specified old employee or project.';
    END
END;

EXEC ReplaceEmployeeInProject @OldEmpNumber = 112233, @NewEmpNumber = 223344, @ProjectNumber = 500;


--4
ALTER TABLE Project
ADD Budget DECIMAL(18, 2);

UPDATE Project
SET Budget = 100000 
WHERE Pnumber = '600'; 

CREATE TABLE Audit (
    ProjectNo VARCHAR(50),
    UserName VARCHAR(50),
    ModifiedDate DATETIME,
    Budget_Old DECIMAL(18, 2),
    Budget_New DECIMAL(18, 2)
);

CREATE TRIGGER trg_AuditBudgetUpdate
ON Project
FOR UPDATE
AS
BEGIN
    DECLARE @ProjectNo VARCHAR(50);
    DECLARE @OldBudget DECIMAL(18, 2);
    DECLARE @NewBudget DECIMAL(18, 2);
    DECLARE @UserName VARCHAR(50) = SYSTEM_USER; 

    
    SELECT @ProjectNo = inserted.Pnumber,
           @NewBudget = inserted.Budget,
           @OldBudget = deleted.Budget
    FROM inserted
    JOIN deleted ON inserted.Pnumber = deleted.Pnumber
    WHERE inserted.Budget <> deleted.Budget; 

   
    INSERT INTO Audit (ProjectNo, UserName, ModifiedDate, Budget_Old, Budget_New)
    VALUES (@ProjectNo, @UserName, GETDATE(), @OldBudget, @NewBudget);
END;

UPDATE Project
SET Budget = 200000
WHERE Pnumber = '600'; 

SELECT * FROM Audit;



--5
USE ITI
CREATE TRIGGER PreventInsertDepartment
ON Department
INSTEAD OF INSERT
AS
BEGIN
    PRINT 'You cannot insert a new record into the Department table.';
END;


INSERT INTO Department (Dept_Name) VALUES ('HR')


--6
USE Company_SD
CREATE TRIGGER PreventInsertInMarch
ON Employee
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @currentDate DATETIME = GETDATE();

    IF MONTH(@currentDate) = 3
    BEGIN
        PRINT 'Inserts are not allowed in the Employee table during March.';
    END
    ELSE
    BEGIN
      
        INSERT INTO Employee (Fname, Lname)
        SELECT Fname, Lname FROM inserted;   
    END
END;

INSERT INTO Employee (Fname, Lname) VALUES ('Saleh', 'Shabibi'); 

--7
use ITI
CREATE TABLE StudentAudit (
    ServerUserName VARCHAR(50),
    Date DATETIME,
    Note VARCHAR(255)
);

CREATE TRIGGER trg_AfterInsertStudent
ON Student
AFTER INSERT
AS
BEGIN
    DECLARE @UserName VARCHAR(50) = SYSTEM_USER; 
    DECLARE @CurrentDate DATETIME = GETDATE(); 
    DECLARE @KeyValue INT; 

    
    SELECT @KeyValue = St_Id 
    FROM inserted;

    
    INSERT INTO StudentAudit (ServerUserName, Date, Note)
    VALUES (@UserName, @CurrentDate, 
            CONCAT(@UserName, ' Insert New Row with Key=', @KeyValue, ' in table Student'));
END;

INSERT INTO Student (St_Id, St_Fname, St_Lname) 
VALUES (15, 'MOHAMMED', 'MANWARI');


--8
CREATE TRIGGER trg_InsteadOfDeleteStudent
ON Student
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @UserName VARCHAR(50) = SYSTEM_USER;
    DECLARE @CurrentDate DATETIME = GETDATE();
    DECLARE @KeyValue INT; 

    
    SELECT @KeyValue = St_Id 
    FROM deleted;

    
    INSERT INTO StudentAudit (ServerUserName, Date, Note)
    VALUES (@UserName, @CurrentDate, 
            CONCAT('Try to delete Row with Key=', @KeyValue));

   
END;

DELETE FROM Student
WHERE St_Id = 19;

