<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*, java.security.*, java.util.Base64, javax.crypto.spec.PBEKeySpec, javax.crypto.SecretKeyFactory" %>

<%!
    public String hashPassword(String password, byte[] salt) throws Exception {
        int iterations = 10000;
        int keyLength = 256;
        PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, iterations, keyLength);
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        byte[] hash = factory.generateSecret(spec).getEncoded();

        return Base64.getEncoder().encodeToString(salt) + ":" + Base64.getEncoder().encodeToString(hash);
    }

    public byte[] generateSalt() {
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);
        return salt;
    }
%>

<%
request.setCharacterEncoding("UTF-8");

String username = request.getParameter("username");
String password = request.getParameter("password");
String email = request.getParameter("email");

if (username == null || password == null || email == null || username.isEmpty() || password.length() < 8) {
%>
<script>
    alert("입력값이 부족하거나 비밀번호가 너무 짧습니다.");
    location.href = "add_user.jsp";
</script>
<%
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

String dbURL = System.getenv("DB_URL");
String dbUser = System.getenv("DB_USER");
String dbPassword = System.getenv("DB_PASSWORD");

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

    // 아이디 또는 이메일 중복 확인
    String checkSql = "SELECT 1 FROM users WHERE username = ? OR email = ?";
    pstmt = conn.prepareStatement(checkSql);
    pstmt.setString(1, username);
    pstmt.setString(2, email);
    rs = pstmt.executeQuery();

    if (rs.next()) {
%>
<script>
    alert("이미 존재하는 아이디 또는 이메일입니다.");
    location.href = "add_user.jsp";
</script>
<%
    } else {
        rs.close();
        pstmt.close();

        byte[] salt = generateSalt();
        String hashedPassword = hashPassword(password, salt);

        String insertSql = "INSERT INTO users (username, password, email) VALUES (?, ?, ?)";
        pstmt = conn.prepareStatement(insertSql);
        pstmt.setString(1, username);
        pstmt.setString(2, hashedPassword);
        pstmt.setString(3, email);
        int result = pstmt.executeUpdate();

        if (result > 0) {
%>
<script>
    alert("[  OK  ] 사용자 추가 완료");
    location.href = "/admin/user_list/user_list.jsp";
</script>
<%
        } else {
%>
<script>
    alert("[ FAIL ] 사용자 등록 실패");
    location.href = "add_user.jsp";
</script>
<%
        }
    }
} catch (Exception e) {
    getServletContext().log("사용자 등록 오류", e);
%>
<script>
    alert("시스템 오류 발생. 관리자에게 문의하세요.");
    location.href = "add_user.jsp";
</script>
<%
} finally {
    try { if (rs != null) rs.close(); } catch (Exception ignore) {}
    try { if (pstmt != null) pstmt.close(); } catch (Exception ignore) {}
    try { if (conn != null) conn.close(); } catch (Exception ignore) {}
}
%>
