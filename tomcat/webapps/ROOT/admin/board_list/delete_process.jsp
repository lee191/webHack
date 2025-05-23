<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.security.*, javax.crypto.spec.PBEKeySpec, javax.crypto.SecretKeyFactory, java.util.Base64, javax.crypto.spec.SecretKeySpec" %>
<%@ page import="io.jsonwebtoken.*" %>

<%!
    // PBKDF2 해시 검증
    public boolean verifyPassword(String inputPassword, String storedHash) throws Exception {
        String[] parts = storedHash.split(":");
        if (parts.length != 2) return false;

        byte[] salt = Base64.getDecoder().decode(parts[0]);
        byte[] hash = Base64.getDecoder().decode(parts[1]);

        PBEKeySpec spec = new PBEKeySpec(inputPassword.toCharArray(), salt, 10000, hash.length * 8);
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        byte[] testHash = factory.generateSecret(spec).getEncoded();

        return Arrays.equals(hash, testHash);
    }
%>

<%
request.setCharacterEncoding("UTF-8");

String postId = request.getParameter("id");
String password = request.getParameter("password");

String dbURL = System.getenv("DB_URL");
String dbUser = System.getenv("DB_USER");
String dbPassword = System.getenv("DB_PASSWORD");

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

String adminUsername = null;

// JWT 관리자 인증
String token = null;
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
        byte[] keyBytes = System.getenv("JWT_SECRET").getBytes("UTF-8");
        Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());
        Claims claims = Jwts.parserBuilder().setSigningKey(signingKey).build().parseClaimsJws(token).getBody();
        adminUsername = claims.getSubject();
    } catch (Exception e) {
        getServletContext().log("JWT 인증 실패", e);
%>
<script>
    alert("인증 실패. 다시 로그인해주세요.");
    location.href = "/index.jsp";
</script>
<%
        return;
    }
}

if (!"admin".equals(adminUsername)) {
%>
<script>
    alert("관리자 권한이 필요합니다.");
    location.href = "/index.jsp";
</script>
<%
    return;
}

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

    // 관리자 비밀번호 확인
    String pwSql = "SELECT password FROM users WHERE username = ?";
    pstmt = conn.prepareStatement(pwSql);
    pstmt.setString(1, adminUsername);
    rs = pstmt.executeQuery();

    boolean validPassword = false;
    if (rs.next()) {
        String storedHash = rs.getString("password");
        validPassword = verifyPassword(password, storedHash);
    }
    rs.close();
    pstmt.close();

    if (!validPassword) {
%>
<script>
    alert("비밀번호가 틀렸습니다.");
    location.href = "/admin/board_list/delete.jsp";
</script>
<%
        return;
    }

    // 게시물 존재 확인
    String checkSql = "SELECT * FROM posts WHERE id = ?";
    pstmt = conn.prepareStatement(checkSql);
    pstmt.setInt(1, Integer.parseInt(postId));
    rs = pstmt.executeQuery();

    if (!rs.next()) {
%>
<script>
    alert("해당 게시물이 존재하지 않습니다.");
    location.href = "/admin/board_list/delete.jsp";
</script>
<%
        return;
    }
    rs.close();
    pstmt.close();

    // 게시물 삭제
    String deleteSql = "DELETE FROM posts WHERE id = ?";
    pstmt = conn.prepareStatement(deleteSql);
    pstmt.setInt(1, Integer.parseInt(postId));
    int result = pstmt.executeUpdate();

    if (result > 0) {
%>
<script>
    alert("게시물이 삭제되었습니다.");
    location.href = "/admin/board_list/board_list.jsp";
</script>
<%
    } else {
%>
<script>
    alert("삭제 실패. 다시 시도해주세요.");
    location.href = "/admin/board_list/delete.jsp";
</script>
<%
    }

} catch (Exception e) {
    getServletContext().log("게시물 삭제 오류", e);
%>
<script>
    alert("시스템 오류가 발생했습니다.");
    location.href = "/admin/board_list/delete.jsp";
</script>
<%
} finally {
    try { if (rs != null) rs.close(); } catch (Exception ignore) {}
    try { if (pstmt != null) pstmt.close(); } catch (Exception ignore) {}
    try { if (conn != null) conn.close(); } catch (Exception ignore) {}
}
%>
