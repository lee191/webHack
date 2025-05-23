<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.crypto.spec.SecretKeySpec, java.security.Key, io.jsonwebtoken.*" %>

<%
    boolean isAdmin = false;
    String token = null;
    String username = "";

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
            String jwtSecret = System.getenv("JWT_SECRET");
            byte[] keyBytes = jwtSecret.getBytes("UTF-8");
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
        alert("관리자만 접근 가능합니다.");
        location.href = "/index.jsp";
    </script>
<%
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>사용자 삭제</title>
    <link rel="stylesheet" type="text/css" href="delete_user_styles.css">
</head>
<body>
    <h1>사용자 삭제</h1>
    <form action="delete_user_process.jsp" method="post">
        <label for="username">삭제할 사용자:</label>
        <input type="text" id="username" name="username" required><br>

        <label for="password">관리자 비밀번호:</label>
        <input type="password" id="password" name="password" required><br>

        <!-- TODO: CSRF 토큰 hidden input 추가 가능 -->
        <button type="submit">사용자 삭제</button>
    </form>
    <a href="/admin/index.jsp">← 관리자 페이지로 돌아가기</a>
</body>
</html>
