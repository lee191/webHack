<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.sql.*, javax.servlet.http.Part" %>
<%@ page import="javax.xml.parsers.*, org.w3c.dom.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String filename = null;
    String parsedXml = "";

    // 1. 파일 업로드 처리 (확장자 필터링 없음)
    String uploadPath = application.getRealPath("/uploads");
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdir();

    Part filePart = request.getPart("file");
    if (filePart != null && filePart.getSize() > 0) {
        filename = filePart.getSubmittedFileName(); // 🔥 확장자 필터링 없음
        filePart.write(uploadPath + File.separator + filename);
    }

    // 2. XML 파싱 (XXE 허용된 상태)
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

    // 3. DB 저장 (옵션, 없으면 생략 가능)
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/my_database?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC",
            "test", "test"
        );
        String sql = "INSERT INTO posts (username, title, content, filename) VALUES (?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, "anonymous"); // JWT 없이 고정 유저 처리
        pstmt.setString(2, title);
        pstmt.setString(3, content);
        pstmt.setString(4, filename != null ? filename : ""); 
        pstmt.executeUpdate();
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>DB 오류: " + e.getMessage() + "</p>");
    }

%>

<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>처리 결과</title></head>
<body>
    <h2>✅ 업로드 완료</h2>
    <p>제목: <%= title %></p>
    <p>내용: <%= content %></p>
    <% if (filename != null) { %>
        <p>파일 저장: <strong>/uploads/<%= filename %></strong></p>
    <% } %>

    <% if (parsedXml != null && !parsedXml.trim().isEmpty()) { %>
        <h3>📦 XML 파싱 결과:</h3>
        <pre><%= parsedXml %></pre>
    <% } %>
</body>
</html>
