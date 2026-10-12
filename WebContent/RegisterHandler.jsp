<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.campusgreen.dao.StudentDAO" %>
<%
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    StudentDAO studentDAO = new StudentDAO();
    boolean success = studentDAO.register(name, email, password);

    if (success) {
        response.sendRedirect("index.jsp?registered=1");
    } else {
        response.sendRedirect("register.jsp?error=1");
    }
%>
