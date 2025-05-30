--Step 1: Database Schema (Tables with Constraints)

CREATE DATABASE AirportTicketingSystemDB;

USE AirportTicketingSystemDB;

--Create Passengers Table
CREATE TABLE Passengers (
    PassengerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    DoB DATE,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Meal VARCHAR(20) CHECK (Meal IN ('Vegetarian', 'Non-Vegetarian')),
    EmergencyContactNumber NVARCHAR(20) NULL
);

 --Create Employees Table
 CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeName NVARCHAR(100),
    Email NVARCHAR(100) UNIQUE,
    Username NVARCHAR(50) UNIQUE,
    EmployeePassword NVARCHAR(100),
    Role VARCHAR(30) CHECK (Role IN ('Ticketing Staff', 'Ticketing Supervisor'))
);

--Create Flights Table
CREATE TABLE Flights (
    FlightID INT PRIMARY KEY IDENTITY(1,1),
    FlightNumber NVARCHAR(10) UNIQUE NOT NULL,
    DepartureTime DATETIME NOT NULL,
    ArrivalTime DATETIME NOT NULL,
    Origin NVARCHAR(100),
    Destination NVARCHAR(100)
);

--Create Reservations Table
CREATE TABLE Reservations (
    PNR NVARCHAR(10) PRIMARY KEY,
    FlightID INT NULL,
    BookingDate DATE NOT NULL DEFAULT GETDATE(),
    RStatus VARCHAR(20) NOT NULL CHECK (RStatus IN ('Confirmed', 'Pending', 'Cancelled')),
    TravelItinerary NVARCHAR(255),
    PassengerID INT NULL,
    FOREIGN KEY (FlightID) REFERENCES Flights(FlightID) ON DELETE SET NULL,
    FOREIGN KEY (PassengerID) REFERENCES Passengers(PassengerID) ON DELETE SET NULL
);

-- Create Tickets Table
CREATE TABLE Tickets (
    TicketID INT PRIMARY KEY IDENTITY(1,1),
    IssueDate DATE,
    IssueTime TIME,
    EBoardingNumber NVARCHAR(20),
    SeatNumber NVARCHAR(5),
    Class VARCHAR(20) CHECK (Class IN ('Business', 'FirstClass', 'Economy')),
    InitialFare DECIMAL(10, 2),
    MealUpgrade BIT DEFAULT 0,
    PreferredSeat BIT DEFAULT 0,
	ExtraBag BIT DEFAULT 0,
    -- Computed charge values based on the choice
    MealUpgradeCharges AS (CASE WHEN MealUpgrade = 1 THEN 20.00 ELSE 0.00 END) PERSISTED,
    PreferredSeatCharges AS (CASE WHEN PreferredSeat = 1 THEN 30.00 ELSE 0.00 END) PERSISTED,
    ExtraBaggageFee AS (CASE WHEN ExtraBag = 1 THEN 100.00 ELSE 0.00 END) PERSISTED,
    -- Total fare calculation
    TotalFareCharged AS (
        InitialFare 
        + CASE WHEN MealUpgrade = 1 THEN 20.00 ELSE 0.00 END
        + CASE WHEN PreferredSeat = 1 THEN 30.00 ELSE 0.00 END
        + CASE WHEN ExtraBag = 1 THEN 100.00 ELSE 0.00 END
    ) PERSISTED,
    PNR NVARCHAR(10) FOREIGN KEY REFERENCES Reservations(PNR) ON DELETE CASCADE,
    FlightID INT FOREIGN KEY REFERENCES Flights(FlightID),
    IssuingEmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID) ON DELETE SET NULL
);

-- Create Baggage Table
CREATE TABLE Baggage (
    BagID INT PRIMARY KEY IDENTITY(1,1),
    BagWeight DECIMAL(5, 2) CHECK (BagWeight > 0),
	BaggageFee DECIMAL(10,2),
    BagStatus VARCHAR(20) CHECK (BagStatus IN ('CheckedIn', 'Loaded')),
    TicketID INT FOREIGN KEY REFERENCES Tickets(TicketID),
    FlightID INT FOREIGN KEY REFERENCES Flights(FlightID)
);


