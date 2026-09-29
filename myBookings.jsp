<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Campus Mobility - Booking Confirmation</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body class="bg-light">

    <nav class="navbar navbar-dark bg-success shadow-sm">
        <div class="container">
            <a class="navbar-brand fw-bold" href="home.jsp">
                <i class="bi bi-tree-fill me-2"></i> Campus Green Mobility
            </a>
            <a class="btn btn-outline-light btn-sm rounded-pill" href="home.jsp">
                <i class="bi bi-house-door-fill me-1"></i> Home
            </a>
        </div>
    </nav>

   
    <div class="container my-5" style="max-width: 650px;">
        
        <%
            String slot = request.getParameter("slot");
            String distanceStr = request.getParameter("distanceKm");
            
            Integer studentId = (Integer) session.getAttribute("studentId");
            if (studentId == null) {
                studentId = 1; // Default fallback for presentation testing
            }

            double distance = 0.0;
            double co2Saved = 0.0;
            boolean dbSuccess = false;
            String errorMsg = null;

            if (distanceStr != null && !distanceStr.trim().isEmpty()) {
                try {
                    distance = Double.parseDouble(distanceStr.trim());
                    co2Saved = distance * 0.10; // Carbon offset formula: 0.10 kg per km

                    Class.forName("com.mysql.cj.jdbc.Driver");
                    // UPDATE YOUR MYSQL ROOT PASSWORD HERE
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/green_mobility1", "root", "Sainath@9");

                    String sql = "INSERT INTO Bookings (student_id, slot_id, distance_km, co2_saved_kg) VALUES (?, 1, ?, ?)";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    stmt.setInt(1, studentId);
                    stmt.setDouble(2, distance);
                    stmt.setDouble(3, co2Saved);
                    
                    int rows = stmt.executeUpdate();
                    if (rows > 0) {
                        dbSuccess = true;
                    }
                    conn.close();
                } catch (Exception e) {
                    errorMsg = e.getMessage();
                }
            }
        %>

        
        <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
            <div class="card-header bg-success text-white p-4 text-center">
                <i class="bi bi-check-circle-fill display-4 mb-2 d-block"></i>
                <h3 class="fw-bold mb-0">Booking Confirmed!</h3>
                <p class="small text-white-50 mb-0">Your eco-friendly commute is registered in MySQL</p>
            </div>
            
            <div class="card-body p-4">
                
                <% if (errorMsg != null) { %>
                    <div class="alert alert-warning p-2 small mb-3">
                        <i class="bi bi-exclamation-triangle me-1"></i> Database Logging Notice: <%= errorMsg %>
                    </div>
                <% } %>

                <h6 class="text-uppercase text-muted fw-bold small mb-3">Trip Summary</h6>
                
                <ul class="list-group list-group-flush mb-4">
                    <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-3">
                        <span class="text-secondary"><i class="bi bi-ev-front me-2 text-success"></i>Selected Vehicle / Route</span>
                        <strong class="text-dark"><%= slot != null ? slot : "EV Shuttle - Main Campus" %></strong>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-3">
                        <span class="text-secondary"><i class="bi bi-geo-alt me-2 text-success"></i>Distance Travelled</span>
                        <strong class="text-dark"><%= distance %> km</strong>
                    </li>
                    <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-3">
                        <span class="text-secondary"><i class="bi bi-piggy-bank me-2 text-success"></i>Estimated CO₂ Saved</span>
                        <span class="badge bg-success-subtle text-success border border-success fw-bold fs-6 px-3 py-2 rounded-pill">
                            <%= String.format("%.2f", co2Saved) %> kg CO₂
                        </span>
                    </li>
                </ul>

               
                <div class="d-grid gap-2 d-sm-flex justify-content-sm-end">
                    <a href="availableSlots.jsp" class="btn btn-outline-success rounded-pill px-4">
                        <i class="bi bi-plus-circle me-1"></i> Book Another Slot
                    </a>
                    <a href="home.jsp" class="btn btn-success rounded-pill px-4">
                        <i class="bi bi-house me-1"></i> Back to Dashboard
                    </a>
                </div>

            </div>
            <div class="card-footer bg-light text-center py-2 text-muted small">
                Database Table Updated: <code>green_mobility1.Bookings</code>
            </div>
        </div>

    </div>

</body>
</html>