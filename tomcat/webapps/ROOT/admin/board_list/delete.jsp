<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.security.Key" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="io.jsonwebtoken.*" %>

<%
request.setCharacterEncoding("UTF-8");

String token = null;
String username = null;
boolean isAdmin = false;

// JWT 토큰 추출
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
        Key key = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());
        Claims claims = Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token).getBody();
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
    <title>게시물 삭제</title>
    <link rel="stylesheet" type="text/css" href="delete.css">
</head>
<body>
    <h1>게시물 삭제</h1>
    <form action="delete_process.jsp" method="post">
        <label for="id">삭제할 게시물 ID:</label><br>
        <input type="number" id="id" name="id" required><br><br>

        <label for="password">관리자 비밀번호:</label><br>
        <input type="password" id="password" name="password" required><br><br>

        <button type="submit">게시물 삭제</button>
    </form>

    <p><a href="/admin/board_list/board_list.jsp">← 게시판 관리 페이지로 돌아가기</a></p>
</body>
</html>
