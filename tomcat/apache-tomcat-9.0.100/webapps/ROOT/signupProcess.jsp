<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String email = request.getParameter("email");

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

        // ❗Blind SQLi 가능한 취약한 중복 체크 로직
        String checkQuery = "SELECT * FROM users WHERE username = '" + username + "' OR email = '" + email + "'";
        rs = stmt.executeQuery(checkQuery);

        if (rs.next()) {
            //alert 창 띄우기
            out.println("<script>alert('이미 존재하는 아이디 또는 이메일입니다.');</script>");
            // 회원가입 페이지로 리다이렉트
            out.println("<script>window.location.href='signup.jsp';</script>");
            
        } else {
            // 비밀번호가 8자 이하면 회원가입 실패
            if (password.length() < 8) {
                out.println("<script>alert('비밀번호는 8자 이상이어야 합니다.');</script>");
                out.println("<script>window.location.href='signup.jsp';</script>");
                return;
            }
            // 회원가입 INSERT
            String insertQuery = "INSERT INTO users (username, password, email) VALUES ('" + username + "', '" + password + "', '" + email + "')";
            int result = stmt.executeUpdate(insertQuery);

            if (result > 0) {
                out.println("회원가입 성공");
            } else {
                out.println("회원가입 실패");
            }
        }

    } catch (Exception e) {
        out.println("회원가입 실패");
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (Exception e) {}
    }
%>
