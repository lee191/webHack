<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="java.security.Key" %>
<%@ page import="io.jsonwebtoken.*" %>
<%@ page import="io.jsonwebtoken.security.Keys" %>
<%@ page import="java.security.MessageDigest" %>
<%!
    // 문자열을 MD5 해시로 변환하는 함수
    String md5(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] messageDigest = md.digest(input.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : messageDigest) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            return null;
        }
    }
%>

<%
    // 사용자 입력값 수집
    String id = request.getParameter("username");     // 입력값
    String password = request.getParameter("password");
    password = md5(password);

    // DB 접속 정보 (환경변수 등 생략 가능)
    String dbURL = System.getenv("DB_URL");
    String dbUser = System.getenv("DB_USER");
    String dbPassword = System.getenv("DB_PASSWORD");

    boolean isValidUser = false;
    String username = "";  // DB에서 조회된 username

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        // SQLi 테스트 가능: 입력값 id, password 직접 삽입
        String sql = "SELECT * FROM users WHERE username = '" + id + "' AND password = '" + password + "'";
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);

        if (rs.next()) {
            username = rs.getString("username");  // DB 컬럼값
            isValidUser = true;
        }

        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<h3>SQL 오류 발생!</h3>");
        out.println("<pre>");
        java.io.StringWriter sw = new java.io.StringWriter();
        java.io.PrintWriter pw = new java.io.PrintWriter(sw);
        e.printStackTrace(pw);
        out.println(sw.toString());
        out.println("</pre>");
    }

    if (isValidUser) {
        // JWT 생성
        byte[] keyBytes = "thisIsASecretKeyThatIsAtLeast32Bytes!".getBytes("UTF-8");
        Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());

        String jwtToken = Jwts.builder()
            .setSubject(username)
            .setIssuedAt(new java.util.Date())
            .setExpiration(new java.util.Date(System.currentTimeMillis() + 3600000))
            .compact();

        Cookie authCookie = new Cookie("authToken", jwtToken);
        authCookie.setHttpOnly(false); 
        authCookie.setMaxAge(3600);
        authCookie.setPath("/");
        response.addCookie(authCookie);

        // 분기
        if ("admin".equals(username)) {
            response.sendRedirect("/admin/index.jsp");
        } else {
            response.sendRedirect("/index.jsp");
        }
    } else {
%>
    <script>
        alert("아이디 또는 비밀번호가 잘못되었습니다.");
        history.back();
    </script>
<%
    }
%>
