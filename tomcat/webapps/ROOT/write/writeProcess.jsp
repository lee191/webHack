<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.sql.*, javax.servlet.http.Part" %>
<%@ page import="javax.xml.parsers.*, org.w3c.dom.*" %>
<%@ page import="io.jsonwebtoken.*, javax.crypto.spec.SecretKeySpec, java.security.Key" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 1. 로그인 여부 확인 (JWT from cookie)
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
            byte[] keyBytes = "thisIsASecretKeyThatIsAtLeast32Bytes!".getBytes("UTF-8");
            Key key = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());
            Claims claims = Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody();
            username = claims.getSubject();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("/login/login.jsp");
            return;
        }
    }

    if (username == null) {
        response.sendRedirect("/login/login.jsp");
        return;
    }

    // 2. 사용자 입력 수신
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String filename = null;
    String parsedXml = "";

    // 3. 파일 업로드 처리
    String uploadPath = application.getRealPath("/uploads");
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdir();

    Part filePart = request.getPart("file");
    if (filePart != null && filePart.getSize() > 0) {
        filename = filePart.getSubmittedFileName();
        filePart.write(uploadPath + File.separator + filename);
    }

    // 4. XML 파싱 (XXE 허용 상태)
    String xmlInput = request.getParameter("xml");
    if (xmlInput != null && !xmlInput.trim().isEmpty()) {
        try {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            dbf.setFeature("http://apache.org/xml/features/disallow-doctype-decl", false); // ❗️ XXE 가능
            dbf.setFeature("http://xml.org/sax/features/external-general-entities", true);
            dbf.setFeature("http://xml.org/sax/features/external-parameter-entities", true);
            dbf.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", true);
            dbf.setExpandEntityReferences(true);

            DocumentBuilder db = dbf.newDocumentBuilder();
            InputStream is = new ByteArrayInputStream(xmlInput.getBytes("UTF-8"));
            Document doc = db.parse(is);

            parsedXml = doc.getDocumentElement().getTextContent();
        } catch (Exception e) {
            parsedXml = "XML 파싱 오류: " + e.getMessage();
        }
    }

    // 5. DB 저장
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/my_database?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC",
            "test", "test"
        );
        String sql = "INSERT INTO posts (username, title, content, filename) VALUES (?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, username); // 로그인된 사용자
        pstmt.setString(2, title);
        pstmt.setString(3, content);
        pstmt.setString(4, filename != null ? filename : ""); 
        pstmt.executeUpdate();
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>DB 오류: " + e.getMessage() + "</p>");
    }

    // 성공 메시지 alert
    out.println("<script>alert('업로드 완료!');</script>");
    out.println("<script>location.href='/board/board.jsp';</script>");
%>