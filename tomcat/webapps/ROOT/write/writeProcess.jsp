<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.sql.*, javax.servlet.http.Part" %>
<%@ page import="javax.xml.parsers.*, org.w3c.dom.*" %>
<%@ page import="io.jsonwebtoken.*, javax.crypto.spec.SecretKeySpec, java.security.Key" %>

<%
request.setCharacterEncoding("UTF-8");

// 1. JWT 인증 확인
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
        response.sendRedirect("/login/login.jsp");
        return;
    }
}

if (username == null) {
    response.sendRedirect("/login/login.jsp");
    return;
}

// 초기화
String title = "";
String content = "";
String filename = "";
String xmlInput = request.getParameter("xml");

// 2. 파일 업로드
String uploadPath = application.getRealPath("/uploads");
File uploadDir = new File(uploadPath);
if (!uploadDir.exists()) uploadDir.mkdir();

Part filePart = request.getPart("file");
if (filePart != null && filePart.getSize() > 0) {
    filename = filePart.getSubmittedFileName();
    filePart.write(uploadPath + File.separator + filename);
}

// 3. XML 파싱 (XXE 허용 구조 유지)
if (xmlInput != null && !xmlInput.trim().isEmpty()) {
    try {
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setFeature("http://apache.org/xml/features/disallow-doctype-decl", false);
        dbf.setFeature("http://xml.org/sax/features/external-general-entities", true);
        dbf.setFeature("http://xml.org/sax/features/external-parameter-entities", true);
        dbf.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", true);
        dbf.setExpandEntityReferences(true);

        DocumentBuilder db = dbf.newDocumentBuilder();
        InputStream is = new ByteArrayInputStream(xmlInput.getBytes("UTF-8"));
        Document doc = db.parse(is);

        Element root = doc.getDocumentElement();
        title = root.getElementsByTagName("title").item(0).getTextContent();
        content = root.getElementsByTagName("content").item(0).getTextContent();
        // writer는 username으로 대체되므로 생략
    } catch (Exception e) {
        content = "XML 파싱 오류: " + e.getMessage();
        title = "제목 없음";
    }
}

// 4. DB 저장
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/my_database?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC",
        "test", "test"
    );
    String sql = "INSERT INTO posts (username, title, content, filename) VALUES (?, ?, ?, ?)";
    PreparedStatement pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, username);
    pstmt.setString(2, title);
    pstmt.setString(3, content);
    pstmt.setString(4, filename);
    pstmt.executeUpdate();
    pstmt.close();
    conn.close();
} catch (Exception e) {
    out.println("<p style='color:red;'>DB 오류: " + e.getMessage() + "</p>");
}

// 5. 완료 응답
out.println("<script>alert('업로드 완료!');</script>");
out.println("<script>location.href='/board/board.jsp';</script>");
%>
