<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="java.security.Key" %>
<%@ page import="io.jsonwebtoken.*" %>
<%@ page import="io.jsonwebtoken.security.Keys" %>

<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    String dbURL = "jdbc:mysql://172.17.0.1:3306/my_database";
    String dbUser = "test";
    String dbPassword = "test";

    boolean isValidUser = false;

    try {
        // 비밀번호를 MD5로 해시
        MessageDigest md = MessageDigest.getInstance("MD5");
        md.update(password.getBytes());
        byte[] digest = md.digest();
        StringBuilder sb = new StringBuilder();
        for (byte b : digest) {
            sb.append(String.format("%02x", b));
        }
        String hashedPassword = sb.toString();

        // DB 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        // SQL Injection 취약한 방식 (테스트용)
        String sql = "SELECT * FROM users WHERE username = '" + username + "' AND password = '" + hashedPassword + "'";
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);

        if (rs.next()) {
            isValidUser = true;
        }

        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (isValidUser) {
        // HS256에 적합한 키 생성 (고정된 키 사용 가능)
        byte[] keyBytes = "thisIsASecretKeyThatIsAtLeast32Bytes!".getBytes("UTF-8");
        Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());

        // JWT 생성
        String jwtToken = Jwts.builder()
            .setSubject(username)
            .setIssuedAt(new java.util.Date())
            .setExpiration(new java.util.Date(System.currentTimeMillis() + 3600000))
            .signWith(signingKey, SignatureAlgorithm.HS256)
            .compact();

        // 쿠키에 저장
        Cookie authCookie = new Cookie("authToken", jwtToken);
        authCookie.setHttpOnly(true);
        authCookie.setMaxAge(3600);
        authCookie.setPath("/");
        response.addCookie(authCookie);

        // 관리자 페이지로 리다이렉트
        if (username.equals("admin")) {
            response.sendRedirect("/admin/admin.jsp");
        } else {
            response.sendRedirect("/index.jsp");
        }
    } 
    else {
%>
    <script>
        alert("아이디 또는 비밀번호가 잘못되었습니다.");
        history.back();
    </script>
<%
    }
%>
