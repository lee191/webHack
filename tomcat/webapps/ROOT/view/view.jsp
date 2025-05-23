<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*, org.apache.commons.text.StringEscapeUtils" %>
<%
String title="", content="", writer="", filename="", created="";
int postId = 0;
try {
    postId = Integer.parseInt(request.getParameter("id"));
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection(System.getenv("DB_URL"), System.getenv("DB_USER"), System.getenv("DB_PASSWORD"))) {
        String sql = "SELECT * FROM posts WHERE id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    title = StringEscapeUtils.escapeHtml4(rs.getString("title"));
                    content = StringEscapeUtils.escapeHtml4(rs.getString("content"));
                    writer = StringEscapeUtils.escapeHtml4(rs.getString("username"));
                    filename = StringEscapeUtils.escapeHtml4(rs.getString("filename"));
                    created = StringEscapeUtils.escapeHtml4(rs.getString("created_at"));
                } else {
                    out.println("<script>alert('게시글 없음'); history.back();</script>");
                    return;
                }
            }
        }
    }
} catch (Exception e) {
    getServletContext().log("조회 오류", e);
    out.println("<script>alert('조회 오류'); history.back();</script>");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시글 보기</title>
    <link rel="stylesheet" href="/view/view_styles.css">
</head>
<body>

<h1>게시글 보기</h1>

<table>
    <tr>
        <th>제목</th>
        <td><%= title %></td>
    </tr>
    <tr>
        <th>작성자</th>
        <td><%= writer %></td>
    </tr>
    <tr>
        <th>작성 시간</th>
        <td><%= created %></td>
    </tr>
    <tr>
        <th>내용</th>
        <td><pre><%= content %></pre></td>
    </tr>
    <% if (filename != null && !filename.isEmpty()) { %>
    <tr>
        <th>첨부파일</th>
        <td>
            <a class="download-link" href="/view/download.jsp?fileName=<%= filename %>"><%= filename %></a>
        </td>
    </tr>
    <% } %>
</table>

</body>
</html>