-- Create Seats Table
CREATE TABLE Seats (
    SeatID INT PRIMARY KEY IDENTITY(1,1),
    FlightID INT,
    SeatNumber NVARCHAR(10),
    SeatStatus NVARCHAR(20) NULL CHECK(SeatStatus IN('Available', 'Not-Available', 'Reserved')),
    Class NVARCHAR(20),
    FOREIGN KEY (FlightID) REFERENCES Flights(FlightID),
	UNIQUE (FlightID, SeatNumber)
);

-- Step 2: Sample Data Inserts (19 Records Each)

--Passengers
INSERT INTO Passengers (FirstName, LastName, DoB, Email, Meal, EmergencyContactNumber)
VALUES 
('John', 'Andre', '1980-05-12', 'john.doe@email.com', 'Vegetarian', '07435368967'),
('Jane', 'Smith', '1990-08-22', 'jane.smith@email.com', 'Non-Vegetarian', '07736894240'),
('Peter', 'Parker', '1975-10-01', 'peter.parker@email.com', 'Vegetarian', '07464657850'),
('Bruce', 'Wayne', '1985-02-19', 'bruce.wayne@email.com', 'Non-Vegetarian', '07564533457'),
('Diana', 'Prince', '1984-03-21', 'diana.prince@email.com', 'Vegetarian', '07895053456'),
('Tony', 'Stark', '1970-05-29', 'tony.stark@email.com', 'Non-Vegetarian', '07701234567'),
('Natasha', 'Romanoff', '1982-12-03', 'natasha.romanoff@email.com', 'Vegetarian', '07814553298'),
('Clark', 'Kent', '1988-06-18', 'clark.kent@email.com', 'Non-Vegetarian', '07894567909'),
('Wanda', 'Maximoff', '1992-04-22', 'wanda.maximoff@email.com', 'Vegetarian', '07456789010'),
('Stephen', 'Strange', '1981-11-18', 'stephen.strange@email.com', 'Non-Vegetarian', '07567890123'),
('Scott', 'Lang', '1973-07-10', 'scott.lang@email.com', 'Vegetarian', '07578901234'),
('Peter', 'Quill', '1984-08-25', 'peter.quill@email.com', 'Non-Vegetarian', '07789012345'),
('Gamora', 'Zen', '1990-02-25', 'gamora.zen@email.com', 'Vegetarian', '07780128856'),
('Rocket', 'Raccoon', '1980-01-22', 'rocket.raccoon@email.com', 'Non-Vegetarian', '07890123457'),
('Vision', 'Stone', '1985-05-13', 'vision.stone@email.com', 'Vegetarian', '07903456127'),
('Thor', 'Odinson', '1972-03-29', 'thor.odinson@email.com', 'Non-Vegetarian', '07014567289'),
('Loki', 'Laufeyson', '1995-01-17', 'loki.laufeyson@email.com', 'Vegetarian', '07127767890'),
('Black', 'Widow', '1982-11-22', 'black.widow@email.com', 'Non-Vegetarian', '07634567891'),
('Shuri', 'Panther', '1990-09-23', 'shuri.panther@email.com', 'Vegetarian', '07345678901');

