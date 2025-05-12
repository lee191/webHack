<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.io.*" %>
<%
    String fileName = request.getParameter("fileName");

    // ✅ 취약점: fileName 검증 없음 (../ 포함 허용)
    // ex: fileName=../../../../etc/passwd

    String uploadPath = application.getRealPath("uploads");
    File file = new File(uploadPath + File.separator + fileName);

    if (file.exists()) {
        response.setContentType("application/octet-stream");

        // ✅ 파일명 인코딩 (다운로드시 한글 파일 깨짐 방지)
        response.setHeader("Content-Disposition", "attachment;filename=\"" + new String(fileName.getBytes("UTF-8"), "ISO8859_1") + "\"");

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
        out.println("<script>alert('파일이 존재하지 않습니다.'); history.back();</script>");
    }
%>
