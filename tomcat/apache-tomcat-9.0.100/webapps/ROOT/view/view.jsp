<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String dbURL = "jdbc:mysql://localhost:3306/my_database?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
    String dbUser = "test";
    String dbPass = "test";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String title = "", content = "", writer = "", filename = "", created = "";
    int postId = 0;

    try {
        postId = Integer.parseInt(request.getParameter("id"));

        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        String sql = "SELECT * FROM posts WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            title = rs.getString("title");
            content = rs.getString("content");
            writer = rs.getString("username");
            filename = rs.getString("filename");
            created = rs.getString("created_at");
        } else {
%>
            <script>alert("존재하지 않는 게시글입니다."); history.back();</script>
<%
            return;
        }
    } catch (Exception e) {
%>
        <script>alert("오류 발생: <%= e.getMessage() %>"); history.back();</script>
<%
        return;
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시글 상세보기</title>
    <link rel="stylesheet" href="view_styles.css">
</head>
<body>
    <h1>게시글 상세보기</h1>
    <table border="1" style="width: 80%; background-color: #fff; color: #000;">
        <tr><th style="width: 20%;">제목</th><td><%= title %></td></tr>
        <tr><th>작성자</th><td><%= writer %></td></tr>
        <tr><th>작성 시간</th><td><%= created %></td></tr>
        <tr><th>내용</th><td><pre style="white-space: pre-wrap;"><%= content %></pre></td></tr>
        <%
            if (filename != null && !filename.trim().equals("")) {
        %>
        <tr><th>첨부파일</th>
            <td>
                <a href="download.jsp?action=download&fileName=<%= filename %>"><%= filename %></a>
            </td>
        </tr>
        <% } %>
    </table>
    <br>
    <a href="../board/board.jsp" class="nav-link">← 목록으로</a>
</body>
</html>
