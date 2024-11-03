--Part 2 
--Indexing
CREATE NONCLUSTERED INDEX idx_hotel_name
ON Hotels(HotelName);

CREATE NONCLUSTERED INDEX idx_hotel_rating
ON Hotels(Rating);



CREATE CLUSTERED INDEX idx_hotel_room 
ON Rooms (HotelID,RoomNumber);

CREATE NONCLUSTERED INDEX idx_room_type
ON Rooms (RoomType);




CREATE NONCLUSTERED INDEX idx_GuestID_ 
ON Bookings (GuestID);

CREATE NONCLUSTERED INDEX idx_Status 
ON Bookings (Status);

CREATE NONCLUSTERED INDEX idx_Room_Check
ON Bookings (RoomID, CheckInDate, CheckOutDate);




--views
--1
CREATE VIEW ViewTopRatedHotels 
AS
SELECT 
    h.HotelID AS [HotelID],h.HotelName AS [HotelName],COUNT(r.RoomID) AS TotalRooms,AVG(r.PricePerNight) AS AverageRoomPrice
FROM 
    Hotels h
JOIN 
    Rooms r ON h.HotelID = r.HotelID
WHERE 
    h.Rating > 4.5
GROUP BY 
    h.HotelID, h.HotelName;


select * from ViewTopRatedHotels;

--2
CREATE VIEW ViewGuestBookings AS
SELECT 
    g.GuestID AS GuestID,g.GuestName AS GuestName,COUNT(b.BookingID) AS TotalBookings,SUM(b.TotalCost) AS TotalSpent
FROM 
    guests g
LEFT JOIN 
    bookings b ON g.GuestID = b.GuestID
GROUP BY 
    g.GuestID, g.GuestName;

select * from ViewGuestBookings



CREATE VIEW ViewAvailableRooms AS
SELECT 
    h.HotelID AS HotelID,
    h.HotelName AS HotelName,
    r.RoomType AS RoomType,
    r.PricePerNight AS PricePerNight
FROM 
    hotels h
JOIN 
    rooms r ON h.HotelID = r.HotelID
WHERE 
    r.IsAvailable = 1  
GROUP BY 
    h.HotelID, h.HotelName, r.RoomType, r.PricePerNight;


select * from ViewAvailableRooms




CREATE VIEW ViewBookingSummary AS
SELECT 
    h.HotelID AS HotelID,
    h.HotelName AS HotelName,
    COUNT(b.BookingID) AS TotalBookings,
    SUM(CASE WHEN b.status = 'Confirmed' THEN 1 ELSE 0 END) AS ConfirmedBookings,
    SUM(CASE WHEN b.status = 'Pending' THEN 1 ELSE 0 END) AS PendingBookings,
    SUM(CASE WHEN b.status = 'Canceled' THEN 1 ELSE 0 END) AS CanceledBookings
FROM 
    hotels h
LEFT JOIN 
    bookings b ON h.HotelID = b.HotelHD  
GROUP BY 
    h.HotelID, h.HotelName;


SELECT * FROM ViewBookingSummary








--Functions
CREATE FUNCTION GetHotelAverageRating(@HotelID INT)
RETURNS FLOAT
AS
BEGIN
    RETURN (SELECT AVG(Rating) FROM reviews WHERE HotelID = @HotelID);
END;

SELECT dbo.GetHotelAverageRating(1) AS AverageRating_Hotel1;



CREATE FUNCTION GetNextAvailableRoom(@HotelID INT, @RoomType VARCHAR(50))
RETURNS INT
AS
BEGIN
    RETURN (SELECT TOP 1 RoomID FROM rooms WHERE HotelID = @HotelID AND RoomType= @RoomType AND IsAvailable = 1);
END;



CREATE FUNCTION CalculateOccupancyRate(@HotelID INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @OccupiedRooms INT = (SELECT COUNT(DISTINCT RoomID) FROM bookings WHERE HotelID = @HotelID AND CheckInDate >= DATEADD(DAY, -30, GETDATE()) AND status = 'Confirmed');
    DECLARE @TotalRooms INT = (SELECT COUNT(*) FROM rooms WHERE HotelID = @HotelID);

    RETURN CASE WHEN @TotalRooms = 0 THEN 0 ELSE CAST(@OccupiedRooms AS FLOAT) / @TotalRooms * 100 END;
END;






--Stored Procedures
CREATE PROCEDURE sp_MarkRoomUnavailable
    @RoomID INT
AS
BEGIN
    UPDATE rooms SET IsAvailable = 0 WHERE RoomID = @RoomID;
END;






CREATE PROCEDURE sp_UpdateBookingStatus
    @BookingID INT,
    @NewStatus VARCHAR(20)
AS
BEGIN
    UPDATE bookings SET status = @NewStatus WHERE BookingID = @BookingID;
END;



CREATE PROCEDURE sp_RankGuestsBySpending
AS
BEGIN
    SELECT g.GuestID, g.GuestName, SUM(b.TotalCost) AS TotalSpent,
           RANK() OVER (ORDER BY SUM(b.total_amount) DESC) AS Rank
    FROM guests g
    LEFT JOIN bookings b ON g.GuestID = b.GuestID
    GROUP BY g.GuestID, g.GuestName;
END;




--Triggers

CREATE TRIGGER trg_UpdateRoomAvailability
ON bookings
AFTER INSERT
AS
BEGIN
    UPDATE rooms SET IsAvailable = 0 WHERE RoomID IN (SELECT RoomID FROM inserted);
END;




CREATE TRIGGER trg_CalculateTotalRevenue
ON payments
AFTER INSERT
AS
BEGIN
    UPDATE hotels SET Rating = Rating + (SELECT SUM(amount) FROM inserted) 
    WHERE HotelID IN (SELECT HotelID FROM bookings WHERE BookingID IN (SELECT BookingID FROM inserted));
END;



CREATE TRIGGER trg_CheckInDateValidation
ON bookings
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE CheckInDate > CheckOutDate)
    BEGIN
        RAISERROR('Check-in date cannot be greater than check-out date.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO bookings (CheckInDate) SELECT CheckInDate FROM inserted;
    END
END;



