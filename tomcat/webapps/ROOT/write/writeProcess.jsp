<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.sql.*, java.util.*, javax.servlet.http.Part" %>
<%@ page import="javax.xml.parsers.*, org.w3c.dom.*" %>
<%@ page import="io.jsonwebtoken.*, javax.crypto.spec.SecretKeySpec, java.security.Key" %>

<%
request.setCharacterEncoding("UTF-8");

// 1. CSRF 토큰 검증 (multipart 전송 처리 방식)
String csrfToken = null;
for (Part part : request.getParts()) {
    if ("csrfToken".equals(part.getName())) {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(part.getInputStream(), "UTF-8"))) {
            csrfToken = reader.readLine(); // hidden field는 1줄만 입력됨
        }
        break;
    }
}
String sessionToken = (String) session.getAttribute("csrfToken");

// CSRF 토큰이 없거나 일치하지 않으면 오류 처리
if (csrfToken == null || sessionToken == null || !csrfToken.equals(sessionToken)) {
    getServletContext().log("CSRF 토큰 오류: 요청 CSRF 토큰 = " + csrfToken + ", 세션 CSRF 토큰 = " + sessionToken);
    out.println("<script>alert('CSRF 토큰이 유효하지 않습니다.'); history.back();</script>");
    return;
}
session.removeAttribute("csrfToken");

// 2. JWT 인증 확인
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
        byte[] keyBytes = System.getenv("JWT_SECRET").getBytes("UTF-8");
        Key key = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());
        Claims claims = Jwts.parserBuilder()
            .setSigningKey(key)
            .setAllowedClockSkewSeconds(60)
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

// 3. 초기화
String title = "";
String content = "";
String filename = "";
String xmlInput = request.getParameter("xml");

// 4. 파일 업로드 처리
String uploadPath = application.getRealPath("/WEB-INF/uploads");
File uploadDir = new File(uploadPath);
// [보안] 업로드 경로가 존재하지 않을 경우 생성 (WEB-INF 하위로 설정해 웹에서 직접 접근 불가)
if (!uploadDir.exists()) uploadDir.mkdirs();

Part filePart = request.getPart("file");
if (filePart != null && filePart.getSize() > 0) {
    // [보안] 원본 파일명에서 디렉토리 경로 제거하여 디렉토리 트래버설 방지
    String original = new File(filePart.getSubmittedFileName()).getName();
    String ext = "";
    int i = original.lastIndexOf(".");
    if (i > 0) ext = original.substring(i).toLowerCase();

    // [보안] 허용된 확장자(화이트리스트)만 업로드 가능하도록 제한
    List<String> whitelist = Arrays.asList(".jpg", ".jpeg", ".png", ".pdf", ".txt", ".zip");
    if (!whitelist.contains(ext)) {
        out.println("<script>alert('허용되지 않은 파일 형식입니다.'); history.back();</script>");
        return;
    }

    // [보안] 업로드 시 저장 파일명을 무작위(UUID)로 변경하여 원본 파일명 및 경로 노출/중복/덮어쓰기 방지
    filename = UUID.randomUUID().toString() + ext;
    // [보안] 지정된 업로드 디렉토리 내에만 저장 (디렉토리 탈출 방지)
    filePart.write(new File(uploadDir, filename).getAbsolutePath());
}

// 5. XML 파싱 (XXE 방어 포함)
if (xmlInput != null && !xmlInput.trim().isEmpty()) {
    try {
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
        dbf.setFeature("http://xml.org/sax/features/external-general-entities", false);
        dbf.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
        dbf.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);
        dbf.setExpandEntityReferences(false);

        DocumentBuilder db = dbf.newDocumentBuilder();
        InputStream is = new ByteArrayInputStream(xmlInput.getBytes("UTF-8"));
        Document doc = db.parse(is);

        Element root = doc.getDocumentElement();
        title = root.getElementsByTagName("title").item(0).getTextContent().trim();
        content = root.getElementsByTagName("content").item(0).getTextContent().trim();
    } catch (Exception e) {
        getServletContext().log("XML 파싱 오류", e);
        out.println("<script>alert('XML 파싱 오류'); history.back();</script>");
        return;
    }
}

// 6. 입력 유효성 검사
if (title.isEmpty() || content.isEmpty()) {
    out.println("<script>alert('제목과 내용을 모두 입력하세요.'); history.back();</script>");
    return;
}

// 7. DB 저장
String dbURL = System.getenv("DB_URL");
String dbUser = System.getenv("DB_USER");
String dbPassword = System.getenv("DB_PASSWORD");

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword)) {
        String sql = "INSERT INTO posts (username, title, content, filename) VALUES (?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            pstmt.setString(2, title);
            pstmt.setString(3, content);
            pstmt.setString(4, filename);
            pstmt.executeUpdate();
        }
    }
} catch (Exception e) {
    getServletContext().log("DB 저장 오류", e);
    out.println("<script>alert('DB 오류 발생'); history.back();</script>");
    return;
}

// 8. 완료 메시지
out.println("<script>alert('업로드 완료!'); location.href='/board/board.jsp';</script>");
%>
