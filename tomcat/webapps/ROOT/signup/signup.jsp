<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입</title>
    <link rel="stylesheet" type="text/css" href="signup_styles.css">
</head>
<body>

    <!-- 네비게이션 (옵션) -->
    <div class="navbar">
        <a href="/index.jsp" class="logo">TEST<span class="white-text">GAMES</span></a>
        <div class="navbar-right">
            <a href="/index.jsp">MAIN</a>
            <a href="/login/login.jsp">LOGIN</a>
        </div>
    </div>

    <div class="login-container">
        <h1>회원가입</h1>

        <form action="signupProcess.jsp" method="post">
            <label for="username">아이디</label>
            <input type="text" id="username" name="username" required>

            <label for="password">비밀번호</label>
            <input type="password" id="password" name="password" required>

            <label for="confirmPassword">비밀번호 확인</label>
            <input type="password" id="confirmPassword" name="confirmPassword" required>

            <label for="email">이메일</label>
            <input type="email" id="email" name="email" required>

            <button type="submit">회원가입</button>
        </form>

        <a href="/login/login.jsp">← 로그인 페이지로 돌아가기</a>
        <a href="/index.jsp">← 메인 페이지로 돌아가기</a>
    </div>

</body>
</html>
