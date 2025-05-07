<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.util.*" %>
<%@ page import="io.jsonwebtoken.*, javax.crypto.spec.SecretKeySpec" %>
<%@ page import="java.util.Base64, java.security.Key" %>

<%
    String token = null;
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("authToken".equals(cookie.getName())) {
                token = cookie.getValue();
            }
        }
    }

    if (token != null) {
        try {
            String secret = "yourSecretKey"; // 최소 256bit 이상 권장
            byte[] keyBytes = secret.getBytes("UTF-8");
            Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());

            Claims claims = Jwts.parserBuilder()
                .setSigningKey(signingKey)
                .build()
                .parseClaimsJws(token)
                .getBody();

            out.println("로그인 사용자: " + claims.getSubject());

        } catch (Exception e) {
            out.println("JWT 오류: " + e.getMessage());
        }
    } else {
        // JWT가 없으면 메세지 출력
        out.println("<script>alert('로그인 후 이용해주세요.');</script>");
        out.println("<script>window.location.href='index.jsp';</script>");
    }
%>

<%
    String action = request.getParameter("action");
    String uploadPath = application.getRealPath("uploads");
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) {
        uploadDir.mkdir();
    }

    if ("upload".equals(action)) {
        Part filePart = request.getPart("file");
        String fileName = filePart.getSubmittedFileName();
        filePart.write(uploadPath + File.separator + fileName);
        out.println("<p>파일 업로드 성공: " + fileName + "</p>");
    } else if ("download".equals(action)) {
        String fileName = request.getParameter("fileName");
        File file = new File(uploadPath + File.separator + fileName);
        if (file.exists()) {
            response.setContentType("application/octet-stream");
            response.setHeader("Content-Disposition", "attachment;filename=\"" + fileName + "\"");
            FileInputStream in = new FileInputStream(file);
            OutputStream outStream = response.getOutputStream();
            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                outStream.write(buffer, 0, bytesRead);
            }
            in.close();
            outStream.close();
        } else {
            out.println("<p>파일이 존재하지 않습니다.</p>");
        }
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>게시판</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <h1>게시판 </h1>
    <nav>
        <ul>
            <li><a href="index.jsp">메인 페이지</a></li>
            <li><a href="board.jsp">게시판</a></li>
            <li><a href="logout.jsp">로그아웃</a></li>
        </ul>
    </nav>
    <p>로그인에 성공하셨습니다. 게시판 내용을 확인하세요.</p>

    <h2>파일 업로드</h2>
    <form action="board.jsp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="action" value="upload">
        <input type="file" name="file">
        <button type="submit">업로드</button>
    </form>

    <h2>파일 다운로드</h2>
    <form action="board.jsp" method="get">
        <input type="hidden" name="action" value="download">
        <input type="text" name="fileName" placeholder="파일 이름 입력">
        <button type="submit">다운로드</button>
    </form>

    <h2>글쓰기</h2>
    <form action="writePost.jsp" method="post">
        <textarea name="content" rows="5" cols="50" placeholder="글 내용을 입력하세요"></textarea><br>
        <button type="submit">글쓰기</button>
    </form>

    <a href="index.jsp">메인 페이지로 돌아가기</a>
</body>
</html>