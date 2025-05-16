<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>

<%!
    // MD5 해시 함수
    String md5(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] messageDigest = md.digest(input.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : messageDigest) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            return null;
        }
    }
%>

<%
    request.setCharacterEncoding("UTF-8");

    String username = request.getParameter("username");
    String email = request.getParameter("email");
    String newPassword = request.getParameter("newPassword");

    String dbURL = System.getenv("DB_URL");
    String dbUser = System.getenv("DB_USER");
    String dbPassword = System.getenv("DB_PASSWORD");

    if (username != null && email != null && newPassword != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

            // 1. 사용자 존재 확인
            String checkSql = "SELECT * FROM users WHERE username = ? AND email = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, username);
            pstmt.setString(2, email);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                // 2. 비밀번호 변경
                String hashed = md5(newPassword);  // 취약: MD5 사용
                String updateSql = "UPDATE users SET password = ? WHERE username = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setString(1, hashed);
                pstmt.setString(2, username);
                pstmt.executeUpdate();
%>
                <script>
                    alert("비밀번호가 변경되었습니다.");
                    location.href = "/login/login.jsp";
                </script>
<%
            } else {
%>
                <script>
                    alert("일치하는 사용자 정보를 찾을 수 없습니다.");
                    history.back();
                </script>
<%
            }
        } catch (Exception e) {
            out.println("오류 발생: " + e.getMessage());
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ignore) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception ignore) {}
            if (conn != null) try { conn.close(); } catch (Exception ignore) {}
        }
        return;
    }
%>

<head>
    <title>비밀번호 재설정</title>
    <link rel="stylesheet" type="text/css" href="/login/edit_pass_styles.css">
</head>
<body>
    <form method="post" action="">
        <h2>비밀번호 재설정</h2>
        <label>아이디:
            <input type="text" name="username" required>
        </label><br>
        <label>이메일:
            <input type="text" name="email" required>
        </label><br>
        <label>새 비밀번호:
            <input type="text" name="newPassword" required>
        </label><br>
        <button type="submit">비밀번호 변경</button>
    </form>
</body>
