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


<main class="board-main">
    <h1>BLOG</h1>
    <div style="text-align:center; color:#ffe082; font-size:1.08em; margin-bottom:10px;">
        게임 소식과 업데이트를 확인하세요!
    </div>
    <form class="search-bar" action="board.jsp" method="get">
        <input type="text" name="query" placeholder="검색어를 입력하세요" value="<%= StringEscapeUtils.escapeHtml4(query) %>" required>
        <button type="submit">🔍</button>
    </form>
    <a href="/mobile/write/write.jsp" class="write-btn">✏️ 글쓰기</a>

    <% if (isSearch) { %>
        <div style="text-align:center; color:#ffe082; font-size:1.05em; margin-bottom:8px;">
            "<%= StringEscapeUtils.escapeHtml4(query) %>" 검색 결과
        </div>
    <% } %>

    <div class="post-list">
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
        <div class="post-card">
            <a href="/mobile/view/view.jsp?id=<%= postId %>" class="post-title"><%= title %></a>
            <div class="post-meta">
                <span>👤 <%= writer %></span>
                <span>🕒 <%= created %></span>
                <span style="margin-left:auto; color:#ffe082; font-size:0.98em;">#<%= postId %></span>
            </div>
        </div>
    <%
                count++;
            }
            if (count == 0) {
    %>
        <div style="text-align:center; color:#bbb; margin:18px 0;">검색 결과가 없습니다.</div>
    <%
            }
        } catch (Exception e) {
            getServletContext().log("게시글 목록 오류", e);
            out.println("<div style='color:#e53935; text-align:center; margin:18px 0;'>데이터를 불러오는 중 오류가 발생했습니다.</div>");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    %>
    </div>

<footer class="mobile-footer">
    <span style="font-size:1.1em;">&copy; 2025 TESTGAMES</span><br>
    <span style="font-size:0.98em; color:#bbb;">이 웹사이트는 테스트 용도로 만들어졌습니다.</span>
</footer>

<!-- 모바일 하단 네비게이션 -->
<nav class="mobile-nav">
    <a href="/mobile/index.jsp">
        <svg viewBox="0 0 24 24" fill="none"><path d="M3 12L12 4l9 8" stroke="currentColor" stroke-width="2"/><path d="M5 10v10h14V10" stroke="currentColor" stroke-width="2"/></svg>
        홈
    </a>
    <a href="/mobile/board/board.jsp">
        <svg viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="14" rx="2" stroke="currentColor" stroke-width="2"/><path d="M7 10h10M7 14h6" stroke="currentColor" stroke-width="2"/></svg>
        게시판
    </a>
    <a href="/mobile/mypage/mypage.jsp">
        <svg viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="2"/><path d="M4 20c0-4 4-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="2"/></svg>
        마이페이지
    </a>
</nav>

</body>
</html>
