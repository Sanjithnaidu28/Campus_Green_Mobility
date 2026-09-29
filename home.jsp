<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Campus Mobility - Home</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .hero-banner {
            background: linear-gradient(135deg, #1b5e20 0%, #2e7d32 100%);
            color: white;
            border-radius: 16px;
        }
        .action-card {
            border: none;
            border-radius: 12px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .action-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.08);
        }
    </style>
</head>
<body class="bg-light">

    <%
        String studentName = (String) session.getAttribute("studentName");
        if (studentName == null) {
            studentName = "Student";
        }
    %>

    
    <nav class="navbar navbar-expand-lg navbar-dark bg-success sticky-top shadow-sm">
        <div class="container">
            <a class="navbar-brand fw-bold d-flex align-items-center" href="home.jsp">
                <i class="bi bi-tree-fill me-2"></i> Green Mobility
            </a>
            <div class="d-flex align-items-center text-white">
                <span class="me-3 d-none d-sm-inline"><i class="bi bi-person-circle me-1"></i> Welcome, <strong><%= studentName %></strong></span>
                <a href="login.jsp" class="btn btn-outline-light btn-sm rounded-pill"><i class="bi bi-box-arrow-right"></i> Logout</a>
            </div>
        </div>
    </nav>

   
    <div class="container my-4">

        
        <div class="hero-banner p-4 p-md-5 mb-4 shadow-sm">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h1 class="fw-bold mb-2">Zero-Emission Campus Transit</h1>
                    <p class="lead text-light mb-0" style="opacity: 0.9;">
                        Reserve electric shuttles and e-bikes, track your carbon offset, and help keep our campus eco-friendly.
                    </p>
                </div>
                <div class="col-md-4 text-center d-none d-md-block">
                    <i class="bi bi-ev-front display-1 text-light opacity-75"></i>
                </div>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="card action-card p-3 bg-white shadow-sm d-flex flex-row align-items-center">
                    <div class="bg-success-subtle text-success p-3 rounded-circle me-3">
                        <i class="bi bi-speedometer2 fs-3"></i>
                    </div>
                    <div>
                        <h6 class="text-muted small mb-0">Calculated Savings</h6>
                        <h4 class="fw-bold text-success mb-0">0.10 kg CO₂ / km</h4>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card action-card p-3 bg-white shadow-sm d-flex flex-row align-items-center">
                    <div class="bg-primary-subtle text-primary p-3 rounded-circle me-3">
                        <i class="bi bi-lightning-charge fs-3"></i>
                    </div>
                    <div>
                        <h6 class="text-muted small mb-0">Campus Fleet</h6>
                        <h4 class="fw-bold text-dark mb-0">EV Shuttles & E-Bikes</h4>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card action-card p-3 bg-white shadow-sm d-flex flex-row align-items-center">
                    <div class="bg-warning-subtle text-warning p-3 rounded-circle me-3">
                        <i class="bi bi-award fs-3"></i>
                    </div>
                    <div>
                        <h6 class="text-muted small mb-0">Milestones</h6>
                        <h4 class="fw-bold text-dark mb-0">Badges Unlocked</h4>
                    </div>
                </div>
            </div>
        </div>

        
        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="card action-card h-100 bg-white shadow-sm border-0">
                    <div class="card-body p-4 d-flex flex-column">
                        <div class="d-flex align-items-center mb-3">
                            <i class="bi bi-calendar-check text-success fs-2 me-3"></i>
                            <h4 class="card-title fw-bold mb-0">Available Slots</h4>
                        </div>
                        <p class="card-text text-muted flex-grow-1">
                            Browse active transport routes across campus, select available EV shuttles or e-bikes, and confirm your departure time.
                        </p>
                        <a href="availableSlots.jsp" class="btn btn-success fw-semibold rounded-pill px-4 align-self-start">
                            View Routes & Book <i class="bi bi-arrow-right ms-1"></i>
                        </a>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="card action-card h-100 bg-white shadow-sm border-0">
                    <div class="card-body p-4 d-flex flex-column">
                        <div class="d-flex align-items-center mb-3">
                            <i class="bi bi-journal-bookmark-fill text-primary fs-2 me-3"></i>
                            <h4 class="card-title fw-bold mb-0">My Bookings</h4>
                        </div>
                        <p class="card-text text-muted flex-grow-1">
                            Review your recent ride history, view total distance logged, and check your cumulative carbon offset credits.
                        </p>
                        <a href="myBookings.jsp" class="btn btn-outline-primary fw-semibold rounded-pill px-4 align-self-start">
                            Check Booking History <i class="bi bi-arrow-right ms-1"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <footer class="text-center text-muted small py-3 border-top">
            <p class="mb-0">Campus Green Mobility System &bull; Java JSP / Apache Tomcat / MySQL</p>
        </footer>

    </div>

</body>
</html>