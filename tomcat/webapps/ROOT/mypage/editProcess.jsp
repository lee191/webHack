<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.security.Key" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="io.jsonwebtoken.*" %>

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
            byte[] keyBytes = "thisIsASecretKeyThatIsAtLeast32Bytes!".getBytes("UTF-8");
            Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());
            Claims claims = Jwts.parserBuilder()
                .setSigningKey(signingKey)
                .build()
                .parseClaimsJws(token)
                .getBody();
            username = claims.getSubject();
            isLoggedIn = true;
        } catch (Exception e) {
            isLoggedIn = false;
            e.printStackTrace(); // 디버깅: 콘솔에서 JWT 파싱 예외 확인
        }
    }

    if (!isLoggedIn) {
        response.sendRedirect("/login/login.jsp");
        return;
    }

    String intro = request.getParameter("intro");
    String dbURL = System.getenv("DB_URL");
    String dbUser = System.getenv("DB_USER");
    String dbPassword = System.getenv("DB_PASSWORD");
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        String sql = "UPDATE users SET introduction = ? WHERE username = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, intro);
        pstmt.setString(2, username);
        pstmt.executeUpdate();
        pstmt.close(); conn.close();
        response.sendRedirect("/mypage/mypage.jsp");
    } catch (Exception e) {
        e.printStackTrace();
%> <script>alert("DB 오류"); history.back();</script> <%
    }
%>