<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입</title>
    <link rel="stylesheet" type="text/css" href="signup_styles.css">
</head>
<body>
    <h1>회원가입</h1>
    <form action="signupProcess.jsp" method="post">
        <label for="username">아이디:</label>
        <input type="text" id="username" name="username" required><br>

        <label for="password">비밀번호:</label>
        <input type="password" id="password" name="password" required><br>

        <label for="password">비밀번호 확인:</label>
        <input type="password" id="password" name="password" required><br>

        <label for="email">이메일:</label>
        <input type="email" id="email" name="email" required><br>

        <button type="submit">회원가입</button>
    </form>
    <a href="/login/login.jsp">로그인 페이지로 돌아가기</a>
    <a href="/index.jsp">메인 페이지로 돌아가기</a>
</body>
</html>