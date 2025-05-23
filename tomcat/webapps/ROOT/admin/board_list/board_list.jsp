<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.security.Key, javax.crypto.spec.SecretKeySpec" %>
<%@ page import="io.jsonwebtoken.*" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>

<%
String token = null;
String username = null;
boolean isAdmin = false;

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
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시판 관리</title>
    <link rel="stylesheet" href="board_list_styles.css">
</head>
<body>
    <h1>게시판 관리</h1>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>작성자</th>
            <th>제목</th>
            <th>내용</th>
            <th>파일명</th>
            <th>작성일</th>
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
        pstmt = conn.prepareStatement("SELECT * FROM posts ORDER BY created_at DESC");
        rs = pstmt.executeQuery();

        while (rs.next()) {
            int id = rs.getInt("id");
            String name = StringEscapeUtils.escapeHtml4(rs.getString("username"));
            String title = StringEscapeUtils.escapeHtml4(rs.getString("title"));
            String content = StringEscapeUtils.escapeHtml4(rs.getString("content"));
            String filename = StringEscapeUtils.escapeHtml4(rs.getString("filename"));
            String date = StringEscapeUtils.escapeHtml4(rs.getString("created_at"));

            String trimmedContent = content != null && content.length() > 30 ? content.substring(0, 30) + "..." : content;
            String trimmedTitle = title != null && title.length() > 10 ? title.substring(0, 10) + "..." : title;
            String trimmedFilename = filename != null && filename.length() > 10 ? filename.substring(0, 10) + "..." : filename;
%>
        <tr>
            <td><%= id %></td>
            <td><%= name %></td>
            <td><%= trimmedTitle %></td>
            <td><%= trimmedContent %></td>
            <td><%= trimmedFilename %></td>
            <td><%= date %></td>
        </tr>
<%
        }
    } catch (Exception e) {
        getServletContext().log("게시판 목록 로딩 오류", e);
%>
<script>alert("게시글 조회 중 오류가 발생했습니다."); location.href='/admin/index.jsp';</script>
<%
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException ignore) {}
        try { if (pstmt != null) pstmt.close(); } catch (SQLException ignore) {}
        try { if (conn != null) conn.close(); } catch (SQLException ignore) {}
    }
%>
    </table>

    <!-- 버튼 영역 -->
    <form action="/admin/index.jsp" method="post" style="display:inline;">
        <button type="submit">관리자 페이지</button>
    </form>
    <form action="/admin/board_list/delete.jsp" method="post" style="display:inline;">
        <button type="submit">게시물 삭제</button>
    </form>
    <form action="/admin/board_list/delete_all.jsp" method="post" style="display:inline;">
        <button type="submit">전체 삭제</button>
    </form>
</body>
</html>
