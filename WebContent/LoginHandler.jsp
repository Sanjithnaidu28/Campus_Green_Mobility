<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusgreen.dao.StudentDAO" %>
<%@ page import="com.campusgreen.model.Student" %>
<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    StudentDAO studentDAO = new StudentDAO();
    Student student = studentDAO.login(email, password);

    if (student != null) {
        session.setAttribute("student", student);
        // Cookie just to demonstrate cookie usage alongside session, as required by the brief
        Cookie lastLogin = new Cookie("lastLoginEmail", email);
        lastLogin.setMaxAge(60 * 60 * 24 * 7); // 7 days
        response.addCookie(lastLogin);

        response.sendRedirect("availability.jsp");
    } else {
        response.sendRedirect("index.jsp?error=1");
    }
%>
