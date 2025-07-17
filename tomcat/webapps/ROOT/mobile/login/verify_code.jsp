<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.sql.Timestamp" %>
<%
String username = request.getParameter("username");
String code = request.getParameter("code");

String dbURL = System.getenv("DB_URL");
String dbUser = System.getenv("DB_USER");
String dbPass = System.getenv("DB_PASSWORD");

boolean valid = false;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass)) {
        PreparedStatement stmt = conn.prepareStatement("SELECT * FROM password_reset_tokens WHERE username = ? AND code = ? AND expires_at > NOW()");
        stmt.setString(1, username);
        stmt.setString(2, code);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            valid = true;
        }
        rs.close();
        stmt.close();
    }
} catch (Exception e) {
    getServletContext().log("코드 검증 오류", e);
    out.println("<script>alert('시스템 오류'); history.back();</script>");
    return;
}

if (valid) {
    session.setAttribute("resetUser", username);
%>
<script>location.href='reset_password.jsp';</script>
<%
} else {
%>
<script>alert('인증코드가 잘못되었거나 만료되었습니다.'); history.back();</script>
<%
}
%>
