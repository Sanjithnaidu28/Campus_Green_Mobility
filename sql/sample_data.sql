-- Sample (fake) data for demos: 8 students and 26 past rides, so the leaderboard,
-- My impact and the seat counts all have something to show.
-- Run this in phpMyAdmin: pick campus_green_mobility on the left, open the SQL tab,
-- paste everything, click Go.
-- Every demo account has the email ending @demo.test and the password demo123.
-- It is safe to run more than once: it removes the old demo rows first, and it never
-- touches accounts you registered yourself.
-- Assumes the 5 sample slots (slot_id 1 to 5) created by schema.sql.

USE campus_green_mobility;
SET SQL_SAFE_UPDATES = 0;

-- 1. clear any earlier copy of the demo data
DELETE FROM Seat_Holds WHERE student_id IN (SELECT student_id FROM Students WHERE email LIKE '%@demo.test');
DELETE FROM Bookings   WHERE student_id IN (SELECT student_id FROM Students WHERE email LIKE '%@demo.test');
DELETE FROM Students   WHERE email LIKE '%@demo.test';

-- 2. the fake students (password for all of them: demo123)
INSERT INTO Students (name, email, password, total_co2_saved_kg) VALUES
('Aarav Mehta', 'aarav@demo.test', 'demo123', 0),
('Isha Rao', 'isha@demo.test', 'demo123', 0),
('Rohan Das', 'rohan@demo.test', 'demo123', 0),
('Meera Nair', 'meera@demo.test', 'demo123', 0),
('Kabir Singh', 'kabir@demo.test', 'demo123', 0),
('Ananya Reddy', 'ananya@demo.test', 'demo123', 0),
('Vikram Patel', 'vikram@demo.test', 'demo123', 0),
('Sneha Iyer', 'sneha@demo.test', 'demo123', 0);

-- 3. their past rides. CO2 saved = distance x 0.12 kg per km, the same formula the website uses
INSERT INTO Bookings (student_id, slot_id, distance_km, co2_saved_kg, booked_at)
SELECT s.student_id, t.slot_id, t.km, t.km * 0.12, t.booked_at
FROM (
    SELECT 'aarav@demo.test' AS email, 1 AS slot_id, 8.5 AS km, '2026-10-01 08:05:00' AS booked_at
    UNION ALL SELECT 'aarav@demo.test', 5, 12.0, '2026-10-02 07:50:00'
    UNION ALL SELECT 'aarav@demo.test', 2, 9.0, '2026-10-03 17:35:00'
    UNION ALL SELECT 'aarav@demo.test', 1, 8.5, '2026-10-06 08:02:00'
    UNION ALL SELECT 'aarav@demo.test', 5, 12.0, '2026-10-07 07:48:00'
    UNION ALL SELECT 'aarav@demo.test', 3, 5.5, '2026-10-09 09:01:00'
    UNION ALL SELECT 'isha@demo.test', 5, 11.0, '2026-10-01 07:46:00'
    UNION ALL SELECT 'isha@demo.test', 1, 7.0, '2026-10-03 08:04:00'
    UNION ALL SELECT 'isha@demo.test', 2, 7.5, '2026-10-06 17:33:00'
    UNION ALL SELECT 'isha@demo.test', 4, 4.5, '2026-10-08 16:02:00'
    UNION ALL SELECT 'isha@demo.test', 1, 7.0, '2026-10-10 08:01:00'
    UNION ALL SELECT 'rohan@demo.test', 3, 6.0, '2026-10-02 09:03:00'
    UNION ALL SELECT 'rohan@demo.test', 4, 6.0, '2026-10-04 16:05:00'
    UNION ALL SELECT 'rohan@demo.test', 5, 10.0, '2026-10-07 07:52:00'
    UNION ALL SELECT 'rohan@demo.test', 2, 8.0, '2026-10-09 17:31:00'
    UNION ALL SELECT 'meera@demo.test', 1, 6.5, '2026-10-03 08:06:00'
    UNION ALL SELECT 'meera@demo.test', 3, 5.0, '2026-10-06 09:02:00'
    UNION ALL SELECT 'meera@demo.test', 5, 9.5, '2026-10-10 07:49:00'
    UNION ALL SELECT 'kabir@demo.test', 2, 7.0, '2026-10-04 17:36:00'
    UNION ALL SELECT 'kabir@demo.test', 4, 5.5, '2026-10-08 16:04:00'
    UNION ALL SELECT 'kabir@demo.test', 1, 6.0, '2026-10-11 08:03:00'
    UNION ALL SELECT 'ananya@demo.test', 3, 4.0, '2026-10-05 09:00:00'
    UNION ALL SELECT 'ananya@demo.test', 5, 8.0, '2026-10-09 07:47:00'
    UNION ALL SELECT 'vikram@demo.test', 1, 5.0, '2026-10-07 08:07:00'
    UNION ALL SELECT 'vikram@demo.test', 4, 3.5, '2026-10-10 16:03:00'
    UNION ALL SELECT 'sneha@demo.test', 3, 3.0, '2026-10-08 09:04:00'
) t
JOIN Students s ON s.email = t.email;

-- 4. recalculate the totals from the ride rows so everything stays consistent
UPDATE Students s
SET s.total_co2_saved_kg = (SELECT COALESCE(SUM(b.co2_saved_kg), 0) FROM Bookings b WHERE b.student_id = s.student_id);

UPDATE Vehicles_Slots v
SET v.booked_count = (SELECT COUNT(*) FROM Bookings b WHERE b.slot_id = v.slot_id);

-- 5. quick check: the leaderboard order you should see on the website
SELECT name, ROUND(total_co2_saved_kg, 2) AS co2_saved_kg
FROM Students WHERE total_co2_saved_kg > 0 ORDER BY total_co2_saved_kg DESC, name;
