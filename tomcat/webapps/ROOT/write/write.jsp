<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>글쓰기</title>
    <link rel="stylesheet" type="text/css" href="write_styles.css">
    <script>
        function buildXMLandSubmit(form) {
            const title = form.title.value;
            const content = form.content.value;

            // 문자열 연결 방식 사용 → JSP가 간섭하지 않음
            const xml =
                "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
                "<post>\n" +
                "  <title>" + escapeXml(title) + "</title>\n" +
                "  <content>" + escapeXml(content) + "</content>\n" +
                "</post>";

            form.xml.value = xml;
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
    <!-- 상단 네비게이션 -->
    <div class="navbar">
        <a href="/index.jsp" class="logo">TEST<span class="white-text">GAMES</span></a>
        <div class="navbar-right">
                <a href="/index.jsp">MAIN</a>
                <a href="/board/board.jsp">BLOG</a>
                <a href="/login/logout.jsp">LOGOUT</a>
        </div>
    </div>

    <h2>글쓰기</h2>
    <form action="writeProcess.jsp" method="post" enctype="multipart/form-data" onsubmit="return buildXMLandSubmit(this);">
        <label>제목:</label><br>
        <input type="text" name="title" required><br><br>

        <label>내용:</label><br>
        <textarea name="content" rows="5" cols="60" required></textarea><br><br>

        <label>파일 업로드:</label><br>
        <input type="file" name="file"><br><br>

        <!-- 실제로 전송될 XML 데이터 (자동 생성됨) -->
        <textarea name="xml" rows="10" cols="80" style="display:none;"></textarea>

        <button type="submit">전송</button>
    </form>
</body>
</html>
