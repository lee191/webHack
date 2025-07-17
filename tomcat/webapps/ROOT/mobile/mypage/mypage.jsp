<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.io.*, java.util.*, java.sql.*, java.security.Key" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="io.jsonwebtoken.*" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>

<%
request.setCharacterEncoding("UTF-8");

boolean isLoggedIn = false;
String username = "", email = "", introOutput = "";

String dbURL = System.getenv("DB_URL");
String dbUser = System.getenv("DB_USER");
String dbPassword = System.getenv("DB_PASSWORD");

// JWT 쿠키 추출
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

// JWT 검증
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

            username = claims.getSubject();
            isLoggedIn = true;
        } else {
            out.println("환경변수 JWT_SECRET이 설정되지 않았습니다.");
        }
    } catch (Exception e) {
        getServletContext().log("JWT 검증 실패", e);
    }
}

if (!isLoggedIn) {
    response.sendRedirect("/mobile/login/login.jsp");
    return;
}

// 사용자 이메일 조회
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
         PreparedStatement pstmt = conn.prepareStatement("SELECT email FROM users WHERE username = ?")) {
        pstmt.setString(1, username);
        try (ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                email = rs.getString("email");
            }
        }
    }
} catch (Exception e) {
    getServletContext().log("이메일 조회 오류", e);
}

// 소개글 파일 불러오기 (.jsp 실행 없이 안전하게 출력)
try {
    String path = application.getRealPath("/templates/user_" + username + ".txt");
    File f = new File(path);
    if (f.exists()) {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(f), "UTF-8"))) {
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line).append("\n");
            }
        }
        introOutput = StringEscapeUtils.escapeHtml4(sb.toString());
    } else {
        introOutput = "<em>소개글이 없습니다.</em>";
    }
} catch (Exception e) {
    getServletContext().log("소개글 파일 로딩 실패", e);
    introOutput = "<em>소개글 불러오기 중 오류 발생</em>";
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>마이페이지</title>
    <link rel="stylesheet" href="mypage_styles.css">
</head>
<body>
    <main class="mypage-main" style="max-width:480px; margin:0 auto; padding:18px 8px 120px 8px; box-sizing:border-box;">
        <div class="post-card" style="background:#333; border-radius:12px; margin-bottom:18px; padding:20px 14px 14px 14px; box-shadow:0 2px 8px rgba(0,0,0,0.12);">
            <div style="display:flex; align-items:center; gap:14px; margin-bottom:10px;">
                <div class="profile-pic" style="width:54px; height:54px; border-radius:50%; background:#222 url('/image/profile.png') center/cover no-repeat; border:2px solid #ffe082;"></div>
                <div>
                    <div style="font-size:1.15em; color:#ffe082; font-weight:bold; margin-bottom:2px; word-break:break-all;">👤 <%= StringEscapeUtils.escapeHtml4(username) %></div>
                    <div style="font-size:0.98em; color:#bbb; word-break:break-all;">✉️ <%= StringEscapeUtils.escapeHtml4(email) %></div>
                </div>
            </div>
            <div class="intro-box" style="background:#232323; border-radius:8px; padding:12px 10px; color:#fff; margin-bottom:12px;">
                <div style="color:#ffe082; font-size:1em; margin-bottom:4px;"><strong>소개글</strong></div>
                <pre style="background:none; color:#fff; font-size:1.05em; margin:0; border:none; padding:0; white-space:pre-wrap; word-break:break-all;"><%= introOutput %></pre>
            </div>
            <div style="display:flex; gap:10px; margin-top:10px;">
                <a href="/mobile/mypage/edit.jsp" class="edit-btn" style="flex:1; background:#ffe082; color:#222; border-radius:8px; padding:10px 0; text-align:center; font-weight:bold; text-decoration:none;">소개글 수정</a>
                <a href="/mobile/login/logout.jsp" class="logout-btn" style="flex:1; background:#e53935; color:#fff; border-radius:8px; padding:10px 0; text-align:center; font-weight:bold; text-decoration:none;">로그아웃</a>
            </div>
        </div>
        <footer class="mobile-footer">
            <span style="font-size:1.1em;">&copy; 2025 TESTGAMES</span><br>
            <span style="font-size:0.98em; color:#bbb;">이 웹사이트는 테스트 용도로 만들어졌습니다.</span>
        </footer>
    </main>
    <nav class="mobile-nav">
        <a href="/mobile/index.jsp">
            <svg viewBox="0 0 24 24" fill="none"><path d="M3 12L12 4l9 8" stroke="currentColor" stroke-width="2"/><path d="M5 10v10h14V10" stroke="currentColor" stroke-width="2"/></svg>
            홈
        </a>
        <a href="/mobile/board/board.jsp">
            <svg viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="14" rx="2" stroke="currentColor" stroke-width="2"/><path d="M7 10h10M7 14h6" stroke="currentColor" stroke-width="2"/></svg>
            게시판
        </a>
        <a href="/mobile/mypage/mypage.jsp" class="active">
            <svg viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="2"/><path d="M4 20c0-4 4-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="2"/></svg>
            마이페이지
        </a>
    </nav>
</body>
</html>
