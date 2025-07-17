<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.security.*, java.util.Base64" %>
<%@ page import="javax.crypto.SecretKeyFactory, javax.crypto.spec.PBEKeySpec" %>

<%!
    public byte[] generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[16];
        random.nextBytes(salt);
        return salt;
    }

    public String hashPassword(String password, byte[] salt) throws Exception {
        int iterations = 10000;
        int keyLength = 256;
        PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, iterations, keyLength);
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        byte[] hash = factory.generateSecret(spec).getEncoded();
        return Base64.getEncoder().encodeToString(salt) + ":" + Base64.getEncoder().encodeToString(hash);
    }
%>

<%
String username = (String) session.getAttribute("resetUser");
if (username == null) {
    response.sendRedirect("/login/login.jsp");
    return;
}

String newPassword = request.getParameter("newPassword");
if ("POST".equalsIgnoreCase(request.getMethod())) {
    if (newPassword == null || newPassword.length() < 8) {
        out.println("<script>alert('비밀번호는 8자 이상이어야 합니다.'); history.back();</script>");
        return;
    }

    String dbURL = System.getenv("DB_URL");
    String dbUser = System.getenv("DB_USER");
    String dbPass = System.getenv("DB_PASSWORD");

    try {
        byte[] salt = generateSalt();
        String hashedPassword = hashPassword(newPassword, salt);

        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass)) {
            PreparedStatement stmt = conn.prepareStatement("UPDATE users SET password = ? WHERE username = ?");
            stmt.setString(1, hashedPassword);
            stmt.setString(2, username);
            stmt.executeUpdate();
            stmt.close();

            // 토큰 삭제
            PreparedStatement del = conn.prepareStatement("DELETE FROM password_reset_tokens WHERE username = ?");
            del.setString(1, username);
            del.executeUpdate();
        }

        session.removeAttribute("resetUser");
%>
<script>
    alert("비밀번호 변경 완료");
    location.href = "/login/login.jsp";
</script>
<%
    } catch (Exception e) {
        getServletContext().log("비밀번호 재설정 오류", e);
        out.println("<script>alert('오류 발생'); history.back();</script>");
    }
    return;
}
%>

<form method="post">
    <h2>새 비밀번호 입력</h2>
    <label>새 비밀번호: <input type="password" name="newPassword" required></label><br>
    <button type="submit">변경</button>
</form>
