<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Log in - Campus Green Mobility</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="auth">
    <div class="auth-hero">
        <span class="brand">&#x1F331; campus<span>green</span></span>
        <h1>Ride green.<br><span class="grad">Save carbon.</span></h1>
        <p>Book EV shuttles and shared bikes around campus, and watch your CO2 savings add up with every trip.</p>
        <div class="hero-chips">
            <span class="chip">&#x1F68C; EV shuttles</span>
            <span class="chip">&#x1F6B2; Shared bikes</span>
            <span class="chip">&#x1F30D; Live CO2 tracker</span>
        </div>
    </div>

    <div class="auth-side">
        <div class="panel auth-card">
            <h2>Welcome back</h2>
            <p class="sub">Log in to book your next ride.</p>

            <c:if test="${not empty param.error}">
                <div class="alert alert-err">Invalid email or password. Try again.</div>
            </c:if>
            <c:if test="${not empty param.registered}">
                <div class="alert alert-ok">Account created. You can log in now.</div>
            </c:if>

            <form action="LoginHandler.jsp" method="post">
                <label for="email">Email</label>
                <input id="email" type="email" name="email" placeholder="you@woxsen.edu.in"
                       value="<c:out value='${cookie.lastLoginEmail.value}' />" required>
                <label for="password">Password</label>
                <input id="password" type="password" name="password" placeholder="Your password" required>
                <button class="btn btn-block" type="submit">Log in</button>
            </form>
            <p class="switch">New here? <a href="register.jsp">Create an account</a></p>
        </div>
    </div>
</div>
</body>
</html>
