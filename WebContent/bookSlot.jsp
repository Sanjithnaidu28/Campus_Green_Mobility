<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="com.campusgreen.model.Student" %>
<%@ page import="com.campusgreen.model.Slot" %>
<%@ page import="com.campusgreen.dao.BookingDAO" %>
<%@ page import="com.campusgreen.dao.SeatHoldDAO" %>
<jsp:useBean id="slotDAO" class="com.campusgreen.dao.SlotDAO" scope="page" />
<jsp:useBean id="holdDAO" class="com.campusgreen.dao.SeatHoldDAO" scope="page" />
<%
    Student student = (Student) session.getAttribute("student");
    if (student == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    String slotParam = request.getParameter("slotId");
    if (slotParam == null) {
        response.sendRedirect("availability.jsp");
        return;
    }
    int slotId = Integer.parseInt(slotParam);

    // Hold one seat for this student for 2 minutes. If they already hold one on this
    // slot (e.g. they refreshed the page) their existing timer simply carries on.
    if (!holdDAO.createHold(student.getStudentId(), slotId)) {
        response.sendRedirect("availability.jsp?full=1");
        return;
    }

    Slot slot = slotDAO.getById(slotId);
    if (slot == null) {
        response.sendRedirect("availability.jsp");
        return;
    }
    request.setAttribute("slot", slot);
    request.setAttribute("secondsLeft", holdDAO.secondsLeft(student.getStudentId(), slotId));
%>
<c:set var="activePage" value="book" scope="request" />
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Confirm booking - Campus Green Mobility</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="app">
    <%@ include file="includes/sidebar.jspf" %>

    <main class="main">
        <a class="back" href="releaseSeat.jsp?slotId=${slot.slotId}">&#x2190; Back to slots (releases your seat)</a>
        <div class="page-head">
            <div>
                <h1>Confirm your <span class="grad">booking</span></h1>
                <p>One quick detail and your seat is yours.</p>
            </div>
        </div>

        <div class="hold" id="hold">
            <div class="hold-time" id="timer">2:00</div>
            <div class="hold-text">
                <b id="holdTitle">Seat held for you</b>
                <span id="holdSub">Confirm before the timer runs out, or the seat goes back on sale.</span>
                <div class="hold-bar"><i id="bar"></i></div>
            </div>
        </div>

        <div class="alert alert-warn" id="expiredNote" style="display:none">
            Your 2-minute hold ran out and the seat was released.
            <a href="bookSlot.jsp?slotId=${slot.slotId}">Hold a seat again</a> or
            <a href="availability.jsp">pick another slot</a>.
        </div>

        <div class="panel">
            <div class="detail">
                <div><small>Vehicle</small><b>${slot.vehicleType == 'Shared Bike' ? '&#x1F6B2;' : '&#x1F68C;'} ${slot.vehicleType}</b></div>
                <div><small>Route</small><b>${slot.route}</b></div>
                <div><small>Time</small><b>${slot.slotTime}</b></div>
                <div><small>Other seats still open</small><b>${slot.seatsLeft} of ${slot.capacity}</b></div>
            </div>

            <form action="ConfirmBookingHandler.jsp" method="post" id="bookForm">
                <input type="hidden" name="slotId" value="${slot.slotId}">
                <label for="distanceKm">Trip distance (km), used to estimate your CO2 savings</label>
                <input id="distanceKm" type="number" step="0.1" min="0.1" name="distanceKm" placeholder="4.5" required>

                <div class="estimate">&#x1F331; You'll save about <b id="est">0.00</b> kg CO2 compared with a private vehicle.</div>

                <button class="btn btn-block" type="submit" id="confirmBtn">Confirm booking</button>
            </form>
        </div>
    </main>
</div>

<script>
    var FACTOR = <%= BookingDAO.EMISSION_FACTOR_DIFF %>;
    var TOTAL = <%= SeatHoldDAO.HOLD_SECONDS %>;
    var left = ${secondsLeft};

    document.getElementById('distanceKm').addEventListener('input', function () {
        var km = parseFloat(this.value) || 0;
        document.getElementById('est').textContent = (km * FACTOR).toFixed(2);
    });

    var holdEl = document.getElementById('hold');
    var timerEl = document.getElementById('timer');
    var barEl = document.getElementById('bar');
    var btn = document.getElementById('confirmBtn');
    var iv;

    function tick() {
        if (left <= 0) {
            clearInterval(iv);
            timerEl.textContent = '0:00';
            barEl.style.width = '0%';
            holdEl.classList.remove('warn');
            holdEl.classList.add('expired');
            document.getElementById('holdTitle').textContent = 'Hold expired';
            document.getElementById('holdSub').textContent = 'Your seat has been released for other students.';
            document.getElementById('expiredNote').style.display = 'block';
            btn.disabled = true;
            btn.textContent = 'Hold expired';
            return;
        }
        var m = Math.floor(left / 60), s = left % 60;
        timerEl.textContent = m + ':' + (s < 10 ? '0' : '') + s;
        barEl.style.width = (left / TOTAL * 100) + '%';
        holdEl.classList.toggle('warn', left <= 30);
        left--;
    }
    tick();
    iv = setInterval(tick, 1000);
</script>
</body>
</html>
