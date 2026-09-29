<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Campus Green Mobility - Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-card {
            border: none;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
        }
        .btn-success-custom {
            background-color: #2e7d32;
            border: none;
        }
        .btn-success-custom:hover {
            background-color: #1b5e20;
        }
    </style>
</head>
<body>

    <div class="container" style="max-width: 420px;">
        <div class="card p-4 p-md-5 login-card bg-white">
            <div class="text-center mb-4">
                <div class="d-inline-flex align-items-center justify-content-center bg-success text-white rounded-circle mb-3" style="width: 60px; height: 60px;">
                    <i class="bi bi-tree-fill fs-3"></i>
                </div>
                <h3 class="fw-bold text-success mb-1">Green Mobility</h3>
                <p class="text-muted small mb-0">Campus Sustainable Transit Portal</p>
            </div>

            <%
                String email = request.getParameter("email");
                String password = request.getParameter("password");

                if (email != null && password != null) {
                    email = email.trim();
                    password = password.trim();

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/green_mobility1", "root", "Sainath@9");
                        
                        String sql = "SELECT student_id, name FROM Students WHERE LOWER(email) = LOWER(?) AND password = ?";
                        PreparedStatement stmt = conn.prepareStatement(sql);
                        stmt.setString(1, email);
                        stmt.setString(2, password);
                        ResultSet rs = stmt.executeQuery();

                        if (rs.next()) {
                            session.setAttribute("studentId", rs.getInt("student_id"));
                            session.setAttribute("studentName", rs.getString("name"));
                            response.sendRedirect("home.jsp");
                        } else {
                            out.println("<div class='alert alert-danger p-2 small text-center rounded-3 mb-3'><i class='bi bi-exclamation-triangle-fill me-1'></i> Invalid credentials!</div>");
                        }
                        conn.close();
                    } catch (Exception e) {
                        out.println("<div class='alert alert-danger p-2 small rounded-3 mb-3'>Database Error: " + e.getMessage() + "</div>");
                    }
                }
            %>

            <form action="login.jsp" method="POST">
                <div class="mb-3">
                    <label class="form-label text-secondary small fw-bold">Student Email</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light text-muted"><i class="bi bi-envelope"></i></span>
                        <input type="email" name="email" class="form-control bg-light" placeholder="student@campus.edu" required>
                    </div>
                </div>
                <div class="mb-4">
                    <label class="form-label text-secondary small fw-bold">Password</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light text-muted"><i class="bi bi-lock"></i></span>
                        <input type="password" name="password" class="form-control bg-light" placeholder="••••••••" required>
                    </div>
                </div>
                <button type="submit" class="btn btn-success-custom btn-lg text-white w-100 fw-bold shadow-sm mb-3">Login</button>
            </form>

            <div class="text-center pt-2 border-top">
                <p class="text-muted small mb-2">New to Campus Green Mobility?</p>
                <a href="#" class="btn btn-outline-success btn-sm w-100 rounded-pill fw-semibold" onclick="alert('Student registration is open! Please contact campus transport admin or use a pre-registered account.')">
                    <i class="bi bi-person-plus-fill me-1"></i> Register New Account
                </a>
            </div>
        </div>
    </div>

</body>
</html>