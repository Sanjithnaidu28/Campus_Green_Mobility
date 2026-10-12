package com.campusgreen.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // ---- EDIT THESE THREE LINES TO MATCH YOUR MYSQL SETUP ----
    private static final String URL = "jdbc:mysql://localhost:3306/campus_green_mobility?useSSL=false&serverTimezone=UTC";
    private static final String USER = "root";
    private static final String PASSWORD = "root"; // <-- put your MySQL root password here
    // ------------------------------------------------------------

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found. Did you add mysql-connector-j jar to WEB-INF/lib?", e);
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
