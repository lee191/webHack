<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, io.jsonwebtoken.*, javax.crypto.spec.SecretKeySpec, java.security.Key" %>

<%!
    // HTML 이스케이프 함수 (XSS 방지용)
    public String escapeHtml(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#x27;");
    }
%>

<%
    // JWT 인증 및 관리자 여부 확인
    boolean isAdmin = false;
    String token = null;
    String username = "";

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
            Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());

            Claims claims = Jwts.parserBuilder()
                .setSigningKey(signingKey)
                .build()
                .parseClaimsJws(token)
                .getBody();

            username = claims.getSubject();
            isAdmin = "admin".equals(username);
        } catch (Exception e) {
            getServletContext().log("JWT 인증 실패", e);
        }
    }

    if (!isAdmin) {
%>
    <script>
        alert("관리자만 접근 가능합니다.");
        location.href = "/index.jsp";
    </script>
<%
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>사용자 목록</title>
    <link rel="stylesheet" href="user_list_styles.css">
</head>
<body>
    <h1>사용자 목록</h1>
    <table border="1">
        <tr>
            <th>Name</th>
            <th>Email</th>
        </tr>
<%
    String dbURL = System.getenv("DB_URL");
    String dbUser = System.getenv("DB_USER");
    String dbPassword = System.getenv("DB_PASSWORD");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        pstmt = conn.prepareStatement("SELECT username, email FROM users");
        rs = pstmt.executeQuery();

        while (rs.next()) {
            String name = escapeHtml(rs.getString("username"));
            String email = escapeHtml(rs.getString("email"));
%>
        <tr>
            <td><%= name %></td>
            <td><%= email %></td>
        </tr>
<%
        }
    } catch (Exception e) {
        getServletContext().log("DB 오류 - 사용자 목록", e);
%>
        <tr><td colspan="2">사용자 정보를 불러오는 중 오류가 발생했습니다.</td></tr>
<%
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>
    </table>

    <form action="/admin/index.jsp" method="get" style="display:inline;">
        <button type="submit">관리자 페이지</button>
    </form>
    <form action="/admin/add_user/add_user.jsp" method="get" style="display:inline;">
        <button type="submit">사용자 추가</button>
    </form>
    <form action="/admin/delete_user/delete_user.jsp" method="get" style="display:inline;">
        <button type="submit">사용자 삭제</button>
    </form>
</body>
</html>
