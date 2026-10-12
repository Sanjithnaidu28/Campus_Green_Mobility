package com.campusgreen.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.campusgreen.model.Booking;
import com.campusgreen.util.DBConnection;

public class BookingDAO {

    // Emission factor difference (kg CO2 per km) between an average private
    // vehicle trip and this green-mobility trip. Simple, editable constant.
    public static final double EMISSION_FACTOR_DIFF = 0.12;

    public double calculateCo2Saved(double distanceKm) {
        return distanceKm * EMISSION_FACTOR_DIFF;
    }

    /**
     * Turns a live seat hold into a confirmed booking, all in ONE transaction:
     * the hold is consumed, the seat is counted as booked, the booking row is saved and
     * the student's CO2 total is updated. If the hold has already expired (or never
     * existed) nothing is changed and false is returned.
     */
    public boolean createBookingFromHold(int studentId, int slotId, double distanceKm) {
        double co2Saved = calculateCo2Saved(distanceKm);
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                // The hold must still be alive, and deleting it proves it was ours
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM Seat_Holds WHERE student_id = ? AND slot_id = ? AND expires_at > NOW()")) {
                    ps.setInt(1, studentId);
                    ps.setInt(2, slotId);
                    if (ps.executeUpdate() == 0) { con.rollback(); return false; }
                }

                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE Vehicles_Slots SET booked_count = booked_count + 1 " +
                        "WHERE slot_id = ? AND booked_count < capacity")) {
                    ps.setInt(1, slotId);
                    if (ps.executeUpdate() == 0) { con.rollback(); return false; }
                }

                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO Bookings (student_id, slot_id, distance_km, co2_saved_kg) VALUES (?, ?, ?, ?)")) {
                    ps.setInt(1, studentId);
                    ps.setInt(2, slotId);
                    ps.setDouble(3, distanceKm);
                    ps.setDouble(4, co2Saved);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE Students SET total_co2_saved_kg = total_co2_saved_kg + ? WHERE student_id = ?")) {
                    ps.setDouble(1, co2Saved);
                    ps.setInt(2, studentId);
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

    public int createBooking(int studentId, int slotId, double distanceKm, double co2Saved) {
        String sql = "INSERT INTO Bookings (student_id, slot_id, distance_km, co2_saved_kg) VALUES (?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, studentId);
            ps.setInt(2, slotId);
            ps.setDouble(3, distanceKm);
            ps.setDouble(4, co2Saved);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public List<Booking> getBookingsForStudent(int studentId) {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT b.*, v.vehicle_type, v.route, v.slot_time " +
                     "FROM Bookings b JOIN Vehicles_Slots v ON b.slot_id = v.slot_id " +
                     "WHERE b.student_id = ? ORDER BY b.booked_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking b = new Booking();
                    b.setBookingId(rs.getInt("booking_id"));
                    b.setStudentId(rs.getInt("student_id"));
                    b.setSlotId(rs.getInt("slot_id"));
                    b.setDistanceKm(rs.getDouble("distance_km"));
                    b.setCo2SavedKg(rs.getDouble("co2_saved_kg"));
                    b.setBookedAt(rs.getString("booked_at"));
                    b.setVehicleType(rs.getString("vehicle_type"));
                    b.setRoute(rs.getString("route"));
                    b.setSlotTime(rs.getString("slot_time"));
                    list.add(b);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