-- Employees
INSERT INTO Employees (EmployeeName, Email, Username, EmployeePassword, Role)
VALUES 
('Alice Johnson', 'alice@email.com', 'alicej', 'pass123', 'Ticketing Staff'),
('Bob Miller', 'bob@email.com', 'bobm', 'secure456', 'Ticketing Supervisor'),
('Charlie Lee', 'charlie@email.com', 'charliel', 'emp789', 'Ticketing Staff'),
('David Kim', 'david@email.com', 'davidk', 'abc123', 'Ticketing Staff'),
('Emma Brown', 'emma@email.com', 'emmab', 'xyz456', 'Ticketing Supervisor'),
('Frank White', 'frank@email.com', 'frankw', 'strongpass', 'Ticketing Staff'),
('Grace Hall', 'grace@email.com', 'graceh', 'pass888', 'Ticketing Staff'),
('Hannah Kim', 'hannah@email.com', 'hannahk', 'pass987', 'Ticketing Supervisor'),
('Ibrahim Syed', 'ibrahim@email.com', 'ibrahims', 'password123', 'Ticketing Staff'),
('Jack Roberts', 'jack@email.com', 'jackr', 'secure789', 'Ticketing Staff'),
('Lily Harper', 'lily@email.com', 'lilyh', 'qwerty123', 'Ticketing Supervisor'),
('Megan Clark', 'megan@email.com', 'meganc', 'admin456', 'Ticketing Staff'),
('Nina Owens', 'nina@email.com', 'ninaow', 'pass321', 'Ticketing Supervisor'),
('Olivia Jones', 'olivia@email.com', 'oliviaj', 'mypassword1', 'Ticketing Staff'),
('Paul Smith', 'paul@email.com', 'pauls', 'admin123', 'Ticketing Staff'),
('Quincy Lee', 'quincy@email.com', 'quincyl', 'mypassword123', 'Ticketing Supervisor'),
('Ruth Adams', 'ruth@email.com', 'ruthad', 'rootpass456', 'Ticketing Staff'),
('Sam Harris', 'sam@email.com', 'samhar', 'secure654', 'Ticketing Staff'),
('Tracy Evans', 'tracy@email.com', 'tracye', 'password789', 'Ticketing Supervisor');


-- Flights (UK domestic flights)
INSERT INTO Flights (FlightNumber, DepartureTime, ArrivalTime, Origin, Destination)
VALUES 
('FL1001', '2025-02-24 08:00', '2025-04-23 09:30', 'London', 'Manchester'),
('FL1002', '2025-04-27 10:00', '2025-04-26 11:30', 'Manchester', 'Birmingham'),
('FL1003', '2025-04-30 14:00', '2025-04-28 15:30', 'Birmingham', 'London'),
('FL1004', '2025-05-03 16:00', '2025-04-30 17:30', 'London', 'Bristol'),
('FL1005', '2025-05-07 08:00', '2025-05-01 09:30', 'Bristol', 'London'),
('FL1006', '2025-05-09 10:00', '2025-05-03 11:30', 'London', 'Liverpool'),
('FL1007', '2025-05-12 18:00', '2025-05-06 19:30', 'Liverpool', 'Manchester');

-- Reservations
INSERT INTO Reservations (PNR, FlightID, BookingDate, RStatus, TravelItinerary, PassengerID)
VALUES 
('PNR1001', 1, '2025-04-24', 'Confirmed', 'London to Manchester', 1),
('PNR1002', 1, '2025-04-25', 'Pending', 'Manchester to Birmingham', 2),
('PNR1003', 1, '2025-04-25', 'Cancelled', 'Birmingham to London', 3),
('PNR1004', 2, '2025-04-26', 'Confirmed', 'London to Bristol', 4),
('PNR1005', 2, '2025-04-27', 'Pending', 'Bristol to London', 5),
('PNR1006', 3, '2025-04-27', 'Confirmed', 'London to Liverpool', 6),
('PNR1007', 3, '2025-04-27', 'Cancelled', 'Liverpool to Manchester', 7),
('PNR1008', 4, '2025-04-28', 'Confirmed', 'Manchester to Bristol', 8),
('PNR1009', 4, '2025-04-29', 'Pending', 'Bristol to Liverpool', 9),
('PNR1010', 5, '2025-04-29', 'Confirmed', 'Liverpool to London', 10),
('PNR1011', 5, '2025-04-30', 'Pending', 'London to Manchester', 11),
('PNR1012', 5, '2025-04-30', 'Cancelled', 'Manchester to Bristol', 12),
('PNR1013', 6, '2025-05-01', 'Confirmed', 'Bristol to London', 13),
('PNR1014', 6, '2025-05-01', 'Pending', 'Liverpool to Bristol', 14),
('PNR1015', 6, '2025-05-02', 'Confirmed', 'London to Manchester', 15),
('PNR1016', 7, '2025-05-03', 'Cancelled', 'Manchester to Liverpool', 16),
('PNR1017', 7, '2025-05-04', 'Confirmed', 'Liverpool to London', 17),
('PNR1018', 7, '2025-05-05', 'Pending', 'London to Bristol', 18),
('PNR1019', 7, '2025-05-06', 'Confirmed', 'Bristol to Liverpool', 19);

