<%@ page import="java.io.*" %>
<%
    String fileName = request.getParameter("fileName");
    String uploadPath = application.getRealPath("uploads");
    File file = new File(uploadPath + File.separator + fileName);

    if (file.exists()) {
        response.setContentType("application/octet-stream");
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
