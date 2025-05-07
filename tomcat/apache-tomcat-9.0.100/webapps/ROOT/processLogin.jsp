<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="io.jsonwebtoken.*" %>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    String dbURL = "jdbc:mysql://localhost:3306/my_database";
    String dbUser = "test";
    String dbPassword = "test";

    boolean isValidUser = false;

    try {
        // 비밀번호를 MD5로 해시 (테스트 목적)
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

        // 취약한 방식: 사용자 입력값을 문자열로 직접 삽입 → SQL Injection 발생 가능
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

    String secretKey = "yourSecretKey";

    if (isValidUser) {
        // JWT 토큰 생성
        String jwtToken = Jwts.builder()
            .setSubject(username)
            .setIssuedAt(new java.util.Date())
            .setExpiration(new java.util.Date(System.currentTimeMillis() + 3600000)) // 1시간 유효
            .signWith(SignatureAlgorithm.HS256, secretKey)
            .compact();

        // JWT 토큰을 쿠키에 저장
        Cookie authCookie = new Cookie("authToken", jwtToken);
        authCookie.setHttpOnly(true);
        authCookie.setMaxAge(3600); // 1시간
        response.addCookie(authCookie);

        response.sendRedirect("board.jsp");
    } else {
%>
        <script>
            alert("아이디 또는 비밀번호가 잘못되었습니다.");
            history.back();
        </script>
<%
    }
%>