-- Tickets
INSERT INTO Tickets (IssueDate, IssueTime, EBoardingNumber, SeatNumber, Class, InitialFare, ExtraBag, MealUpgrade, PreferredSeat, PNR, FlightID, IssuingEmployeeID)
VALUES 
('2025-04-01', '07:30', 'A1234', '1A', 'Business', 500.00,0, 1, 1, 'PNR1001', 1, 1),
('2025-04-02', '09:30', 'B2345', NULL, 'Economy', 150.00, 1, 0, 0, 'PNR1002', 1, 2),
('2025-04-03', '11:30', 'C3456', '1FC', 'FirstClass', 700.00, 0, 1, 1, 'PNR1003', 1, 3),
('2025-04-04', '13:30', 'D4567', '3C', 'Economy', 180.00, 1, 0, 0, 'PNR1004', 2, 4),
('2025-04-05', '15:00', 'E5678', '4D', 'Economy', 160.00, 0, 0, 0, 'PNR1005', 2, 5),
('2025-04-06', '17:00', 'F6789', '5E', 'Business', 550.00, 1, 1, 1, 'PNR1006', 3, 6),
('2025-04-07', '08:00', 'G7890', '6F', 'FirstClass', 750.00, 1, 1, 1, 'PNR1007', 3, 7),
('2025-04-08', '10:00', 'H8901', NULL, 'Economy', 170.00, 0, 0, 0, 'PNR1008', 4, 8),
('2025-04-09', '12:00', 'I9012', '8H', 'Business', 500.00, 0, 1, 1, 'PNR1009', 4, 9),
('2025-04-10', '14:00', 'J0123', '9I', 'Economy', 200.00, 1, 0, 0, 'PNR1010', 5, 10),
('2025-04-11', '16:00', 'K1234', '2FC', 'FirstClass', 750.00, 0, 1, 1, 'PNR1011', 5, 11),
('2025-04-12', '18:00', 'L2345', NULL, 'Economy', 160.00, 1, 0, 0, 'PNR1012', 5, 12),
('2025-04-13', '07:30', 'M3456', '11K', 'Business', 550.00, 1, 1, 1, 'PNR1013', 6, 13),
('2025-04-14', '09:30', 'N4567', '12L', 'Economy', 180.00, 0, 0, 0, 'PNR1014', 6, 14),
('2025-04-15', '11:00', 'O5678', '3FC', 'FirstClass', 800.00, 1, 1, 1, 'PNR1015', 6, 15),
('2025-04-16', '13:00', 'P6789', '13M', 'Economy', 170.00, 0, 0, 0, 'PNR1016', 7, 16),
('2025-04-17', '15:00', 'Q7890', '14N', 'Business', 520.00, 0, 1, 1, 'PNR1017', 7, 17),
('2025-04-18', '17:00', 'R8901', '15O', 'FirstClass', 750.00, 1, 1, 1, 'PNR1018', 7, 18),
('2025-04-19', '19:00', 'S9012', '16P', 'Economy', 160.00, 0, 0, 0, 'PNR1019', 7, 19);

-- Baggage
INSERT INTO Baggage (BagWeight, BaggageFee, BagStatus, TicketID, FlightID)
VALUES 
(15.00, 20.00, 'CheckedIn', 1, 1),
(20.00, 30.00, 'CheckedIn', 2, 1),
(18.00, 22.00, 'Loaded', 3, 2),
(25.00, 40.00, 'CheckedIn', 4, 2),
(22.00, 35.00, 'Loaded', 5, 3),
(19.00, 28.00, 'CheckedIn', 6, 3),
(30.00, 45.00, 'Loaded', 7, 4),
(24.00, 38.00, 'CheckedIn', 8, 4),
(12.00, 15.00, 'Loaded', 9, 5),
(21.00, 33.00, 'CheckedIn', 10, 5),
(17.00, 20.00, 'Loaded', 11, 6),
(23.00, 36.00, 'CheckedIn', 12, 6),
(26.00, 41.00, 'Loaded', 13, 7),
(20.00, 30.00, 'CheckedIn', 14, 7),
(28.00, 45.00, 'Loaded', 15, 1),
(16.00, 18.00, 'CheckedIn', 16, 2),
(14.00, 16.00, 'Loaded', 17, 3),
(27.00, 43.00, 'CheckedIn', 18, 4),
(19.00, 28.00, 'Loaded', 19, 5);

