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
    <link rel="stylesheet" href="/mobile/view/view_styles.css">
</head>
<body>

<main class="view-main">
    <div class="view-card">
        <div class="view-title"><%= title %></div>
        <div class="view-meta">
            <span class="view-writer">👤 <%= writer %></span>
            <span class="view-date">🕒 <%= created %></span>
            <span class="view-id">#<%= postId %></span>
        </div>
        <div class="view-content"><pre><%= content %></pre></div>
        <% if (filename != null && !filename.isEmpty()) { %>
        <div class="view-file">
            <span>📎 첨부파일: </span>
            <a class="download-link" href="/mobile/view/download.jsp?fileName=<%= filename %>"><%= filename %></a>
        </div>
        <% } %>
    </div>
</main>


<footer class="mobile-footer">
    <span style="font-size:1.1em;">&copy; 2025 TESTGAMES</span><br>
    <span style="font-size:0.98em; color:#bbb;">이 웹사이트는 테스트 용도로 만들어졌습니다.</span>
</footer>



</body>
</html>

