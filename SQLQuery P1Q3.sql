
USE HotelBookingSystems;

-- Table for Hotels
CREATE TABLE Hotels(
	HotelID INT IDENTITY PRIMARY KEY ,
	HotelName VARCHAR (255) NOT NULL UNIQUE,
	Location VARCHAR(255) NOT NULL,
    ContactNumber VARCHAR(15) NOT NULL,
	Rating FLOAT CHECK (Rating >= 1 AND Rating <= 5)
);

-- Table for Rooms
CREATE TABLE Rooms (
    RoomID INT IDENTITY PRIMARY KEY,
    RoomNumber VARCHAR(10) NOT NULL UNIQUE,
    RoomType VARCHAR(50) NOT NULL CHECK (RoomType IN ('Single', 'Double', 'Suite')),
    PricePerNight DECIMAL(10, 2) NOT NULL CHECK (PricePerNight > 0),
    IsAvailable BIT NOT NULL DEFAULT 1,
    HotelID INT,
    FOREIGN KEY (HotelID) REFERENCES Hotels(HotelID) 
);


CREATE TABLE Guests (
    GuestID INT IDENTITY PRIMARY KEY,
    GuestName VARCHAR(255) NOT NULL,
    Contact VARCHAR(255) NOT NULL,
    IDProofType VARCHAR(50) NOT NULL,
    IDProofNumber VARCHAR(50) NOT NULL
);


-- Table for Bookings
CREATE TABLE Bookings (
    BookingID INT IDENTITY PRIMARY KEY,
    BookingDate DATETIME NOT NULL,
    CheckInDate DATETIME NOT NULL,
    CheckOutDate DATETIME NOT NULL,
    Status VARCHAR(20) NOT NULL CHECK (Status IN ('Pending', 'Confirmed', 'Canceled', 'Check-in', 'Check-out')) DEFAULT 'Pending',
    TotalCost DECIMAL(10, 2) NOT NULL,
    RoomID INT,
    GuestID INT,
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID),
    FOREIGN KEY (GuestID) REFERENCES Guests(GuestID) 
);



-- Table for Payments
CREATE TABLE Payments (
    PaymentID INT IDENTITY PRIMARY KEY,
    PaymentDate DATETIME NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0),
    PaymentMethod VARCHAR(50),
    BookingID INT,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID) 
);
SELECT BookingID FROM Bookings;
-- Table for Staff Members
CREATE TABLE StaffMembers (
    StaffID INT IDENTITY PRIMARY KEY,
    StaffName VARCHAR(255) NOT NULL,
    Position VARCHAR(50) NOT NULL,
    ContactNumber VARCHAR(15) NOT NULL,
    HotelID INT,
    FOREIGN KEY (HotelID) REFERENCES Hotels(HotelID) 
);

-- Table for Reviews
CREATE TABLE Reviews (
    ReviewID INT IDENTITY PRIMARY KEY,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comments VARCHAR(255) DEFAULT 'No comments',
    ReviewDate DATETIME NOT NULL,
    HotelID INT,
    GuestID INT,
    FOREIGN KEY (HotelID) REFERENCES Hotels(HotelID) ,
    FOREIGN KEY (GuestID) REFERENCES Guests(GuestID) 
);