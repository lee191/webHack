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
    <link rel="stylesheet" href="/login/edit_pass_styles.css">
</head>
<body>
    <form method="post" action="send_code.jsp">
        <h2>비밀번호 재설정 요청</h2>

        <input type="hidden" name="csrfToken" value="<%= csrfToken %>">

        <label>아이디:
            <input type="text" name="username" required>
        </label><br>

        <label>이메일:
            <input type="email" name="email" required>
        </label><br>

        <button type="submit">인증코드 요청</button>
    </form>
</body>
</html>
