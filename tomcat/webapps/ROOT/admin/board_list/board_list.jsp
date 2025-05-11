<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
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
            // DB 연결 정보
            String url = "jdbc:mysql://localhost:3306/my_database?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
            String dbUser = "test";
            String dbPass = "test";

            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, dbUser, dbPass);
                stmt = conn.createStatement();
                String query = "SELECT * FROM posts";
                rs = stmt.executeQuery(query);

                while (rs.next()) {
                    int id = rs.getInt("id");
                    String name = rs.getString("username");
                    String title = rs.getString("title");
                    String content = rs.getString("content");
                    String filename = rs.getString("filename");
                    String date = rs.getString("created_at");

                    // 내용 자르기
                    int maxContentLength = 30;
                    String trimmedContent = content != null && content.length() > maxContentLength
                        ? content.substring(0, maxContentLength) + "..."
                        : content;
                    // 제목 자르기
                    int maxTitleLength = 10;
                    String trimmedTitle = title != null && title.length() > maxTitleLength
                        ? title.substring(0, maxTitleLength) + "..."
                        : title;

                    // 파일명 자르기
                    int maxFilenameLength = 10;
                    String trimmedFilename = filename != null && filename.length() > maxFilenameLength
                        ? filename.substring(0, maxFilenameLength) + "..."
                        : filename;
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
                out.println("<p>Error: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
                if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
            }
        %>
    </table>

    <!-- 버튼 영역 -->
    <form action="/admin/admin.jsp" method="post" style="display:inline;">
        <button type="submit">관리자 페이지</button>
    </form>
    <form action="/admin/board_list/add.jsp" method="post" style="display:inline;">
        <button type="submit">게시물 작성</button>
    </form>
    <form action="/admin/board_list/delete.jsp" method="post" style="display:inline;">
        <button type="submit">게시물 삭제</button>
    </form>
    <form action="/admin/board_list/delete_all.jsp" method="post" style="display:inline;">
        <button type="submit">전체 삭제</button>
    </form>
</body>
</html>
