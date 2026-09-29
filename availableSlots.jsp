<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Available Slots</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <nav class="navbar navbar-dark bg-success">
        <div class="container">
            <a class="navbar-brand" href="home.jsp">Campus Green Mobility</a>
            <div>
                <a class="btn btn-light btn-sm" href="home.jsp">Home</a>
            </div>
        </div>
    </nav>

    <div class="container mt-5" style="max-width: 600px;">
        <div class="card p-4 shadow-sm">
            <h3 class="mb-3 text-success">Book a Vehicle Slot</h3>

            <form action="myBookings.jsp" method="GET">
                <div class="mb-3">
                    <label class="form-label">Select Route & Time:</label>
                    <select name="slot" class="form-select" required>
                        <option value="EV Shuttle (North Gate to Library - 10:00 AM)">EV Shuttle (North Gate to Library - 10:00 AM)</option>
                        <option value="E-Bike (Hostel A to Science Block - 10:30 AM)">E-Bike (Hostel A to Science Block - 10:30 AM)</option>
                        <option value="EV Shuttle (Sports Complex to South Gate - 11:15 AM)">EV Shuttle (Sports Complex to South Gate - 11:15 AM)</option>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label">Trip Distance (in km):</label>
                    <input type="number" step="0.1" name="distanceKm" class="form-control" value="2.5" min="0.1" required>
                </div>

                <button type="submit" class="btn btn-success w-100">Confirm Booking</button>
            </form>
        </div>
    </div>

</body>
</html>