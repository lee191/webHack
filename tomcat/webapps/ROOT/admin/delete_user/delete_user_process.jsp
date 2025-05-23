<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.security.*, javax.crypto.SecretKeyFactory, javax.crypto.spec.PBEKeySpec, java.util.Base64, javax.crypto.spec.SecretKeySpec" %>
<%@ page import="io.jsonwebtoken.*" %>

<%!
    // PBKDF2 비밀번호 검증 함수
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

String username = request.getParameter("username");         // 삭제할 대상
String password = request.getParameter("password");         // 관리자 비밀번호 입력

String dbURL = System.getenv("DB_URL");
String dbUser = System.getenv("DB_USER");
String dbPassword = System.getenv("DB_PASSWORD");

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

String token = null;
String adminUsername = null;

// ✅ JWT 토큰에서 로그인된 관리자 확인
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
        out.println("<script>alert('인증 실패. 다시 로그인하세요.'); location.href='/index.jsp';</script>");
        return;
    }
}

if (adminUsername == null || !"admin".equals(adminUsername)) {
    out.println("<script>alert('관리자만 삭제할 수 있습니다.'); location.href='/index.jsp';</script>");
    return;
}

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

    // ✅ 관리자 비밀번호 확인
    String adminCheckSQL = "SELECT password FROM users WHERE username = ?";
    pstmt = conn.prepareStatement(adminCheckSQL);
    pstmt.setString(1, adminUsername);
    rs = pstmt.executeQuery();

    boolean verified = false;
    if (rs.next()) {
        String storedHash = rs.getString("password");
        verified = verifyPassword(password, storedHash);
    }
    rs.close();
    pstmt.close();

    if (!verified) {
        out.println("<script>alert('관리자 비밀번호가 틀립니다.'); location.href='delete_user.jsp';</script>");
        return;
    }

    // ✅ 삭제 대상 사용자 존재 여부 확인
    String checkSQL = "SELECT * FROM users WHERE username = ?";
    pstmt = conn.prepareStatement(checkSQL);
    pstmt.setString(1, username);
    rs = pstmt.executeQuery();

    if (!rs.next()) {
        out.println("<script>alert('삭제할 사용자가 존재하지 않습니다.'); location.href='delete_user.jsp';</script>");
        return;
    }
    rs.close();
    pstmt.close();

    // ✅ 사용자 삭제
    String deleteSQL = "DELETE FROM users WHERE username = ?";
    pstmt = conn.prepareStatement(deleteSQL);
    pstmt.setString(1, username);
    int result = pstmt.executeUpdate();

    if (result > 0) {
        out.println("<script>alert('사용자 삭제 성공'); location.href='/admin/user_list/user_list.jsp';</script>");
    } else {
        out.println("<script>alert('삭제 실패. 다시 시도하세요.'); location.href='delete_user.jsp';</script>");
    }

} catch (Exception e) {
    getServletContext().log("사용자 삭제 처리 중 오류", e);
    out.println("<script>alert('시스템 오류 발생'); location.href='delete_user.jsp';</script>");
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
}
%>
