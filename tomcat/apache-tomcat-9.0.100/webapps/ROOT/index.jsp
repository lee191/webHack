<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.security.Key" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="io.jsonwebtoken.*" %>

<%
    boolean isLoggedIn = false;
    String username = "";

    Cookie[] cookies = request.getCookies();
    String token = null;

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
            byte[] keyBytes = "thisIsASecretKeyThatIsAtLeast32Bytes!".getBytes("UTF-8");
            Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());

            Claims claims = Jwts.parserBuilder()
                .setSigningKey(signingKey)
                .build()
                .parseClaimsJws(token)
                .getBody();

            isLoggedIn = true;
            username = claims.getSubject();

        } catch (Exception e) {
            e.printStackTrace(); // 오류 확인 로그
        }
    }
%>


<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>메인 페이지</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <h1>환영합니다<% if (isLoggedIn) { %>, <%= username %>님!<% } %></h1>

    <nav>
        <ul>
            <li><a href="board/board.jsp">게시판</a></li>
            <% if (isLoggedIn) { %>
                <li><a href="login/logout.jsp">로그아웃</a></li>
            <% } else { %>
                <li><a href="login/login.jsp">로그인</a></li>
                <li><a href="signup/signup.jsp">회원가입</a></li>
            <% } %>
        </ul>
    </nav>
</body>
</html>
