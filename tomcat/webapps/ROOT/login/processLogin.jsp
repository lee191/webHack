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
    // 파라미터 수집
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    password = md5(password); // 비밀번호 해시화

    // DB 접속 정보
    String dbURL = "jdbc:mysql://localhost:3306/my_database";
    String dbUser = "test";
    String dbPassword = "test";

    boolean isValidUser = false;

    try {
        // 1. DB 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        // 2. 취약한 SQL 쿼리 구성 (SQLi 테스트 가능)
        // username과 password가 그대로 삽입되므로 UNION, ERROR, BLIND 모두 가능
        String sql = "SELECT * FROM users WHERE username = '" + username + "' AND password = '" + password + "'";

        Statement stmt = conn.createStatement();

        // 3. 쿼리 실행
        ResultSet rs = stmt.executeQuery(sql);

        if (rs.next()) {
            isValidUser = true; // 쿼리 결과가 있으면 로그인 성공 처리
        }

        rs.close();
        stmt.close();
        conn.close();

    }catch (Exception e) {
    // Error-based SQLi용 에러 메시지 노출
    out.println("<h3>SQL 오류 발생!</h3>");
    out.println("<pre>");

    // StringWriter와 PrintWriter를 이용해 예외 메시지를 문자열로 출력
    java.io.StringWriter sw = new java.io.StringWriter();
    java.io.PrintWriter pw = new java.io.PrintWriter(sw);
    e.printStackTrace(pw);  // 예외 내용을 문자열로 변환
    out.println(sw.toString()); // JSP 출력 스트림으로 출력

    out.println("</pre>");
    }


    // 4. 로그인 성공 시 JWT 생성 및 쿠키 저장
    if (isValidUser) {
        // HS256 서명용 고정 키
        byte[] keyBytes = "thisIsASecretKeyThatIsAtLeast32Bytes!".getBytes("UTF-8");
        Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());

        // JWT 생성
        String jwtToken = Jwts.builder()
            .setSubject(username)
            .setIssuedAt(new java.util.Date())
            .setExpiration(new java.util.Date(System.currentTimeMillis() + 3600000)) // 1시간
            .signWith(signingKey, SignatureAlgorithm.HS256)
            .compact();

        // 쿠키 저장
        Cookie authCookie = new Cookie("authToken", jwtToken);
        authCookie.setHttpOnly(false); 
        authCookie.setMaxAge(3600);
        authCookie.setPath("/");
        response.addCookie(authCookie);

        // 관리자/일반 사용자 분기
        if (username.equals("admin")) {
            response.sendRedirect("/admin/index.jsp");
        } else {
            response.sendRedirect("/index.jsp");
        }

    } else {
%>
    <!-- 로그인 실패 시 경고창 -->
    <script>
        alert("아이디 또는 비밀번호가 잘못되었습니다.");
        history.back();
    </script>
<%
    }
%>
