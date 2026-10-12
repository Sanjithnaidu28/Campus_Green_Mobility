<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ page import="com.campusgreen.model.Student" %>
<jsp:useBean id="bookingDAO" class="com.campusgreen.dao.BookingDAO" scope="page" />
<%
    Student student = (Student) session.getAttribute("student");
    if (student == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<c:set var="bookings" value="<%= bookingDAO.getBookingsForStudent(student.getStudentId()) %>" />
<c:set var="activePage" value="impact" scope="request" />
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My impact - Campus Green Mobility</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="app">
    <%@ include file="includes/sidebar.jspf" %>

    <main class="main">
        <div class="page-head">
            <div>
                <h1>My <span class="grad">impact</span></h1>
                <p>Every shared ride keeps a private vehicle off the road.</p>
            </div>
            <a class="btn" href="availability.jsp">Book another ride</a>
        </div>

        <c:if test="${param.booked == '1'}">
            <div class="alert alert-ok">Booking confirmed. Your impact totals are updated below.</div>
        </c:if>

        <div class="stats">
            <div class="stat hero">
                <small>Total CO2 saved</small>
                <b><fmt:formatNumber value="${sessionScope.student.totalCo2SavedKg}" maxFractionDigits="2" /> kg</b>
                <span>across all your bookings</span>
            </div>
            <div class="stat">
                <small>Trips booked</small>
                <b>${fn:length(bookings)}</b>
                <span>green rides so far</span>
            </div>
            <div class="stat">
                <small>Trees' yearly CO2 uptake</small>
                <b><fmt:formatNumber value="${sessionScope.student.totalCo2SavedKg / 21}" maxFractionDigits="2" /></b>
                <span>rough estimate, about 21 kg per tree per year</span>
            </div>
        </div>

        <h2 class="section">Booking history</h2>
        <c:choose>
            <c:when test="${empty bookings}">
                <div class="panel">No bookings yet. <a href="availability.jsp">Book your first ride</a> and start your tally.</div>
            </c:when>
            <c:otherwise>
                <div class="table-wrap">
                    <table>
                        <tr>
                            <th>Date</th>
                            <th>Vehicle</th>
                            <th>Route</th>
                            <th>Time</th>
                            <th>Distance</th>
                            <th>CO2 saved</th>
                        </tr>
                        <c:forEach var="b" items="${bookings}">
                            <tr>
                                <td>${b.bookedAt}</td>
                                <td>${b.vehicleType == 'Shared Bike' ? '&#x1F6B2;' : '&#x1F68C;'} ${b.vehicleType}</td>
                                <td>${b.route}</td>
                                <td>${b.slotTime}</td>
                                <td>${b.distanceKm} km</td>
                                <td class="good"><fmt:formatNumber value="${b.co2SavedKg}" maxFractionDigits="2" /> kg</td>
                            </tr>
                        </c:forEach>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </main>
</div>
</body>
</html>
