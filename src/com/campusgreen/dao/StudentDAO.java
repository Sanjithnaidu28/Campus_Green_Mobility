package com.campusgreen.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.campusgreen.model.Student;
import com.campusgreen.util.DBConnection;

public class StudentDAO {

    // Returns the Student if email+password match, otherwise null
    public Student login(String email, String password) {
        String sql = "SELECT * FROM Students WHERE email = ? AND password = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Returns true if a new account was created, false if the email already exists
    public boolean register(String name, String email, String password) {
        if (emailExists(email)) return false;
        String sql = "INSERT INTO Students (name, email, password, total_co2_saved_kg) VALUES (?, ?, ?, 0)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, password);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private boolean emailExists(String email) {
        String sql = "SELECT student_id FROM Students WHERE email = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Re-fetch fresh totals (used after a new booking is added)
    public Student getById(int studentId) {
        String sql = "SELECT * FROM Students WHERE student_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void addCo2Saved(int studentId, double amount) {
        String sql = "UPDATE Students SET total_co2_saved_kg = total_co2_saved_kg + ? WHERE student_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDouble(1, amount);
            ps.setInt(2, studentId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Leaderboard: students with at least some CO2 saved, highest first
    public List<Student> getTopStudents(int limit) {
        List<Student> list = new ArrayList<>();
        String sql = "SELECT * FROM Students WHERE total_co2_saved_kg > 0 " +
                     "ORDER BY total_co2_saved_kg DESC, name ASC LIMIT ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Student mapRow(ResultSet rs) throws SQLException {
        Student s = new Student();
        s.setStudentId(rs.getInt("student_id"));
        s.setName(rs.getString("name"));
        s.setEmail(rs.getString("email"));
        s.setPassword(rs.getString("password"));
        s.setTotalCo2SavedKg(rs.getDouble("total_co2_saved_kg"));
        return s;
    }
}
