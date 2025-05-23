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

String dbURL = System.getenv("DB_URL");
String dbUser = System.getenv("DB_USER");
String dbPassword = System.getenv("DB_PASSWORD");

boolean isValidUser = false;
String username = "";

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword)) {
        String sql = "SELECT username, password FROM users WHERE username = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String dbHashed = rs.getString("password");
                    username = rs.getString("username");

                    // 입력 비밀번호 검증
                    isValidUser = verifyPassword(password, dbHashed);
                }
            }
        }
    }
} catch (Exception e) {
    getServletContext().log("Login error", e);
}

if (isValidUser) {
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
    // authCookie.setSecure(true); // HTTPS 환경에서만

    response.addCookie(authCookie);
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if ("admin".equals(username)) {
        response.sendRedirect("/admin/index.jsp");
    } else {
        response.sendRedirect("/index.jsp");
    }
} else {
%>
<script>
    alert("아이디 또는 비밀번호가 잘못되었습니다.");
    history.back();
</script>
<%
}
%>
