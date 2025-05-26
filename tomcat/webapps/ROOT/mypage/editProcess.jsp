<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*, java.io.*, java.security.Key, javax.servlet.http.Part" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="io.jsonwebtoken.*" %>
<%@ page import="java.io.BufferedReader, java.io.InputStreamReader" %>

<%
    // Multipart 설정
    request.setAttribute("org.apache.catalina.multipartConfig",
        new javax.servlet.MultipartConfigElement(System.getProperty("java.io.tmpdir")));
    request.setCharacterEncoding("UTF-8");

    // 1. CSRF 토큰 검증
    String csrfToken = null;
    for (Part part : request.getParts()) {
        if ("csrfToken".equals(part.getName())) {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(part.getInputStream(), "UTF-8"))) {
                csrfToken = reader.readLine();
            }
            break;
        }
    }
    String sessionToken = (String) session.getAttribute("csrfToken");
    if (csrfToken == null || sessionToken == null || !csrfToken.equals(sessionToken)) {
        getServletContext().log("CSRF 토큰 확인: 요청=" + csrfToken + ", 세션=" + sessionToken);
        out.println("<script>alert('CSRF 토큰이 유효하지 않습니다.'); history.back();</script>");
        return;
    }
    session.removeAttribute("csrfToken");

    // 2. JWT 인증
    String username = null;
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
            String jwtSecret = System.getenv("JWT_SECRET");
            if (jwtSecret != null) {
                byte[] keyBytes = jwtSecret.getBytes("UTF-8");
                Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());
                Claims claims = Jwts.parserBuilder()
                    .setSigningKey(signingKey)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
                username = claims.getSubject();
            }
        } catch (Exception e) {
            response.sendRedirect("/login/login.jsp");
            return;
        }
    }
    if (username == null) {
        response.sendRedirect("/login/login.jsp");
        return;
    }

    // 3. 소개글 파싱
    String intro = null;
    for (Part part : request.getParts()) {
        if ("intro".equals(part.getName())) {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(part.getInputStream(), "UTF-8"))) {
                intro = reader.readLine();
            }
            break;
        }
    }
    if (intro == null || intro.length() > 1000) {
        out.println("<script>alert('소개글 입력 오류'); history.back();</script>");
        return;
    }

    // 3-1. XSS + SSTI 방지 필터링
    intro = intro
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll("\\$\\{", "&#36;&#123;")
        .replaceAll("\\{\\{", "&#123;&#123;")
        .replaceAll("\\}\\}", "&#125;&#125;")
        .replaceAll("<%", "&lt;%")
        .replaceAll("%" + ">", "%&gt;");

    // 4. DB 저장
    String dbURL = System.getenv("DB_URL");
    String dbUser = System.getenv("DB_USER");
    String dbPassword = System.getenv("DB_PASSWORD");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword)) {
            String sql = "UPDATE users SET introduction = ? WHERE username = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, intro);
                pstmt.setString(2, username);
                pstmt.executeUpdate();
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('DB 오류가 발생했습니다.'); history.back();</script>");
        return;
    }

    // 5. 템플릿 파일 저장
    try {
        String path = application.getRealPath("/templates/");
        File dir = new File(path);
        if (!dir.exists()) dir.mkdirs();

        File file = new File(dir, "user_" + username + ".txt");
        try (PrintWriter writer = new PrintWriter(new FileWriter(file))) {
            writer.println(intro);
        }
    } catch (Exception e) {
        getServletContext().log("파일 저장 실패", e);
        out.println("<script>alert('파일 저장 오류: " + e.getMessage() + "');</script>");
        return;
    }

    out.println("<script>alert('소개글이 수정되었습니다.'); location.href='/mypage/mypage.jsp';</script>");
%>
