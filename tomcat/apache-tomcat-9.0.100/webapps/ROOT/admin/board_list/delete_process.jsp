<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.util.*, java.security.Key" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="io.jsonwebtoken.*" %>

<%
    String id = request.getParameter("id");
    String password = request.getParameter("password");

    String dbURL = "jdbc:mysql://localhost:3306/my_database";
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

        // 사용자가 입력한 사용자가 존재하는지 확인
        String checkQuery = "SELECT * FROM posts WHERE id = '" + id + "'";
        Statement checkStmt = conn.createStatement();
        ResultSet checkRs = checkStmt.executeQuery(checkQuery);
        if (checkRs.next()) {
            // 게시물이 존재하는 경우
            out.println("<script>alert('게시물이 존재합니다.');</script>");
        } else {
            // 게시물이이 존재하지 않는 경우
            out.println("<script>alert('게시물이 존재하지 않습니다.');</script>");
            // delete_user.jsp로 리다이렉트
            out.println("<script>window.location.href='/admin/board_list/delete.jsp';</script>");
        }
        checkRs.close();
        checkStmt.close();

        // JWT에서 현재 로그인한 사용자 이름 추출
        String token = null;
        String admin_username = null;
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
                Claims claims = Jwts.parserBuilder().setSigningKey(signingKey).build().parseClaimsJws(token).getBody();
                admin_username = claims.getSubject();
            } catch (Exception e) {
                out.println("<script>alert('토큰 인증 실패: " + e.getMessage() + "'); location.href='/index.jsp';</script>");
                return;
            }
        }
        // SQL Injection 취약한 방식 (테스트용)
        String sql = "SELECT * FROM users WHERE username = '" + admin_username + "' AND password = '" + hashedPassword + "'";
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);

        if (rs.next()) {
            isValidUser = true;
            out.println("<script>alert('게시물 삭제 가능 합니다.');</script>");
            // 게시물물 삭제 쿼리
            String deleteQuery = "DELETE FROM posts WHERE id = '" + id + "'";
            int result = stmt.executeUpdate(deleteQuery);
            if (result > 0) {
                out.println("<script>alert('게시물 삭제 성공');</script>");
                out.println("<script>window.location.href='/admin/board_list/board_list.jsp';</script>");
            } else {
                out.println("<script>alert('게시물물 삭제 실패');</script>");
                out.println("<script>window.location.href='/admin/board_list/delete.jsp';</script>");
            }
        } else {
            out.println("<script>alert('비밀번호가 틀립니다.');</script>");
            out.println("<script>window.location.href='/admin/board_list/delete.jsp';</script>");
        }

        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

%>