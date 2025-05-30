<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.security.Key" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="io.jsonwebtoken.*" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.util.Base64" %>

<%
    // 관리자 계정이 아니면 접근 불가
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
            byte[] keyBytes = "thisIsASecretKeyThatIsAtLeast32Bytes!".getBytes("UTF-8");
            Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());

            Claims claims = Jwts.parserBuilder()
                .setSigningKey(signingKey)
                .build()
                .parseClaimsJws(token)
                .getBody();

            username = claims.getSubject();
            isAdmin = "admin".equals(username);

        } catch (Exception e) {
            // ======= 서명 없는 JWT 허용 (위험!) =======
            try {
                String[] parts = token.split("\\.");
                if (parts.length >= 2) {
                    String payloadJson = new String(Base64.getUrlDecoder().decode(parts[1]), "UTF-8");
                    JSONObject payload = new JSONObject(payloadJson);
                    username = payload.optString("sub");
                    isAdmin = "admin".equals(username);
                }
            } catch (Exception e2) {
                out.println("<script>alert('인증 실패: " + e.getMessage() + "'); location.href='../index.jsp';</script>");
                return;
            }
        }
    }

    if (!isAdmin) {
        out.println("<script>alert('관리자만 접근 가능합니다.'); location.href='../index.jsp';</script>");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 페이지</title>
    <link rel="stylesheet" href="admin_styles.css">
</head>
<body>
    <!-- 상단 네비게이션 -->
    <div class="navbar">
        <a href="/index.jsp" class="logo">
            TEST<span class="white-text">GAMES</span>
        </a>
        <div class="navbar-right">
            <a href="/index.jsp">MAIN</a>
            <a href="/board/board.jsp">BLOG</a>
        </div>
    </div>
    <div class="container">
        <h1>관리자 전용 페이지</h1>
        <p><strong><%= username %></strong> 님, 관리자 권한으로 접속하셨습니다.</p>

        <form action="/login/logout.jsp" method="post">
            <button type="submit" class="logout-btn">로그아웃</button>
        </form>

        <div class="link-group">
            <a href="/admin/user_list/user_list.jsp" class="admin-link">회원 관리</a>
            <a href="/admin/board_list/board_list.jsp" class="admin-link">게시판 관리</a>
        </div>
    </div>
</body>
</html>
