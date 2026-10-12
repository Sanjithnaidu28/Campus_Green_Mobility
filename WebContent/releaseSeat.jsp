<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusgreen.model.Student" %>
<%@ page import="com.campusgreen.dao.SeatHoldDAO" %>
<%
    // Student left the booking page on purpose: give the held seat back straight away
    Student student = (Student) session.getAttribute("student");
    String slotParam = request.getParameter("slotId");
    if (student != null && slotParam != null) {
        new SeatHoldDAO().release(student.getStudentId(), Integer.parseInt(slotParam));
    }
    response.sendRedirect("availability.jsp");
%>
