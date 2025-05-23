<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.security.Key" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="io.jsonwebtoken.*" %>

<%
request.setCharacterEncoding("UTF-8");

String token = null;
String username = null;
boolean isAdmin = false;

// JWT 인증 확인
Cookie[] cookies = request.getCookies();
if (cookies != null) {
    for (Cookie cookie : cookies) {
        if ("authToken".equals(cookie.getName())) {
            token = cookie.getValue();
            break;
        }
    }
}

if (token != null) {
    try {
        byte[] keyBytes = System.getenv("JWT_SECRET").getBytes("UTF-8");
        Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());

        Claims claims = Jwts.parserBuilder()
            .setSigningKey(signingKey)
            .build()
            .parseClaimsJws(token)
            .getBody();

        username = claims.getSubject();
        isAdmin = "admin".equals(username);
    } catch (Exception e) {
        getServletContext().log("JWT 인증 실패", e);
    }
}

if (!isAdmin) {
%>
<script>
    alert("관리자만 접근 가능한 페이지입니다.");
    location.href = "/index.jsp";
</script>
<%
    return;
}
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>사용자 추가</title>
    <link rel="stylesheet" type="text/css" href="add_user_styles.css">
</head>
<body>
    <h1>사용자 추가</h1>
    <form action="add_user_process.jsp" method="post">
        <label for="username">아이디:</label><br>
        <input type="text" id="username" name="username" required><br><br>

        <label for="password">비밀번호:</label><br>
        <input type="password" id="password" name="password" required><br><br>

        <label for="email">이메일:</label><br>
        <input type="email" id="email" name="email" required><br><br>

        <!-- 향후 CSRF 토큰 삽입 가능 -->
        <!-- <input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken") %>"> -->

        <button type="submit">사용자 등록</button>
    </form>

    <p><a href="/admin/user_list/user_list.jsp">← 사용자 목록 페이지</a></p>
</body>
</html>
