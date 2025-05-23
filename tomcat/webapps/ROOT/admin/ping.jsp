<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.io.*, java.util.regex.*, java.security.Key" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="io.jsonwebtoken.*" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>

<%
request.setCharacterEncoding("UTF-8");

String dbUser = System.getenv("DB_USER");
String dbPass = System.getenv("DB_PASSWORD");

String token = null;
String username = null;
boolean isAdmin = false;

// JWT 쿠키 추출 및 검증
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
        Key key = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());

        Claims claims = Jwts.parserBuilder()
            .setSigningKey(key)
            .build()
            .parseClaimsJws(token)
            .getBody();

        username = claims.getSubject();
        if ("admin".equals(username)) {
            isAdmin = true;
        }
    } catch (Exception e) {
        getServletContext().log("JWT 검증 오류", e);
    }
}

// 관리자만 접근 가능
if (!isAdmin) {
    response.sendError(403, "접근 권한이 없습니다.");
    return;
}
%>

<%
String target = request.getParameter("host");
Pattern hostPattern = Pattern.compile("^[a-zA-Z0-9.-]{1,253}$");

if ("POST".equalsIgnoreCase(request.getMethod()) && target != null && !target.isEmpty()) {
    if (!hostPattern.matcher(target).matches()) {
        out.println("<script>alert('허용되지 않은 형식의 호스트명입니다.'); history.back();</script>");
        return;
    }

    try {
        ProcessBuilder pb = new ProcessBuilder("mysqladmin", "-h", target, "-u", dbUser, "-p" + dbPass, "ping");
        pb.redirectErrorStream(true);
        Process proc = pb.start();

        BufferedReader reader = new BufferedReader(new InputStreamReader(proc.getInputStream()));
        StringBuilder output = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            output.append(line).append("\n");
        }
%>
        <h2>DB 상태 결과 (<%= StringEscapeUtils.escapeHtml4(target) %>):</h2>
        <pre><%= StringEscapeUtils.escapeHtml4(output.toString()) %></pre>
<%
    } catch (Exception e) {
        getServletContext().log("DB 상태 확인 실패", e);
        out.println("<script>alert('DB 상태 확인 중 오류 발생'); history.back();</script>");
    }
} else {
%>
<link rel="stylesheet" href="/admin/ping_styles.css">
<div class="container">
    <h3>DB 상태 확인 (관리자 전용)</h3>
    <form method="POST">
        <label>DB 호스트 주소:</label>
        <input type="text" name="host" placeholder="127.0.0.1" required>
        <button type="submit">DB Ping</button>
    </form>
</div>
<%
}
%>
