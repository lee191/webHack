<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <h1>회원가입</h1>
    <nav>
        <ul>
            <li><a href="index.jsp">메인 페이지</a></li>
            <li><a href="board.jsp">게시판</a></li>
            <li><a href="login.jsp">로그인</a></li>
        </ul>
    </nav>
    <form action="signupProcess.jsp" method="post">
        <label for="username">아이디:</label>
        <input type="text" id="username" name="username" required><br>

        <label for="password">비밀번호:</label>
        <input type="password" id="password" name="password" required><br>

        <label for="email">이메일:</label>
        <input type="email" id="email" name="email" required><br>

        <button type="submit">회원가입</button>
    </form>
</body>
</html>