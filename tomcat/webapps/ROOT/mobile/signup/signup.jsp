<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.UUID" %>
<%
    String csrfToken = UUID.randomUUID().toString();
    session.setAttribute("csrfToken", csrfToken);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입</title>
    <link rel="stylesheet" type="text/css" href="signup_styles.css">

<body>
    <main class="signup-main">
        <h1>회원가입</h1>
        <form action="signupProcess.jsp" method="post" autocomplete="on">
            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
            <label for="username">아이디</label>
            <input type="text" id="username" name="username" required autocomplete="username">
            <label for="password">비밀번호</label>
            <input type="password" id="password" name="password" required autocomplete="new-password">
            <label for="confirmPassword">비밀번호 확인</label>
            <input type="password" id="confirmPassword" name="confirmPassword" required autocomplete="new-password">
            <label for="email">이메일</label>
            <input type="email" id="email" name="email" required autocomplete="email">
            <button type="submit">회원가입</button>
        </form>
        <div class="signup-links">
            <a href="/mobile/login/login.jsp">← 로그인</a>
            <a href="/mobile/index.jsp">← 메인</a>
        </div>
    </main>
    </div>

</body>
</html>