--Seats
INSERT INTO Seats (FlightID, SeatNumber, SeatStatus, Class)
VALUES
(1, '1A', 'Available', 'Business'),
(2, NULL, 'Not-Available', 'Economy'),
(3, '1FC', 'Available', 'FirstClass'),
(4, '3C', 'Available', 'Economy'),
(5, '4D', 'Available', 'Economy'),
(6, '5E', 'Available', 'Business'),
(7, '6F', 'Available', 'FirstClass'),
(1, NULL, 'Not-Available', 'Economy'),
(2, '8H', 'Available', 'Business'),
(3, '9I', 'Available', 'Economy'),
(4, '2FC', 'Available', 'FirstClass'),
(5, NULL, 'Not-Available', 'Economy'),
(6, '11K', 'Available', 'Business'),
(7, '12L', 'Available', 'Economy'),
(1, '3FC', 'Available', 'FirstClass'),
(2, '13M', 'Available', 'Economy'),
(3, '14N', 'Available', 'Business'),
(4, '15O', 'Available', 'FirstClass'),
(5, '16P', 'Available', 'Economy');


--Question 2 (q2): Constraint Checks and Queries

--Check Foreign Key Integrity
-- Add check constraints to ensure booking can not be done in the past
ALTER TABLE Reservations
ADD CONSTRAINT CH_BookingDateNotInThePast CHECK(BookingDate >= CAST(GETDATE() AS DATE));

--Test the constraint
INSERT INTO Reservations (PNR, FlightID, BookingDate, RStatus, TravelItinerary, PassengerID)
VALUES('PNR1020',1,'2025-04-08','Confirmed','London to Manchester',20);

--Question 3 (q3):
-- Identify Passengers with Pending Reservations:
SELECT 
    P.PassengerID,
    P.FirstName + ' ' + P.LastName AS FullName,
    R.PNR,
    R.BookingDate,
    R.RStatus,
    R.TravelItinerary
FROM Passengers P
JOIN Reservations R ON P.PassengerID = R.PassengerID
WHERE R.RStatus = 'Pending';

--To Identify Passengers Older Than 40 Years
SELECT 
    P.PassengerID,
    P.FirstName + ' ' + P.LastName AS FullName,
    P.DOB,
    DATEDIFF(YEAR, P.DOB, GETDATE()) AS Age
FROM Passengers P
WHERE DATEDIFF(YEAR, P.DOB, GETDATE()) > 40;


-- Identify Passengers with Pending Reservations and age > 40
SELECT 
    P.PassengerID,
    P.FirstName + ' ' + P.LastName AS FullName,
    R.PNR,
    R.BookingDate,
    R.RStatus,
    R.TravelItinerary,
	P.DOB,
    DATEDIFF(YEAR, P.DOB, GETDATE()) AS Age
FROM Passengers P
JOIN Reservations R ON P.PassengerID = R.PassengerID
WHERE R.RStatus = 'Pending' AND DATEDIFF(YEAR, P.DOB, GETDATE()) > 40;


--Question 4 (q4): – Stored Procedures and Functions


--(a) Search by Passenger Last Name – Most Recent Ticket First
-- Stored Procedure
CREATE PROCEDURE SearchPassengersByLastName
    @LastName NVARCHAR(50)
