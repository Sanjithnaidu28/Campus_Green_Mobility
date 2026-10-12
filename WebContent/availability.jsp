<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="com.campusgreen.model.Student" %>
<jsp:useBean id="slotDAO" class="com.campusgreen.dao.SlotDAO" scope="page" />
<%
    Student student = (Student) session.getAttribute("student");
    if (student == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<jsp:useBean id="holdDAO" class="com.campusgreen.dao.SeatHoldDAO" scope="page" />
<c:set var="slots" value="<%= slotDAO.getAllSlots() %>" />
<c:set var="myHold" value="<%= holdDAO.getActiveHoldSlotId(student.getStudentId()) %>" />
<c:set var="activePage" value="book" scope="request" />
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Book a ride - Campus Green Mobility</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="app">
    <%@ include file="includes/sidebar.jspf" %>

    <main class="main">
        <div class="page-head">
            <div>
                <h1>Ride green. <span class="grad">Save carbon.</span></h1>
                <p>Live seats, updated every time someone books.</p>
            </div>
            <span class="chip">&#x1F331; <fmt:formatNumber value="${sessionScope.student.totalCo2SavedKg}" maxFractionDigits="2" /> kg saved</span>
        </div>

        <c:if test="${param.full == '1'}">
            <div class="alert alert-err">No seats are free on that slot right now. Pick another one, or check back in a moment.</div>
        </c:if>
        <c:if test="${param.expired == '1'}">
            <div class="alert alert-warn">Your 2-minute hold ran out before you confirmed, so the seat was released. Pick a slot to try again.</div>
        </c:if>

        <div class="filters">
            <button type="button" class="filter active" data-filter="all">All</button>
            <button type="button" class="filter" data-filter="shuttle">Shuttles</button>
            <button type="button" class="filter" data-filter="bike">Bikes</button>
            <button type="button" class="filter" data-filter="open">Open only</button>
        </div>

        <div class="slots">
            <c:forEach var="slot" items="${slots}">
                <fmt:formatNumber value="${slot.seatsLeft * 10 / slot.capacity}" maxFractionDigits="0" var="litRaw" />
                <c:set var="lit" value="${slot.full ? 0 : (litRaw < 1 ? 1 : litRaw)}" />

                <div class="slot-row ${slot.full && slot.slotId != myHold ? 'is-full' : ''}"
                     data-type="${slot.vehicleType == 'Shared Bike' ? 'bike' : 'shuttle'}"
                     data-open="${!slot.full}">
                    <div class="slot-icon">${slot.vehicleType == 'Shared Bike' ? '&#x1F6B2;' : '&#x1F68C;'}</div>

                    <div class="slot-info">
                        <h3>${slot.vehicleType}</h3>
                        <p>${slot.route} &#xB7; ${slot.slotTime}</p>
                    </div>

                    <div class="seat-wrap">
                        <div class="dots">
                            <c:forEach begin="1" end="10" var="i">
                                <i class="dot ${slot.full ? (slot.heldCount > 0 ? 'held' : 'full') : (i <= lit ? 'on' : '')}"></i>
                            </c:forEach>
                        </div>
                        <span class="seats">${slot.seatsLeft} of ${slot.capacity} left<c:if test="${slot.heldCount > 0}"> &#xB7; ${slot.heldCount} on hold</c:if></span>
                    </div>

                    <c:choose>
                        <c:when test="${slot.slotId == myHold}">
                            <a class="btn" href="bookSlot.jsp?slotId=${slot.slotId}">Resume</a>
                        </c:when>
                        <c:when test="${slot.full}">
                            <span class="btn btn-ghost">${slot.heldCount > 0 ? 'On hold' : 'Full'}</span>
                        </c:when>
                        <c:otherwise>
                            <a class="btn" href="bookSlot.jsp?slotId=${slot.slotId}">Book</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:forEach>
        </div>
        <p class="empty-note" id="empty">No slots match that filter.</p>
    </main>
</div>

<script>
(function () {
    var chips = document.querySelectorAll('.filter');
    var rows = document.querySelectorAll('.slot-row');
    var empty = document.getElementById('empty');
    chips.forEach(function (chip) {
        chip.addEventListener('click', function () {
            chips.forEach(function (c) { c.classList.remove('active'); });
            chip.classList.add('active');
            var f = chip.dataset.filter, shown = 0;
            rows.forEach(function (r) {
                var ok = f === 'all' || (f === 'open' && r.dataset.open === 'true') || r.dataset.type === f;
                r.style.display = ok ? '' : 'none';
                if (ok) shown++;
            });
            empty.style.display = shown ? 'none' : 'block';
        });
    });
})();

// Keep the page live: reload every 15 seconds so seats released by expired holds
// reappear, and remember which filter chip was selected across reloads.
(function () {
    try {
        var saved = sessionStorage.getItem('slotFilter');
        if (saved) {
            var chip = document.querySelector('.filter[data-filter="' + saved + '"]');
            if (chip) chip.click();
        }
    } catch (e) {}
    document.querySelectorAll('.filter').forEach(function (c) {
        c.addEventListener('click', function () {
            try { sessionStorage.setItem('slotFilter', c.dataset.filter); } catch (e) {}
        });
    });
    setTimeout(function () { location.reload(); }, 15000);
})();
</script>
</body>
</html>
