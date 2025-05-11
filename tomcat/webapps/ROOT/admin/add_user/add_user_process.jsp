<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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
    String username = request.getParameter("username"); 
    String password = request.getParameter("password");
    String email = request.getParameter("email");

    // 비밀번호를 MD5 해시로 변환
    password = md5(password);

    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/my_database", 
            "test", "test"
        );

        stmt = conn.createStatement();

        // Blind SQLi 가능한 취약한 중복 체크 로직
        String checkQuery = "SELECT * FROM users WHERE username = '" + username + "' OR email = '" + email + "'";
        rs = stmt.executeQuery(checkQuery);

        if (rs.next()) {
            //alert 창 띄우기
            out.println("<script>alert('이미 존재하는 아이디 또는 이메일입니다.');</script>");
            // 회원가입 페이지로 리다이렉트
            out.println("<script>window.location.href='add_user.jsp';</script>");
            
        } else {
            // INSERT
            String insertQuery = "INSERT INTO users (username, password, email) VALUES ('" + username + "', '" + password + "', '" + email + "')";
            int result = stmt.executeUpdate(insertQuery);

            if (result > 0) {
                //alert 창 띄우기
                out.println("<script>alert('[  OK  ] User Add');</script>");
                // 로그인 페이지로 리다이렉트
                out.println("<script>window.location.href='/admin/user_list/user_list.jsp';</script>");

            } else {
                //alert 창 띄우기
                out.println("<script>alert('[ FAIL ]');</script>");
                // 회원가입 페이지로 리다이렉트
                out.println("<script>window.location.href='add_user.jsp';</script>");

            }
        }

    } catch (Exception e) {
        out.println("사용자 추가가 실패");
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (Exception e) {}
    }   

%>