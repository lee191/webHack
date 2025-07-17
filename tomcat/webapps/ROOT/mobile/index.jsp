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
            String jwtSecret = System.getenv("JWT_SECRET");
            if (jwtSecret != null) {
                byte[] keyBytes = jwtSecret.getBytes("UTF-8");
                Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());

                Claims claims = Jwts.parserBuilder()
                    .setSigningKey(signingKey)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();

                isLoggedIn = true;
                username = claims.getSubject();
            } else {
                out.println("환경변수 JWT_SECRET이 설정되지 않았습니다.");
            }
        } catch (Exception e) {
            e.printStackTrace(); // 서버 로그에서 확인
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

    <main class="mobile-main">
        <div class="mobile-welcome">
            <span style="font-size:2.1em;">👾</span><br>
            <span>어서오세요<% if (isLoggedIn) { %>, <b><%= username %></b>님!<% } %></span>
        </div>
        <div class="mobile-intro">
            <h1>TESTGAMES</h1>
            <p>모바일에서도 즐기는 게임 커뮤니티</p>
            <img src="/mobile/image/hero.jpg" alt="로고" class="mobile-logo">
        </div>
        <div style="display:flex; justify-content:center; gap:18px; margin:18px 0 30px 0;">
            <div style="background:#232323; border-radius:16px; padding:18px 12px; width:90px; text-align:center; box-shadow:0 2px 8px #0002;">
                <img src="/image/pc.png" alt="PC" style="width:38px; margin-bottom:6px;" />
                <div style="font-size:1.1em; font-weight:600; color:#e53935;">PC</div>
                <a href="/mobile/board/board.jsp" style="display:block; color:#fff; font-size:0.98em; margin-top:4px;">게임</a>
            </div>
            <div style="background:#232323; border-radius:16px; padding:18px 12px; width:90px; text-align:center; box-shadow:0 2px 8px #0002;">
                <img src="/image/ps4.png" alt="PS4" style="width:38px; margin-bottom:6px;" />
                <div style="font-size:1.1em; font-weight:600; color:#3b5be7;">PS4</div>
                <a href="/mobile/board/board.jsp" style="display:block; color:#fff; font-size:0.98em; margin-top:4px;">게임</a>
            </div>
            <div style="background:#232323; border-radius:16px; padding:18px 12px; width:90px; text-align:center; box-shadow:0 2px 8px #0002;">
                <img src="/image/xbox.png" alt="XBOX" style="width:38px; margin-bottom:6px;" />
                <div style="font-size:1.1em; font-weight:600; color:#43c43a;">XBOX</div>
                <a href="/mobile/board/board.jsp" style="display:block; color:#fff; font-size:0.98em; margin-top:4px;">게임</a>
            </div>
        </div>
        <div style="text-align:center; margin:18px 0 0 0; font-size:1.05em; color:#ffe082;">
            <span style="font-size:1.3em;">🎮</span> 오늘도 즐거운 게임 라이프!
        </div>
    </main>

    <!-- 모바일 하단 네비게이션 -->
    <nav class="mobile-nav">
        <a href="/mobile/index.jsp" class="active">
            <svg viewBox="0 0 24 24" fill="none"><path d="M3 12L12 4l9 8" stroke="currentColor" stroke-width="2"/><path d="M5 10v10h14V10" stroke="currentColor" stroke-width="2"/></svg>
            홈
        </a>
        <a href="/mobile/board/board.jsp">
            <svg viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="14" rx="2" stroke="currentColor" stroke-width="2"/><path d="M7 10h10M7 14h6" stroke="currentColor" stroke-width="2"/></svg>
            게시판
        </a>
        <a href="/mobile/mypage/mypage.jsp">
            <svg viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="2"/><path d="M4 20c0-4 4-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="2"/></svg>
            마이페이지
        </a>
        <% if (isLoggedIn) { %>
        <a href="/mobile/login/logout.jsp">
            <svg viewBox="0 0 24 24" fill="none"><path d="M16 17l5-5-5-5" stroke="currentColor" stroke-width="2"/><path d="M21 12H9" stroke="currentColor" stroke-width="2"/><path d="M12 19a7 7 0 1 1 0-14" stroke="currentColor" stroke-width="2"/></svg>
            로그아웃
        </a>
        <% } else { %>
        <a href="/mobile/login/login.jsp">
            <svg viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/><path d="M12 16v-4M12 8h.01" stroke="currentColor" stroke-width="2"/></svg>
            로그인
        </a>
        <% } %>
    </nav>

    <!-- 플로팅 액션버튼 -->
    <a href="/mobile/write/write.jsp" class="mobile-fab" title="글쓰기">
        <svg viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/><path d="M12 8v8M8 12h8" stroke="currentColor" stroke-width="2"/></svg>
    </a>

    <footer class="mobile-footer">
        <span style="font-size:1.1em;">&copy; 2025 TESTGAMES</span><br>
        <span style="font-size:0.98em; color:#bbb;">이 웹사이트는 테스트 용도로 만들어졌습니다.</span>
    </footer>
</body>
</html>