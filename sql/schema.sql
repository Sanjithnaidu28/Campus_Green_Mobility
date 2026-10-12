-- Campus Green Mobility Booking & Carbon-Savings Tracker
-- Run this whole file in MySQL Workbench / mysql CLI before starting Tomcat

CREATE DATABASE IF NOT EXISTS campus_green_mobility;
USE campus_green_mobility;

DROP TABLE IF EXISTS Seat_Holds;
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Vehicles_Slots;
DROP TABLE IF EXISTS Students;

CREATE TABLE Students (
    student_id       INT AUTO_INCREMENT PRIMARY KEY,
    name             VARCHAR(100) NOT NULL,
    email            VARCHAR(100) NOT NULL UNIQUE,
    password         VARCHAR(100) NOT NULL,
    total_co2_saved_kg DOUBLE DEFAULT 0
);

CREATE TABLE Vehicles_Slots (
    slot_id       INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_type  VARCHAR(50) NOT NULL,   -- 'EV Shuttle' or 'Shared Bike'
    route         VARCHAR(100) NOT NULL,
    slot_time     VARCHAR(50) NOT NULL,
    capacity      INT NOT NULL,
    booked_count  INT DEFAULT 0
);

CREATE TABLE Bookings (
    booking_id    INT AUTO_INCREMENT PRIMARY KEY,
    student_id    INT NOT NULL,
    slot_id       INT NOT NULL,
    distance_km   DOUBLE NOT NULL,
    co2_saved_kg  DOUBLE NOT NULL,
    booked_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (slot_id) REFERENCES Vehicles_Slots(slot_id)
);

-- Temporary 2-minute seat holds (BookMyShow-style). A held seat counts as taken
-- until expires_at passes, then it silently goes back on sale.
CREATE TABLE Seat_Holds (
    hold_id     INT AUTO_INCREMENT PRIMARY KEY,
    student_id  INT NOT NULL,
    slot_id     INT NOT NULL,
    expires_at  DATETIME NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (slot_id) REFERENCES Vehicles_Slots(slot_id)
);

-- Sample slots so the availability page has something to show immediately
INSERT INTO Vehicles_Slots (vehicle_type, route, slot_time, capacity, booked_count) VALUES
('EV Shuttle', 'Campus Gate -> Hostel Block C', '08:00 AM', 20, 0),
('EV Shuttle', 'Campus Gate -> Hostel Block C', '05:30 PM', 20, 0),
('Shared Bike', 'Library -> Sports Complex', '09:00 AM', 10, 0),
('Shared Bike', 'Library -> Sports Complex', '04:00 PM', 10, 0),
('EV Shuttle', 'Main Building -> Metro Station', '07:45 AM', 15, 0);
