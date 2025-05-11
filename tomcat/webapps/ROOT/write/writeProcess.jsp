<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, java.util.*, io.jsonwebtoken.*, javax.crypto.spec.SecretKeySpec, java.security.Key" %>
<%@ page import="javax.servlet.http.Part" %>

<%
    request.setCharacterEncoding("UTF-8");

    // JWT에서 사용자 정보 추출
    String token = null;
    String username = null;
    boolean isAuthenticated = false;

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
            isAuthenticated = true;
        } catch (Exception e) {
            out.println("<script>alert('인증 실패: " + e.getMessage() + "'); location.href='index.jsp';</script>");
        }
    }

    if (!isAuthenticated) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='index.jsp';</script>");
        return;
    }

    // 입력값
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String filename = null;

    // 파일 업로드 처리
    String uploadPath = application.getRealPath("/uploads");
    // 업로드 경로 확인
    if (uploadPath == null) {
        out.println("<script>alert('업로드 경로를 찾을 수 없습니다.'); history.back();</script>");
        return;
    }
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdir();

    Part filePart = request.getPart("file");
    if (filePart != null && filePart.getSize() > 0) {
        filename = filePart.getSubmittedFileName();
        filePart.write(uploadPath + File.separator + filename);
    }

    // DB 저장
    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/my_database?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC",
            "test", "test"
        );
        String sql = "INSERT INTO posts (username, title, content, filename) VALUES (?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, username);
        pstmt.setString(2, title);
        pstmt.setString(3, content);
        pstmt.setString(4, filename);

        pstmt.executeUpdate();
        out.println("<script>alert('게시글이 등록되었습니다.'); location.href='/board/board.jsp';</script>");
    } catch (Exception e) {
        out.println("<script>alert('DB 오류: " + e.getMessage() + "'); history.back();</script>");
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>
