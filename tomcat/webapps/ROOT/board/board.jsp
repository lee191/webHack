<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.io.*, java.util.*, io.jsonwebtoken.*, javax.crypto.spec.SecretKeySpec, java.security.Key" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>

<%
    request.setCharacterEncoding("UTF-8");

    boolean isLoggedIn = false;
    String username = "";
    String token = null;

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
            if (jwtSecret != null) {
                byte[] keyBytes = jwtSecret.getBytes("UTF-8");
                Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());

                Claims claims = Jwts.parserBuilder()
                    .setSigningKey(signingKey)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();

                isLoggedIn = true;
                username = claims.getSubject();
            } else {
                getServletContext().log("JWT_SECRET not set.");
            }
        } catch (Exception e) {
            getServletContext().log("JWT parse error", e);
        }
    }

    String dbURL = System.getenv("DB_URL");
    String dbUser = System.getenv("DB_USER");
    String dbPassword = System.getenv("DB_PASSWORD");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String query = request.getParameter("query");
    if (query == null) query = "";
    String trimmedQuery = query.trim();
    boolean isSearch = !trimmedQuery.isEmpty();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시판</title>
    <link rel="stylesheet" href="board_styles.css">
</head>
<body>

<div class="navbar">
    <a href="/index.jsp" class="logo">TEST<span class="white-text">GAMES</span></a>
    <div class="navbar-right">
        <a href="/index.jsp">MAIN</a>
        <a href="/login/logout.jsp">LOGOUT</a>
    </div>
</div>

<h1><a href="/board/board.jsp" class="no-link-style">BLOG</a></h1>

<div class="welcome-message">
    <p>여기는 TESTGAMES의 블로그입니다.</p>
    <p>게임 관련 소식과 업데이트를 확인하세요.</p>
</div>

<div class="top-bar">
    <div class="search-container">
        <form action="board.jsp" method="get">
            <input type="text" name="query" placeholder="검색어를 입력하세요" value="<%= StringEscapeUtils.escapeHtml4(query) %>" required>
            <button type="submit">검색</button>
        </form>
    </div>

    <div class="write-button-container">
        <form action="/write/write.jsp" method="get">
            <button type="submit">글쓰기</button>
        </form>
    </div>
</div>

<% if (isSearch) { %>
    <h2>"<%= StringEscapeUtils.escapeHtml4(query) %>" 검색 결과</h2>
<% } %>

<table class="post-table">
    <thead>
        <tr>
            <th style="width: 10%;">번호</th>
            <th style="width: 20%;">작성자</th>
            <th style="width: 50%;">제목</th>
            <th style="width: 20%;">작성 시간</th>
        </tr>
    </thead>
    <tbody>
<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        String sql = isSearch
            ? "SELECT id, username, title, created_at FROM posts WHERE title LIKE ? OR content LIKE ? ORDER BY created_at DESC LIMIT 10"
            : "SELECT id, username, title, created_at FROM posts ORDER BY created_at DESC LIMIT 10";

        pstmt = conn.prepareStatement(sql);

        if (isSearch) {
            String keyword = "%" + trimmedQuery + "%";
            pstmt.setString(1, keyword);
            pstmt.setString(2, keyword);
        }

        rs = pstmt.executeQuery();
        int count = 0;
        while (rs.next()) {
            int postId = rs.getInt("id");
            String writer = StringEscapeUtils.escapeHtml4(rs.getString("username"));
            String title = StringEscapeUtils.escapeHtml4(rs.getString("title"));
            String created = StringEscapeUtils.escapeHtml4(rs.getString("created_at"));
%>
        <tr>
            <td><%= postId %></td>
            <td><%= writer %></td>
            <td><a href="/view/view.jsp?id=<%= postId %>"><%= title %></a></td>
            <td><%= created %></td>
        </tr>
<%
            count++;
        }
        if (count == 0) {
%>
        <tr><td colspan="4">검색 결과가 없습니다.</td></tr>
<%
        }

    } catch (Exception e) {
        getServletContext().log("게시글 목록 오류", e);
        out.println("<tr><td colspan='4'>데이터를 불러오는 중 오류가 발생했습니다.</td></tr>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>
    </tbody>
</table>

<div class="footer">
    <p>&copy; 2025 TESTGAMES.</p>
    <p>이 웹사이트는 테스트 용도로 만들어졌습니다.</p>
</div>

</body>
</html>
