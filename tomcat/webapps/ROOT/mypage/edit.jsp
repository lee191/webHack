<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.io.*, java.util.*, java.sql.*, java.security.Key" %>
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
            Claims claims = Jwts.parserBuilder()
                .build() // 서명 키 없음
                .parseClaimsJws(token)  // → alg=none 이라도 통과
                .getBody();
            username = claims.getSubject();
            isLoggedIn = true;
        } catch (Exception e) {
            isLoggedIn = false;
        }
    }

    if (!isLoggedIn) {
        response.sendRedirect("/login/login.jsp");
        return;
    }

    String intro = request.getParameter("intro");

    if (intro != null) {
        // 1. DB에 저장
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/my_database", "test", "test");
            String sql = "UPDATE users SET introduction = ? WHERE username = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, intro);
            pstmt.setString(2, username);
            pstmt.executeUpdate();
            pstmt.close(); conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 2. 템플릿 파일로 저장 (RCE 실험 가능)
        try {
            File file = new File(application.getRealPath("/templates/user_" + username + ".jsp"));
            try (PrintWriter writer = new PrintWriter(new FileWriter(file))) {
                writer.println(intro); // 사용자 입력 그대로 저장
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 3. 리디렉션
        out.println("<script>alert('소개글이 수정되었습니다.'); location.href='/mypage/mypage.jsp';</script>");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원정보 수정</title>
    <link rel="stylesheet" href="/mypage/edit_styles.css">
</head>
<body>
    <div class="container">
        <h1>소개글 수정</h1>
        <form method="post" action="/mypage/edit.jsp">
            <label for="intro">소개글</label>
            <textarea name="intro" id="intro" placeholder="영문 입력만 가능..."></textarea>
            <button type="submit">저장</button>
        </form>
    </div>
</body>
</html>
