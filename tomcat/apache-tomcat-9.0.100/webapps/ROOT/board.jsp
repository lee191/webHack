<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.sql.*, java.util.*, io.jsonwebtoken.*, javax.crypto.spec.SecretKeySpec, java.security.Key" %>

<%
    String token = null;
    String username = null;
    boolean isAuthenticated = false;

    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("authToken".equals(cookie.getName())) {
                token = cookie.getValue();
            }
        }
    }

    if (token != null) {
        try {
            byte[] keyBytes = "thisIsASecretKeyThatIsAtLeast32Bytes!".getBytes("UTF-8");
            Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());

            Claims claims = Jwts.parserBuilder()
                .setSigningKey(signingKey)
                .build()
                .parseClaimsJws(token)
                .getBody();

            username = claims.getSubject();
            isAuthenticated = true;
        } catch (Exception e) {
            out.println("<script>alert('로그인 인증 오류: " + e.getMessage() + "'); location.href='index.jsp';</script>");
        }
    } else {
        out.println("<script>alert('로그인 후 이용해주세요.'); location.href='index.jsp';</script>");
    }

    String dbURL = "jdbc:mysql://localhost:3306/my_database";
    String dbUser = "test";
    String dbPass = "test";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시판</title>
    <link rel="stylesheet" href="board_styles.css">
</head>
<body>
    <h1>게시판</h1>
    <nav>
        <ul>
            <li><a href="index.jsp">메인 페이지</a></li>
            <li><a href="board.jsp">게시판</a></li>
            <li><a href="logout.jsp">로그아웃</a></li>
        </ul>
    </nav>

    <h2>글 목록</h2>
    <table border="1" style="width: 90%; background-color: #fff; color: #000;">
        <tr>
            <th style="width: 10%;">번호</th>
            <th style="width: 20%;">작성자</th>
            <th style="width: 50%;">제목</th>
            <th style="width: 20%;">작성 시간</th>
        </tr>
<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        String sql = "SELECT id, username, title, created_at FROM posts ORDER BY created_at DESC LIMIT 10";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();

        int count = 0;
        while (rs.next()) {
            int postId = rs.getInt("id");
            String writer = rs.getString("username");
            String title = rs.getString("title");
            String created = rs.getString("created_at");
%>
        <tr>
            <td><%= postId %></td>
            <td><%= writer %></td>
            <td><a href="view.jsp?id=<%= postId %>"><%= title %></a></td>
            <td><%= created %></td>
        </tr>
<%
            count++;
        }

        for (int i = count; i < 10; i++) {
%>
        <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
<%
        }

    } catch (Exception e) {
        out.println("<tr><td colspan='4'>DB 오류: " + e.getMessage() + "</td></tr>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>
    </table>

    <form action="write.jsp" method="get">
        <button type="submit">글쓰기</button>
    </form>
</body>
</html>