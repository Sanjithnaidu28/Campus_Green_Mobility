-- Run this ONLY if you already created the database with the earlier schema.sql
-- and want to keep your existing students/bookings. It just adds the new table.
-- (If you are starting fresh, run schema.sql instead; it already includes this table.)

USE campus_green_mobility;

CREATE TABLE IF NOT EXISTS Seat_Holds (
    hold_id     INT AUTO_INCREMENT PRIMARY KEY,
    student_id  INT NOT NULL,
    slot_id     INT NOT NULL,
    expires_at  DATETIME NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (slot_id) REFERENCES Vehicles_Slots(slot_id)
);
