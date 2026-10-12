package com.campusgreen.dao;

import java.sql.*;
import com.campusgreen.util.DBConnection;

/**
 * Temporary seat holds, BookMyShow-style.
 * Pressing "Book" holds one seat for HOLD_SECONDS. While the hold is alive the seat
 * counts as taken for everyone else. If the student confirms in time it becomes a real
 * booking, otherwise the hold simply expires and the seat goes back on sale.
 * All time comparisons use the database clock (NOW()), so the web server and browser
 * clocks never matter.
 */
public class SeatHoldDAO {

    public static final int HOLD_SECONDS = 120;

    /**
     * Holds one seat on this slot for the student. If they already hold a seat on this
     * slot, their existing timer is kept. A student can only hold one seat at a time, so
     * any hold they have on another slot is released. Returns false if no seat is free.
     */
    public boolean createHold(int studentId, int slotId) {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                int capacity, booked;
                // Lock the slot row: two students pressing Book on the last seat at the
                // same moment are handled one after the other, never together.
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT capacity, booked_count FROM Vehicles_Slots WHERE slot_id = ? FOR UPDATE")) {
                    ps.setInt(1, slotId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { con.rollback(); return false; }
                        capacity = rs.getInt(1);
                        booked = rs.getInt(2);
                    }
                }

                // Tidy up holds that have run out
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM Seat_Holds WHERE expires_at <= NOW()")) {
                    ps.executeUpdate();
                }

                // Already holding this slot? Keep the existing timer.
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT 1 FROM Seat_Holds WHERE student_id = ? AND slot_id = ?")) {
                    ps.setInt(1, studentId);
                    ps.setInt(2, slotId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) { con.commit(); return true; }
                    }
                }

                // One hold at a time per student
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM Seat_Holds WHERE student_id = ?")) {
                    ps.setInt(1, studentId);
                    ps.executeUpdate();
                }

                int held;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT COUNT(*) FROM Seat_Holds WHERE slot_id = ? AND expires_at > NOW()")) {
                    ps.setInt(1, slotId);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        held = rs.getInt(1);
                    }
                }

                if (capacity - booked - held <= 0) {
                    con.rollback();
                    return false;
                }

                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO Seat_Holds (student_id, slot_id, expires_at) " +
                        "VALUES (?, ?, DATE_ADD(NOW(), INTERVAL ? SECOND))")) {
                    ps.setInt(1, studentId);
                    ps.setInt(2, slotId);
                    ps.setInt(3, HOLD_SECONDS);
                    ps.executeUpdate();
                }
                con.commit();
                return true;
            } catch (SQLException e) {
                con.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Whole seconds left on this student's hold for this slot, or 0 if there is no live hold
    public int secondsLeft(int studentId, int slotId) {
        String sql = "SELECT TIMESTAMPDIFF(SECOND, NOW(), expires_at) FROM Seat_Holds " +
                     "WHERE student_id = ? AND slot_id = ? AND expires_at > NOW()";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, slotId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Math.max(rs.getInt(1), 0);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // The slot this student currently holds a seat on, or 0 if none (used for the "Resume" button)
    public int getActiveHoldSlotId(int studentId) {
        String sql = "SELECT slot_id FROM Seat_Holds WHERE student_id = ? AND expires_at > NOW() LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Gives the seat back straight away (used when the student leaves the booking page)
    public void release(int studentId, int slotId) {
        String sql = "DELETE FROM Seat_Holds WHERE student_id = ? AND slot_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, slotId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
