-- Employee table (superclass)
CREATE TABLE Employee (
    EmployeeID NUMBER PRIMARY KEY,
    FirstName VARCHAR2(50),
    LastName VARCHAR2(50)
);

-- Doctor table (subclass of Employee)
CREATE TABLE Doctor (
    EmployeeID NUMBER UNIQUE NOT NULL,
    Specialization VARCHAR2(100),
    CONSTRAINT fk_doctor_employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Pharmacist table (subclass of Employee)
CREATE TABLE Pharmacist (
    EmployeeID NUMBER UNIQUE NOT NULL,
    CONSTRAINT fk_pharmacist_employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

--  Receptionist table (subclass of Employee)
CREATE TABLE Receptionist (
    EmployeeID NUMBER UNIQUE NOT NULL,
    CONSTRAINT fk_receptionist_employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Create the Patient table
CREATE TABLE Patient (
    HealthCardNumber VARCHAR2(20) PRIMARY KEY,
    FirstName VARCHAR2(50),
    LastName VARCHAR2(50),
    DateOfBirth DATE,
    PhoneNumber VARCHAR2(15)
);

-- Create the Billing table
CREATE TABLE Billing (
    BillingID NUMBER PRIMARY KEY,
    TotalAmount NUMBER
);

-- Create the Medication table
CREATE TABLE Medication (
    MedicationID NUMBER PRIMARY KEY,
    Description VARCHAR2(100),
    QuantityInStock NUMBER
);

// Testing INSERT
/*
INSERT INTO Employee (EmployeeID, FirstName, LastName) VALUES (123, 'Sarim', 'Shahwar');
INSERT INTO Employee (EmployeeID, FirstName, LastName) VALUES (456, 'Adrian', 'Yu');
INSERT INTO Employee (EmployeeID, FirstName, LastName) VALUES (789, 'Ishan', 'Patel');
INSERT INTO Pharmacist (EmployeeID) VALUES (123);
INSERT INTO Doctor (EmployeeID, Specialization) VALUES (456, 'Cardiology');
INSERT INTO Receptionist (EmployeeID) VALUES (789);
INSERT INTO Patient (HealthCardNumber, FirstName, LastName, DateOfBirth, PhoneNumber) VALUES (674, 'John', 'Stone','2003-12-23', '416-999-9999');
INSERT INTO Patient (HealthCardNumber, FirstName, LastName, DateOfBirth, PhoneNumber) VALUES (234, 'Bob', 'Wood','1998-06-15', '416-777-7777');
INSERT INTO Billing (BillingID, TotalAmount) VALUES (902,523);
INSERT INTO Medication (MedicationID, Description, QuantityInStock) VALUES (12, 'Good, Expires: Sept, 20, 2025', 7);
*/

// Delete date from tables
/*
DELETE FROM Billing;
DELETE FROM Doctor;
DELETE FROM Employee;
DELETE FROM Medication;
DELETE FROM Patient;
DELETE FROM Pharmacist;
DELETE FROM Receptionist;
*/

// Simple Queries

// Patient Queries
-- Listing all Patients and Information
SELECT DISTINCT FirstName, LastName, TO_CHAR(DateOfBirth, 'YYYY-MM-DD') AS "Date Of Birth" FROM Patient ORDER BY LastName, FirstName;

// Doctor Queries
-- Listing all Doctors and Specialization
SELECT DISTINCT E.FirstName AS "Doctor First Name", E.LastName AS "Doctor LastName", D.Specialization FROM Doctor D JOIN Employee E ON D.EmployeeID = E.EmployeeID ORDER BY E.LastName, E.FirstName;

// Pharmacist Queries
-- Listing all Pharmacists and their EmployeeID
SELECT DISTINCT E.FirstName AS "Pharmacist First Name", E.LastName AS "Pharmacist LastName", P.EmployeeID AS "EmployeeID" FROM Pharmacist P JOIN Employee E ON P.EmployeeID = E.EmployeeID ORDER BY E.LastName, E.FirstName;

// Receptionist Queries
-- Listing all Receptionist and their EmployeeID
SELECT DISTINCT E.FirstName AS "Receptionist First Name", E.LastName AS "Receptionist LastName", R.EmployeeID AS "EmployeeID" FROM Receptionist R JOIN Employee E ON R.EmployeeID = E.EmployeeID ORDER BY E.LastName, E.FirstName;

// Medication Queries
-- Listing all medications and their quantities
SELECT DISTINCT MedicationID AS "Medication ID", Description AS "Description", QuantityInStock AS "Quantity In Stock" FROM Medication ORDER BY "Medication ID";

// Billing Queries
-- Listing all Patients and the amount their due for their billings
SELECT DISTINCT 'Total Billing Due for All Patients' AS "Description", SUM(TotalAmount) AS "Total Amount" FROM Billing ORDER BY "Description";

// Employee Queries
-- Listing all Employees and their EmployeeID
SELECT DISTINCT E.FirstName AS "Employee First Name", E.LastName AS "Employee Last Name", E.EmployeeID FROM Employee E ORDER BY E.LastName, E.FirstName;

// VIEWs

-- Patient's Billing Summary View
CREATE VIEW PatientsBillingSummary AS
SELECT P.HealthCardNumber, P.FirstName, P.LastName, TO_CHAR(P.DateOfBirth, 'YYYY-MM-DD') AS "Date Of Birth", P.PhoneNumber, B.TotalAmount AS "Total Billing Amount"
FROM Patient P
JOIN Billing B ON P.HealthCardNumber = B.BillingID;

-- Medication Inventory View
CREATE VIEW Medications AS
SELECT M.MedicationID, M.Description AS "Medication Description", M.QuantityInStock AS "Quantity in Stock"
FROM Medication M;

-- Doctor Specialization View
CREATE VIEW DoctorsSpecialization AS
SELECT E.EmployeeID, E.FirstName, E.LastName, D.Specialization AS "Doctor Specialization"
FROM Employee E
JOIN Doctor D ON E.EmployeeID = D.EmployeeID;

// Join Queries

-- Listing patients and their total billings
SELECT P.HealthCardNumber, P.FirstName AS PatientFirstName, P.LastName AS PatientLastName, P.DateOfBirth, P.PhoneNumber, B.BillingID, B.TotalAmount
FROM Patient P
LEFT JOIN Billing B ON P.HealthCardNumber = B.BillingID;

-- Listing Patients who have a billing total to more than $100 in descending order
SELECT p.HealthCardNumber AS "Patient HealthCardNumber",
       p.FirstName AS "Patient First Name",
       p.LastName AS "Patient Last Name",
       b.BillingID AS "Billing ID",
       b.TotalAmount AS "Total Amount"
FROM Patient p
JOIN Billing b ON p.HealthCardNumber = b.BillingID
WHERE b.TotalAmount > 100 
ORDER BY b.TotalAmount DESC;

-- Listing all the cardiolgy doctor in ascending order from their employee id
SELECT e.EmployeeID, e.FirstName, e.LastName
FROM Employee e
JOIN Doctor d ON e.EmployeeID = d.EmployeeID
WHERE d.Specialization = 'Cardiology'
ORDER BY e.EmployeeID ASC;

-- Listing medication, quantity in stock and billing total
SELECT M.MedicationID, M.Description, M.QuantityInStock, B.BillingID, B.TotalAmount
FROM Medication M
JOIN Billing B ON M.MedicationID = B.BillingID;

-- Listing all employees and their jobs
SELECT EmployeeID, FirstName, LastName, EmployeeType
FROM (
    SELECT E.EmployeeID, E.FirstName, E.LastName, 'Employee' AS EmployeeType
    FROM Employee E

    UNION ALL

    SELECT D.EmployeeID, E.FirstName, E.LastName, 'Doctor' AS EmployeeType
    FROM Doctor D
    JOIN Employee E ON D.EmployeeID = E.EmployeeID

    UNION ALL

    SELECT P.EmployeeID, E.FirstName, E.LastName, 'Pharmacist' AS EmployeeType
    FROM Pharmacist P
    JOIN Employee E ON P.EmployeeID = E.EmployeeID

    UNION ALL

    SELECT R.EmployeeID, E.FirstName, E.LastName, 'Receptionist' AS EmployeeType
    FROM Receptionist R
    JOIN Employee E ON R.EmployeeID = E.EmployeeID
) 
WHERE EmployeeType != 'Employee';

-- List a doctor who who specializes in Cardiology
SELECT e.EmployeeID, e.FirstName, e.LastName, 'Doctor' AS EmployeeType
FROM Employee e
WHERE EXISTS (
    SELECT 1
    FROM Doctor d
    WHERE d.EmployeeID = e.EmployeeID AND d.Specialization = 'Cardiology'
);

-- Listing employees who are not doctors
SELECT e.EmployeeID, e.FirstName, e.LastName
FROM Employee e
WHERE e.EmployeeID NOT IN (
    SELECT d.EmployeeID
    FROM Doctor d
);

-- List all the medicine which is low in stock
SELECT Description, COUNT(*) AS "Low Stock"
FROM Medication
WHERE QuantityInStock < 20
GROUP BY Description
HAVING COUNT(*) > 0
ORDER BY "Low Stock" DESC;

SELECT Description, SUM(QuantityInStock) AS "Total Quantity In Stock"
FROM Medication
GROUP BY Description
HAVING SUM(QuantityInStock) > 1000
ORDER BY "Total Quantity In Stock" DESC;

INSERT INTO Medication (MedicationID, Description, QuantityInStock) VALUES (16, 'Lisinopril: Treat HBP', 1500);

INSERT INTO Employee (EmployeeID, FirstName, LastName) VALUES (1000, 'John', 'Doe');
INSERT INTO Employee (EmployeeID, FirstName, LastName) VALUES (1001, 'Noah', 'Wilson');
INSERT INTO Employee (EmployeeID, FirstName, LastName) VALUES (1002, 'Jackson', 'Lee');
INSERT INTO Doctor (EmployeeID, Specialization) VALUES (1000, 'Cardiology');
INSERT INTO Doctor (EmployeeID, Specialization) VALUES (1001, 'Cardiology');
INSERT INTO Doctor (EmployeeID, Specialization) VALUES (1002, 'Neurology');

INSERT INTO Employee (EmployeeID, FirstName, LastName) VALUES (2000, 'Emily', 'Johnson');
INSERT INTO Employee (EmployeeID, FirstName, LastName) VALUES (2001, 'Emma', 'Clark');
INSERT INTO Employee (EmployeeID, FirstName, LastName) VALUES (2002, 'Mason', 'Martin');
INSERT INTO Pharmacist (EmployeeID) VALUES (2000);
INSERT INTO Pharmacist (EmployeeID) VALUES (2001);
INSERT INTO Pharmacist (EmployeeID) VALUES (2002);

INSERT INTO Employee (EmployeeID, FirstName, LastName) VALUES (3000, 'Liam', 'Smith');
INSERT INTO Employee (EmployeeID, FirstName, LastName) VALUES (3001, 'James', 'Jackson');
INSERT INTO Receptionist (EmployeeID) VALUES (3000);
INSERT INTO Receptionist (EmployeeID) VALUES (3001);

INSERT INTO Medication (MedicationID, Description, QuantityInStock) VALUES (1, 'Aspirin: Treats fever', 1500);
INSERT INTO Medication (MedicationID, Description, QuantityInStock) VALUES (2, 'Ibuprofen: Relieves pain', 15);
INSERT INTO Medication (MedicationID, Description, QuantityInStock) VALUES (3, 'Acetaminophen: Relieves aches and pains', 2000);
INSERT INTO Medication (MedicationID, Description, QuantityInStock) VALUES (4, 'Omeprazole: Reduces stomach acid', 10);

INSERT INTO Patient (HealthCardNumber, FirstName, LastName, DateOfBirth, PhoneNumber) VALUES (674, 'John', 'Stone','2003-12-23', '416-999-9999');
INSERT INTO Patient (HealthCardNumber, FirstName, LastName, DateOfBirth, PhoneNumber) VALUES (234, 'Bob', 'Wood','1998-06-15', '416-777-7777');

INSERT INTO Billing (BillingID, TotalAmount) VALUES (456789,523);
INSERT INTO Billing (BillingID, TotalAmount) VALUES (123456,7274);
INSERT INTO Billing (BillingID, TotalAmount) VALUES (654321,3593);


COMMIT;