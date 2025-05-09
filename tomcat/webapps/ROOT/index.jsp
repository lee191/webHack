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
    <title>TESTGAMES - 메인 페이지</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>

    <!-- 상단 네비게이션 -->
    <div class="navbar">
        <div class="logo">TEST<span class="white-text">GAMES</span></div>
        <div class="navbar-right">
            <a href="/board/board.jsp">BLOG</a>
            <a href="#">STORE</a>
            <% if (isLoggedIn) { %>
                <a href="/login/logout.jsp">LOGOUT</a>
            <% } else { %>
                <a href="/login/login.jsp">LOGIN</a>
                <a href="/signup/signup.jsp">SIGNUP</a>
            <% } %>
        </div>
    </div>

    <!-- 히어로 배너 영역 -->
    <div class="hero">
        <img src="/image/hero.jpg" alt="Hero Image" class="hero-img" />
        <div class="hero-text">
            <h2>AS WE PASSED, I REMARKED</h2>
            <p>As we passed, I remarked a beautiful church-spire...</p>
            <button>READ MORE</button>
        </div>
    </div>

    <!-- 사용자 인사말 -->
    <section class="welcome">
        <h1>환영합니다<% if (isLoggedIn) { %>, <%= username %>님!<% } %></h1>
    </section>

    <!-- 게임 플랫폼 소개 -->
    <div class="platforms">
        <div class="platform">
            <%-- PC 아이콘 이미지 삽입 --%>
            <img src="/image/pc.png" alt="PC Icon" />
            <div>PC</div>
            <a href="/board/board.jsp">VIEW GAMES</a>
        </div>
        <div class="platform">
            <%-- PS4 아이콘 이미지 삽입 --%>
            <img src="/image/ps4.png" alt="PS4 Icon" />
            <div>PS4</div>
            <a href="/board/board.jsp">VIEW GAMES</a>
        </div>
        <div class="platform">
            <%-- XBOX 아이콘 이미지 삽입 --%>
            <img src="/image/xbox.png" alt="XBOX Icon" />
            <div>XBOX</div>
            <a href="/board/board.jsp">VIEW GAMES</a>
        </div>
    </div>

    
    <div class="footer">
        <p>&copy; 2025 TESTGAMES.</p>
        <p>이 웹사이트는 테스트 용도로 만들어졌습니다.</p>
    </div>
</body>
</html>