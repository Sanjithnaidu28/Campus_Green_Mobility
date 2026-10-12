<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="com.campusgreen.model.Student" %>
<jsp:useBean id="studentDAO" class="com.campusgreen.dao.StudentDAO" scope="page" />
<%
    Student student = (Student) session.getAttribute("student");
    if (student == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<c:set var="top" value="<%= studentDAO.getTopStudents(10) %>" />
<c:set var="activePage" value="leaderboard" scope="request" />
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Leaderboard - Campus Green Mobility</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="app">
    <%@ include file="includes/sidebar.jspf" %>

    <main class="main">
        <div class="page-head">
            <div>
                <h1>Green <span class="grad">leaderboard</span></h1>
                <p>Top 10 students ranked by total CO2 saved.</p>
            </div>
            <span class="chip">&#x1F331; You: <fmt:formatNumber value="${sessionScope.student.totalCo2SavedKg}" maxFractionDigits="2" /> kg</span>
        </div>

        <c:choose>
            <c:when test="${empty top}">
                <div class="panel">Nobody is on the board yet. <a href="availability.jsp">Book a ride</a> to take the top spot.</div>
            </c:when>
            <c:otherwise>
                <c:forEach var="s" items="${top}" varStatus="st">
                    <div class="lb-row ${s.studentId == sessionScope.student.studentId ? 'me' : ''}">
                        <span class="rank">
                            <c:choose>
                                <c:when test="${st.count == 1}">&#x1F947;</c:when>
                                <c:when test="${st.count == 2}">&#x1F948;</c:when>
                                <c:when test="${st.count == 3}">&#x1F949;</c:when>
                                <c:otherwise>${st.count}</c:otherwise>
                            </c:choose>
                        </span>
                        <span class="lb-name">
                            <c:out value="${s.name}" />
                            <c:if test="${s.studentId == sessionScope.student.studentId}"> (you)</c:if>
                        </span>
                        <span class="lb-score"><fmt:formatNumber value="${s.totalCo2SavedKg}" maxFractionDigits="2" /> kg</span>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </main>
</div>
</body>
</html>
