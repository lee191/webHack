<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.UUID" %>

<%
request.setCharacterEncoding("UTF-8");

// CSRF 토큰 생성
String csrfToken = UUID.randomUUID().toString();
session.setAttribute("csrfToken", csrfToken);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>비밀번호 재설정 요청</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="/mobile/login/edit_pass_styles.css">
</head>
<body>
    <main class="mobile-main">
        <form method="post" action="send_code.jsp" autocomplete="on">
            <h2>비밀번호 재설정 요청</h2>
            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
            <div class="input-group">
                <label for="username">아이디</label>
                <input type="text" id="username" name="username" required autocomplete="username">
            </div>
            <div class="input-group">
                <label for="email">이메일</label>
                <input type="email" id="email" name="email" required autocomplete="email">
            </div>
            <button type="submit">인증코드 요청</button>
        </form>
    </main>
    <footer class="mobile-footer">
        <span>&copy; 2025 TESTGAMES</span>
        <span>이 웹사이트는 테스트 용도로 만들어졌습니다.</span>
    </footer>
</body>
</html>
