<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*" %>

<%
String fileName = request.getParameter("fileName");

// 1. 유효하지 않은 파일명 차단
if (fileName == null || fileName.contains("..") || fileName.contains("/") || fileName.contains("\\") || fileName.startsWith(File.separator)) {
    out.println("<script>alert('잘못된 파일 요청입니다.'); history.back();</script>");
    return;
}

// 2. 업로드 경로 설정
String uploadPath = application.getRealPath("/WEB-INF/uploads");
File file = new File(uploadPath, fileName);

// 3. Canonical 경로 비교 (디렉토리 탈출 방지)
String canonicalUploadPath = new File(uploadPath).getCanonicalPath();
String canonicalFilePath = file.getCanonicalPath();

if (!canonicalFilePath.startsWith(canonicalUploadPath)) {
    out.println("<script>alert('허용되지 않은 파일 경로입니다.'); history.back();</script>");
    return;
}

// 4. 파일 다운로드
if (file.exists() && file.isFile()) {
    // 확장자 기반 Content-Type 설정 (필요시 개선)
    response.setContentType("application/octet-stream");

    // 한글 파일명 대응
    String encodedFileName = new String(fileName.getBytes("UTF-8"), "ISO8859_1");
    response.setHeader("Content-Disposition", "attachment; filename=\"" + encodedFileName + "\"");

    try (
        FileInputStream in = new FileInputStream(file);
        OutputStream outStream = response.getOutputStream()
    ) {
        byte[] buffer = new byte[8192];
        int bytesRead;
        while ((bytesRead = in.read(buffer)) != -1) {
            outStream.write(buffer, 0, bytesRead);
        }
    } catch (IOException e) {
        getServletContext().log("파일 다운로드 중 오류 발생", e);
        out.println("<script>alert('파일 전송 중 오류가 발생했습니다.'); history.back();</script>");
    }

} else {
    out.println("<script>alert('파일이 존재하지 않습니다.'); history.back();</script>");
}
%>
