<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusgreen.model.Student" %>
<%@ page import="com.campusgreen.dao.BookingDAO" %>
<%@ page import="com.campusgreen.dao.StudentDAO" %>
<%
    Student student = (Student) session.getAttribute("student");
    if (student == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    int slotId = Integer.parseInt(request.getParameter("slotId"));
    double distanceKm = Double.parseDouble(request.getParameter("distanceKm"));

    BookingDAO bookingDAO = new BookingDAO();
    StudentDAO studentDAO = new StudentDAO();

    // Only works while this student still holds a live seat on this slot.
    // The hold, the booked seat count, the booking row and the CO2 total all change
    // together in one transaction, so a seat can never be booked twice.
    boolean booked = bookingDAO.createBookingFromHold(student.getStudentId(), slotId, distanceKm);

    if (!booked) {
        response.sendRedirect("availability.jsp?expired=1");
        return;
    }

    // Refresh the session copy of the student so the sidebar and impact numbers are current
    session.setAttribute("student", studentDAO.getById(student.getStudentId()));

    response.sendRedirect("myBookings.jsp?booked=1");
%>
