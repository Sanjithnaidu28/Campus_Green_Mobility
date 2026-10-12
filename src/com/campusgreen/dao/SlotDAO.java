package com.campusgreen.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.campusgreen.model.Slot;
import com.campusgreen.util.DBConnection;

public class SlotDAO {

    // Every slot comes back with how many seats are on a live (unexpired) hold
    private static final String SELECT_WITH_HOLDS =
        "SELECT v.*, (SELECT COUNT(*) FROM Seat_Holds h " +
        "WHERE h.slot_id = v.slot_id AND h.expires_at > NOW()) AS held_count " +
        "FROM Vehicles_Slots v ";

    public List<Slot> getAllSlots() {
        List<Slot> slots = new ArrayList<>();
        String sql = SELECT_WITH_HOLDS + "ORDER BY v.slot_id";
        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                slots.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return slots;
    }

    public Slot getById(int slotId) {
        String sql = SELECT_WITH_HOLDS + "WHERE v.slot_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, slotId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Atomically increments booked_count ONLY if there is still room.
    // Returns true if the seat was successfully reserved, false if the slot was already full
    // (this is the conflict-check that stops overbooking).
    public boolean tryReserveSeat(int slotId) {
        String sql = "UPDATE Vehicles_Slots SET booked_count = booked_count + 1 " +
                     "WHERE slot_id = ? AND booked_count < capacity";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, slotId);
            return ps.executeUpdate() > 0; // 0 rows updated => slot was already full
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Slot mapRow(ResultSet rs) throws SQLException {
        Slot s = new Slot();
        s.setSlotId(rs.getInt("slot_id"));
        s.setVehicleType(rs.getString("vehicle_type"));
        s.setRoute(rs.getString("route"));
        s.setSlotTime(rs.getString("slot_time"));
        s.setCapacity(rs.getInt("capacity"));
        s.setBookedCount(rs.getInt("booked_count"));
        s.setHeldCount(rs.getInt("held_count"));
        return s;
    }
}