AS
BEGIN
    SELECT 
        P.PassengerID,
        P.FirstName,
        P.LastName,
        T.TicketID,
        T.IssueDate,
        T.TotalFareCharged
    FROM Passengers P
    JOIN Reservations R ON P.PassengerID = R.PassengerID
    JOIN Tickets T ON R.PNR = T.PNR
    WHERE P.LastName LIKE '%' + @LastName + '%'
    ORDER BY T.IssueDate DESC;
END;

--To call it
EXEC SearchPassengersByLastName @LastName = 'Smith';

--To call it
EXEC SearchPassengersByLastName @LastName = 'Lang';
DECLARE @LastName NVARCHAR(50)

--(b) List Business Class Passengers with Reservations Today + Their Meal Preference
-- User-Defined Function (Table-Valued)

CREATE FUNCTION GetBusinessClassPassengersToday()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        P.FirstName,
        P.LastName,
        P.Meal,
        R.PNR,
        T.Class,
        R.BookingDate
    FROM Passengers P
    JOIN Reservations R ON P.PassengerID = R.PassengerID
    JOIN Tickets T ON R.PNR = T.PNR
    WHERE T.Class = 'Business' AND R.BookingDate = CAST(GETDATE() AS DATE)
);

--Query from it like a table:
SELECT * FROM dbo.GetBusinessClassPassengersToday();

--(c) Insert New Employee
-- Stored Procedure
CREATE PROCEDURE InsertNewEmployees
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @Username NVARCHAR(50),
    @Password NVARCHAR(50),
    @Role NVARCHAR(20)
AS
BEGIN
    INSERT INTO Employees (EmployeeName, Email, Username, EmployeePassword, Role)
    VALUES (@Name, @Email, @Username, @Password, @Role);
END;
--To call it
EXEC InsertNewEmployees 
    @Name = 'Sarah Obi', 
    @Email = 'sobi@airport.com',
    @Username = 'sobi01',
    @Password = 'secure123',
    @Role = 'Ticketing Staff';

--Test the insert new employees procedure
SELECT * FROM Employees WHERE EmployeeName = 'Sarah Obi';

--(d) Update Passenger Details
-- Stored Procedure
CREATE PROCEDURE UpdatePassengersDetail
    @PassengerID INT,
    @Email NVARCHAR(100),
    @Meal NVARCHAR(20),
    @EmergencyContactNumber NVARCHAR(20)
AS
BEGIN
    UPDATE Passengers
    SET 
        Email = @Email,
        Meal = @Meal,
        EmergencyContactNumber = @EmergencyContactNumber
    WHERE PassengerID = @PassengerID;
END;

--To call it
EXEC UpdatePassengersDetail 
    @PassengerID = 1, 
    @Email = 'john.updated@email.com', 
    @Meal = 'Non-Vegetarian',
    @EmergencyContactNumber = '08012345678';

-- Test the procedure Update Passengers Details
SELECT * FROM Passengers WHERE PassengerID = 1;

--Question 5 (q5) – Create a View for Revenue and Boarding Numbers Issued by Employee

--Create the View
CREATE VIEW ViewRevenueGeneratedByEmployeeOnTicket AS
SELECT 
    E.EmployeeID,
    E.EmployeeName,
    P.FirstName + ' ' + P.LastName AS PassengerName,
    F.FlightNumber,
    T.TicketID,
    T.IssueDate,
    T.SeatNumber,
    T.Class,
    T.InitialFare,
    T.ExtraBaggageFee,
    T.MealUpgradeCharges,
    T.PreferredSeatCharges,
    T.TotalFareCharged,
    T.EBoardingNumber
FROM Employees E
JOIN Tickets T ON E.EmployeeID = T.IssuingEmployeeID
JOIN Reservations R ON T.PNR = R.PNR
JOIN Passengers P ON R.PassengerID = P.PassengerID
JOIN Flights F ON T.FlightID = F.FlightID;

--Query from the View

--View all revenue and boarding info:
SELECT * FROM ViewRevenueGeneratedByEmployeeOnTicket;

--Filter by specific employee:
SELECT * FROM ViewRevenueGeneratedByEmployeeOnTicket
WHERE EmployeeID = 1;

