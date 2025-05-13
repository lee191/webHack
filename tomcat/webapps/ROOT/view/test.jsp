<%@ page import="javax.servlet.annotation.MultipartConfig" %>
<%@ page import="javax.servlet.http.Part" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="false" %>

<%
    // JSP 내에서 MultipartConfig 애노테이션을 적용
    // JSP는 서블릿 클래스로 변환되므로 런타임에서 직접 처리해줘야 함
    request.setAttribute("org.apache.catalina.jsp_file", request.getServletPath());
%>

<!DOCTYPE html>
<html>
<head>
    <title>SSI Upload Test</title>
</head>
<body>
<h2>SSI 인젝션 테스트 (취약한 파일 업로드)</h2>

<form method="post" enctype="multipart/form-data">
    업로드할 .shtml 파일: <input type="file" name="file"><br><br>
    <input type="submit" value="업로드">
</form>

<%
    String uploadDir = application.getRealPath("/") + "uploads";
    File dir = new File(uploadDir);
    if (!dir.exists()) dir.mkdirs();

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        Part filePart = request.getPart("file");
        String fileName = filePart.getSubmittedFileName();
        
        // 확장자 제한 없음 → 취약점
        File uploadedFile = new File(uploadDir, fileName);
        try (InputStream is = filePart.getInputStream(); FileOutputStream fos = new FileOutputStream(uploadedFile)) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = is.read(buffer)) != -1) {
                fos.write(buffer, 0, bytesRead);
            }
        }

        out.println("<p>파일 업로드 완료: <a href='uploads/" + fileName + "' target='_blank'>" + fileName + "</a></p>");
    }
%>

</body>
</html>
