<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*" %>
<%
String username = request.getParameter("username");
String email = request.getParameter("email");
String code = String.format("%06d", new Random().nextInt(999999));

Calendar kstCal = Calendar.getInstance(TimeZone.getTimeZone("Asia/Seoul"));
kstCal.add(Calendar.MINUTE, 5);
Timestamp expires = new Timestamp(kstCal.getTimeInMillis());

String dbURL = System.getenv("DB_URL");
String dbUser = System.getenv("DB_USER");
String dbPass = System.getenv("DB_PASSWORD");

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass)) {
        // 기존 코드 제거
        PreparedStatement del = conn.prepareStatement("DELETE FROM password_reset_tokens WHERE username = ?");
        del.setString(1, username);
        del.executeUpdate();
        del.close();

        // 새 코드 삽입
        PreparedStatement ins = conn.prepareStatement("INSERT INTO password_reset_tokens (username, code, expires_at) VALUES (?, ?, ?)");
        ins.setString(1, username);
        ins.setString(2, code);
        ins.setTimestamp(3, expires);
        ins.executeUpdate();
        ins.close();
    }
} catch (Exception e) {
    getServletContext().log("인증코드 저장 오류", e);
    out.println("<script>alert('시스템 오류'); history.back();</script>");
    return;
}
%>

<!-- 개발용: 코드 노출 -->
<p>인증코드가 생성되었습니다.</p>
<p><strong style="color:red;">개발용 인증코드: <%= code %></strong></p>
<form action="verify_code.jsp" method="post">
    <input type="hidden" name="username" value="<%= username %>">
    <label>인증코드 입력: <input type="text" name="code" required></label><br>
    <button type="submit">다음</button>
</form>
