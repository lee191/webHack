<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.security.Key" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="io.jsonwebtoken.*" %>

<%
request.setCharacterEncoding("UTF-8");

boolean isLoggedIn = false;
String username = null;
String token = null;

// JWT 토큰 추출
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
        Key key = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());
        Claims claims = Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token).getBody();

        username = claims.getSubject();
        isLoggedIn = (username != null);
    } catch (Exception e) {
        getServletContext().log("JWT 파싱 오류", e);
        isLoggedIn = false;
    }
}

if (!isLoggedIn || !"admin".equals(username)) {
%>
<script>
    alert("관리자만 접근 가능합니다.");
    location.href = "/index.jsp";
</script>
<%
    return;
}
%>

<%
String confirm = request.getParameter("confirm");

if (confirm == null || !confirm.equals("true")) {
%>
<script>
    if (confirm("정말로 모든 게시물을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.")) {
        location.href = "<%= request.getRequestURI() %>?confirm=true";
    } else {
        alert("삭제가 취소되었습니다.");
        location.href = '/admin/board_list/board_list.jsp';
    }
</script>
<%
    return;
}
%>

<%
String dbURL = System.getenv("DB_URL");
String dbUser = System.getenv("DB_USER");
String dbPassword = System.getenv("DB_PASSWORD");

Connection conn = null;
Statement stmt = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
    stmt = conn.createStatement();

    int result = stmt.executeUpdate("DELETE FROM posts");

    if (result > 0) {
%>
<script>
    alert('전체 게시글 <%= result %>건이 삭제되었습니다.');
    location.href = '/admin/board_list/board_list.jsp';
</script>
<%
    } else {
%>
<script>
    alert('삭제할 게시글이 없습니다.');
    location.href = '/admin/board_list/board_list.jsp';
</script>
<%
    }
} catch (Exception e) {
    getServletContext().log("전체 게시글 삭제 실패", e);
%>
<script>
    alert('시스템 오류가 발생했습니다.');
    location.href = '/admin/board_list/board_list.jsp';
</script>
<%
} finally {
    try { if (stmt != null) stmt.close(); } catch (Exception ignore) {}
    try { if (conn != null) conn.close(); } catch (Exception ignore) {}
}
%>
