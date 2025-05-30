<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.sql.*, java.util.*, io.jsonwebtoken.*, javax.crypto.spec.SecretKeySpec, java.security.Key" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.util.Base64" %>

<%
    String token = null;
    String username = null;
    boolean isLoggedIn = false;

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
            byte[] keyBytes = "thisIsASecretKeyThatIsAtLeast32Bytes!".getBytes("UTF-8");
            Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());

            Claims claims = Jwts.parserBuilder()
                .setSigningKey(signingKey)
                .build()
                .parseClaimsJws(token)
                .getBody();

            isLoggedIn = true;
            username = claims.getSubject();

        } catch (Exception e) {
            // ======= 서명 없는 JWT 허용 (위험!) =======
            try {
                String[] parts = token.split("\\.");
                if (parts.length >= 2) {
                    String payloadJson = new String(Base64.getUrlDecoder().decode(parts[1]), "UTF-8");
                    JSONObject payload = new JSONObject(payloadJson);
                    username = payload.optString("sub");
                    isLoggedIn = (username != null && !username.isEmpty());
                }
            } catch (Exception e2) {
                username = null;
                isLoggedIn = false;
            }
        }
    } else {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='/index.jsp';</script>");
        return;
    }
%>
<%

    String dbURL = System.getenv("DB_URL");
    String dbUser = System.getenv("DB_USER");
    String dbPassword = System.getenv("DB_PASSWORD");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String query = request.getParameter("query");
    if (query == null || query == "") query = "";
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

    <!-- 네비게이션 -->
    <div class="navbar">
        <a href="/index.jsp" class="logo">
            TEST<span class="white-text">GAMES</span>
        </a>
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

    <!-- 검색 + 글쓰기 상단바 -->
    <div class="top-bar">
        <div class="search-container">
            <form action="board.jsp" method="get">
                <input type="text" name="query" placeholder="검색어를 입력하세요" value="<%= (query != null) ? query : "" %>" required>
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
        <h2>"<%= query %>" 검색 결과</h2>
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
                    pstmt.setString(1, "%" + trimmedQuery + "%");
                    pstmt.setString(2, "%" + trimmedQuery + "%");
                }

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
                out.println("<tr><td colspan='4'>DB 오류: " + e.getMessage() + "</td></tr>");
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception e) {}
                try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
                try { if (conn != null) conn.close(); } catch (Exception e) {}
            }
        %>
        </tbody>
    </table>

    <!-- 푸터 -->
    <div class="footer">
        <p>&copy; 2025 TESTGAMES.</p>
        <p>이 웹사이트는 테스트 용도로 만들어졌습니다.</p>
    </div>

</body>
</html>
