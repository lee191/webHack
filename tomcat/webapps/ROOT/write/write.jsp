<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.UUID" %>
<%
String csrfToken = UUID.randomUUID().toString();
session.setAttribute("csrfToken", csrfToken);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>글쓰기</title>
    <link rel="stylesheet" type="text/css" href="write_styles.css">
    <script>
        function buildXMLandSubmit() {
            const title = document.querySelector('input[name="title"]').value;
            const content = document.querySelector('textarea[name="content"]').value;

            const xml =
                "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
                "<post>\n" +
                "  <title>" + escapeXml(title) + "</title>\n" +
                "  <content>" + escapeXml(content) + "</content>\n" +
                "</post>";

            document.getElementById("xmlField").value = xml;
            return true;
        }

        function escapeXml(str) {
            return str.replace(/&/g, "&amp;")
                      .replace(/</g, "&lt;")
                      .replace(/>/g, "&gt;")
                      .replace(/\"/g, "&quot;")
                      .replace(/\'/g, "&apos;");
        }
    </script>
</head>
<body>
    <h2>글쓰기</h2>
    <form action="writeProcess.jsp" method="post" enctype="multipart/form-data" onsubmit="return buildXMLandSubmit();">
        <!-- csrfToken 필드 -->
        <input type="hidden" name="csrfToken" id="csrfToken" value="<%= csrfToken %>">

        <!-- xml 필드 -->
        <input type="hidden" name="xml" id="xmlField">

        <label>제목:</label><br>
        <input type="text" name="title" required><br><br>

        <label>내용:</label><br>
        <textarea name="content" rows="5" cols="60" required></textarea><br><br>

        <label>파일 업로드:</label><br>
        <input type="file" name="file"><br><br>

        <button type="submit">전송</button>
    </form>
</body>
</html>
