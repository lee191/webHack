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
    response.sendRedirect("/login/login.jsp");
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
    <link rel="stylesheet" href="/mypage/mypage_styles.css">
</head>
<body>
    <div class="profile-header">
        <div class="profile-pic"></div>
    </div>
    <div class="profile-content">
        <h2><%= StringEscapeUtils.escapeHtml4(username) %></h2>
        <p><%= StringEscapeUtils.escapeHtml4(email) %></p>

        <div class="intro-box">
            <p><strong>소개글:</strong></p>
            <pre><%= introOutput %></pre>
        </div>

        <div class="button-group">
            <a href="/mypage/edit.jsp" class="edit-btn">소개글 수정</a>
            <a href="/login/logout.jsp" class="logout-btn">로그아웃</a>
        </div>
    </div>
</body>
</html>
