<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, java.util.Base64" %>
<%@ page import="javax.crypto.spec.SecretKeySpec, java.security.Key" %>
<%@ page import="javax.crypto.SecretKeyFactory, javax.crypto.spec.PBEKeySpec" %>
<%@ page import="io.jsonwebtoken.*" %>

<%!
    public boolean verifyPassword(String inputPassword, String storedHash) throws Exception {
        String[] parts = storedHash.split(":");
        if (parts.length != 2) return false;

        byte[] salt = Base64.getDecoder().decode(parts[0]);
        byte[] stored = Base64.getDecoder().decode(parts[1]);

        PBEKeySpec spec = new PBEKeySpec(inputPassword.toCharArray(), salt, 10000, stored.length * 8);
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        byte[] computed = factory.generateSecret(spec).getEncoded();

        return Arrays.equals(stored, computed);
    }
%>

<%
request.setCharacterEncoding("UTF-8");

String id = request.getParameter("username");
String password = request.getParameter("password");

// 브루트포스 방지 로직
Integer failCount = (Integer) session.getAttribute("failCount");
Long lockTime = (Long) session.getAttribute("lockTime");
long now = System.currentTimeMillis();

if (lockTime != null && now < lockTime) {
    out.println("<script>alert('로그인 시도 제한 초과. 잠시 후 다시 시도하세요.'); history.back();</script>");
    return;
}
if (failCount == null) failCount = 0;

String dbURL = System.getenv("DB_URL");
String dbUser = System.getenv("DB_USER");
String dbPassword = System.getenv("DB_PASSWORD");

boolean isValidUser = false;
String username = "";

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword)) {
        // SQL Injection 방지를 위해 PreparedStatement 사용(파라미터 바인딩)
        // 사용자 입력값을 쿼리 내에 직접 연결하지 않고 ?로 바인딩하여 SQLi 공격을 차단
        String sql = "SELECT username, password FROM users WHERE username = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, id); // 사용자 입력값(id) 파라미터로 바인딩 → SQLi 방지
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String dbHashed = rs.getString("password");
                    username = rs.getString("username");
                    isValidUser = verifyPassword(password, dbHashed);
                }
            }
        }
    }
} catch (Exception e) {
    // 로그인 과정에서 발생한 예외를 외부(사용자)에게 노출하지 않고, 서버 로그에만 기록함 → 시스템 정보 노출 및 공격 탐지 회피
    getServletContext().log("Login error", e);
}

if (isValidUser) {
    session.removeAttribute("failCount");
    session.removeAttribute("lockTime");

    byte[] keyBytes = System.getenv("JWT_SECRET").getBytes("UTF-8");
    Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());

    String jwtToken = Jwts.builder()
        .setSubject(username)
        .setIssuedAt(new java.util.Date())
        .setExpiration(new java.util.Date(System.currentTimeMillis() + 3600000))
        .signWith(signingKey, SignatureAlgorithm.HS256)
        .compact();

    Cookie authCookie = new Cookie("authToken", jwtToken);
    authCookie.setHttpOnly(true);
    authCookie.setMaxAge(3600);
    authCookie.setPath("/");
    // authCookie.setSecure(true); // HTTPS 환경에서만 적용

    response.addCookie(authCookie);
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if ("admin".equals(username)) {
        response.sendRedirect("/mobile/index.jsp");
    } else {
        response.sendRedirect("/mobile/index.jsp");
    }
} else {
    failCount++;
    session.setAttribute("failCount", failCount);
    if (failCount >= 5) {
        session.setAttribute("lockTime", now + (10 * 60 * 1000)); 
        out.println("<script>alert('로그인 5회 실패로 10분간 차단됩니다.'); history.back();</script>");
    } else {
        out.println("<script>alert('아이디 또는 비밀번호가 잘못되었습니다.'); history.back();</script>");
    }
    // out.println("<script>alert('아이디 또는 비밀번호가 잘못되었습니다.'); history.back();</script>");
}
%>
