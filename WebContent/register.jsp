<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Register - Campus Green Mobility</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="auth">
    <div class="auth-hero">
        <span class="brand">&#x1F331; campus<span>green</span></span>
        <h1>Join the<br><span class="grad">green crew.</span></h1>
        <p>Create your account, book a slot in seconds, and see how much CO2 you save compared to a private vehicle.</p>
        <div class="hero-chips">
            <span class="chip">&#x1F3C6; Leaderboard</span>
            <span class="chip">&#x1F4CA; Personal impact</span>
        </div>
    </div>

    <div class="auth-side">
        <div class="panel auth-card">
            <h2>Create account</h2>
            <p class="sub">It takes about ten seconds.</p>

            <c:if test="${not empty param.error}">
                <div class="alert alert-err">That email is already registered. Try logging in instead.</div>
            </c:if>

            <form action="RegisterHandler.jsp" method="post">
                <label for="name">Full name</label>
                <input id="name" type="text" name="name" placeholder="Your name" required>
                <label for="email">Email</label>
                <input id="email" type="email" name="email" placeholder="you@woxsen.edu.in" required>
                <label for="password">Password</label>
                <input id="password" type="password" name="password" placeholder="Choose a password" required>
                <button class="btn btn-block" type="submit">Register</button>
            </form>
            <p class="switch">Already have an account? <a href="index.jsp">Log in</a></p>
        </div>
    </div>
</div>
</body>
</html>