--Group total revenue per flight by employee:
SELECT 
    EmployeeID,
    FlightNumber,
    SUM(TotalFareCharged) AS RevenueGenerated
FROM ViewRevenueGeneratedByEmployeeOnTicket
GROUP BY EmployeeID, FlightNumber;

--Group total revenue per flight:
SELECT 
    FlightNumber,
    SUM(TotalFareCharged) AS RevenueGenerated
FROM ViewRevenueGeneratedByEmployeeOnTicket
GROUP BY FlightNumber
ORDER BY RevenueGenerated DESC;


--Question 6 (q6) – Trigger to Auto-Update Seat Status When Ticket is Issued

--Create Trigger
CREATE TRIGGER trg_SeatAllotmentUpdate
ON Tickets
AFTER INSERT
AS
BEGIN
    -- Update the seat status to 'Reserved' based on the inserted ticket
    UPDATE S
    SET S.SeatStatus = 'Reserved'
    FROM Seats S
    JOIN inserted I ON S.SeatNumber = I.SeatNumber AND S.FlightID = I.FlightID
    WHERE I.SeatNumber IS NOT NULL;
END;

--This trigger fires after a ticket is issued, and sets the seat status to 'Reserved' only if a preferred seat was selected.

--Test the Trigger
--- We check to show that the seat was available
SELECT * FROM Seats WHERE SeatNumber = '3C' AND FlightID = 4;

--Insert a ticket with a specific seat:
INSERT INTO Tickets (
    PNR, FlightID, IssueDate, InitialFare, SeatNumber, Class, IssuingEmployeeID,
    ExtraBag, MealUpgrade, PreferredSeat, EBoardingNumber
)
VALUES (
    'PNR1004', 4, GETDATE(), 200.00, '3C', 'Economy', 1,
    0.00, 0.00, 1, 'EB7890'
);

--To Check
SELECT * FROM Seats WHERE SeatNumber = '3C' AND FlightID = 4;

--Question 7 (q7) – View or Function to Count Checked-In Baggage per Flight on a Specific Date

--Create the Function
CREATE FUNCTION CountCheckedInBaggage (
    @FlightID INT,
    @Date DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @BaggageCount INT;

    -- Count checked-in baggage for the specified flight and date
    SELECT @BaggageCount = COUNT(*)
    FROM Baggage B
    JOIN Tickets T ON B.TicketID = T.TicketID
    WHERE B.FlightID = @FlightID
      AND B.BagStatus = 'CheckedIn'
      AND CAST(T.IssueDate AS DATE) = @Date;

    RETURN @BaggageCount;
END;

--Call the Function
-- Example: Count for flight 1 on April 1, 2025
SELECT dbo.CountCheckedInBaggage(1, '2025-04-01') AS TotalCheckedInBaggage;

--Question 8 (q8) – Additional Queries / Objects

---Extra Query 1: listing passengers who have upgraded their meal preference

-- Create View: Passengers with Meal Upgrade
CREATE VIEW ViewPassengersWithUpgradedMeals AS
SELECT 
    P.PassengerID,
    P.FirstName + ' ' + P.LastName AS FullName,
    T.TicketID,
    T.MealUpgradeCharges,
    T.TotalFareCharged
FROM Passengers P
JOIN Reservations R ON P.PassengerID = R.PassengerID
JOIN Tickets T ON R.PNR = T.PNR
WHERE T.MealUpgradeCharges > 0;

-- Usage of the view to retrieve the results
SELECT * FROM ViewPassengersWithUpgradedMeals
ORDER BY MealUpgradeCharges DESC;


--Extra Query 2: View to Show Upcoming Departures in Next 96 Hours
--Helps employees quickly see imminent flights.
CREATE VIEW SeeUpcomingDepartures AS
SELECT 
    FlightID,
    FlightNumber,
    Origin,
    Destination,
    DepartureTime,
    ArrivalTime
FROM Flights
WHERE DepartureTime BETWEEN GETDATE() AND DATEADD(HOUR, 96, GETDATE());

-- Test See UpComing Departures:
SELECT * FROM SeeUpcomingDepartures;

