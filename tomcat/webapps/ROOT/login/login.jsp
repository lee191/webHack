<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인</title>
    <link rel="stylesheet" type="text/css" href="login_styles.css">
</head>
<body>

    <!-- 상단 네비게이션 -->
    <div class="navbar">
        <div class="logo">TEST<span class="white-text">GAMES</span></div>
        <div class="navbar-right">
                <a href="/signup/signup.jsp">SIGNUP</a>
        </div>
    </div>


    <div class="login-container">
        <h1>LOGIN</h1>

        <form action="processLogin.jsp" method="post">
            <label for="username">ID</label>
            <input type="text" id="username" name="username" placeholder="아이디 입력" required>

            <label for="password">Password</label>
            <input type="password" id="password" name="password" placeholder="비밀번호 입력" required>

            <button type="submit">Login</button>
        </form>

        <a href="/index.jsp">← 메인 페이지로 돌아가기</a>
    </div>

</body>
</html>
