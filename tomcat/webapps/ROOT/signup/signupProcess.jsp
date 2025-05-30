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
    String confirmPassword = request.getParameter("confirmPassword");
    String email = request.getParameter("email");
    if (!password.equals(confirmPassword)) {
        out.println("<script>alert('비밀번호가 일치하지 않습니다.');</script>");
        out.println("<script>window.location.href='signup.jsp';</script>");
        return;
    }

    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    String dbURL = System.getenv("DB_URL");
    String dbUser = System.getenv("DB_USER");
    String dbPassword = System.getenv("DB_PASSWORD");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

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
            else{
                // 비밀번호를 MD5 해시로 변환
                 password = md5(password);

                // 회원가입 INSERT
                String insertQuery = "INSERT INTO users (username, password, email) VALUES ('" + username + "', '" + password + "', '" + email + "')";
                int result = stmt.executeUpdate(insertQuery);

                if (result > 0) {
                    out.println("회원가입 성공");
                    //alert 창 띄우기
                    out.println("<script>alert('회원가입 성공');</script>");
                    // 로그인 페이지로 리다이렉트
                    out.println("<script>window.location.href='/login/login.jsp';</script>");

                } else {
                    out.println("회원가입 실패");
                    //alert 창 띄우기
                    out.println("<script>alert('회원가입 실패');</script>");
                    // 회원가입 페이지로 리다이렉트
                    out.println("<script>window.location.href='signup.jsp';</script>");

                }
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
