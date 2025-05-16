<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*, java.sql.*, java.io.*, java.security.Key" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="io.jsonwebtoken.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    boolean isLoggedIn = false;
    String username = "", email = "";
    String token = null;

    String dbURL = System.getenv("DB_URL");
    String dbUser = System.getenv("DB_USER");
    String dbPassword = System.getenv("DB_PASSWORD");

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
        }
    }

    if (!isLoggedIn) {
        response.sendRedirect("/login/login.jsp");
        return;
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        PreparedStatement pstmt = conn.prepareStatement("SELECT email FROM users WHERE username = ?");
        pstmt.setString(1, username);
        ResultSet rs = pstmt.executeQuery();
        if (rs.next()) {
            email = rs.getString("email");
        }
        rs.close(); pstmt.close(); conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>마이페이지</title>
    <link rel="stylesheet" href="/mypage/mypage_styles.css">
</head>
<body>
    <div class="profile-header">
        <div class="profile-pic"></div>
    </div>
    <div class="profile-content">
        <h2><%= username %></h2>
        <p><%= email %></p>

        <div class="intro-box">
            <p><strong>소개글:</strong></p>
            <p><em>
            <%
                String path = "/templates/user_" + username + ".jsp";
                File f = new File(application.getRealPath(path));
                if (f.exists()) {
                    // 사용자 정의 PrintWriter에 JSP 실행 결과 캡처
                    final StringWriter stringWriter = new StringWriter();
                    final PrintWriter printWriter = new PrintWriter(stringWriter);

                    HttpServletResponse capturingResponse = new HttpServletResponseWrapper(response) {
                        @Override
                        public PrintWriter getWriter() {
                            return printWriter;
                        }
                    };

                    try {
                        request.getRequestDispatcher(path).include(request, capturingResponse);
                    } catch (Exception e) {
                        out.println("<p>템플릿 실행 중 오류 발생</p>");
                    }

                    printWriter.flush();
                    String introOutput = stringWriter.toString();
            %>
                    <%= introOutput %>
            <%
                } else {
            %>
                    <p><em>소개글이 없습니다.</em></p>
            <%
                }
            %>
            </em></p>
        </div>

        <div class="button-group">
            <a href="/mypage/edit.jsp" class="edit-btn">소개글 수정</a>
            <a href="/login/logout.jsp" class="logout-btn">로그아웃</a>
        </div>
    </div>
</body>
</html>
