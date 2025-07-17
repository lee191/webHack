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

<main class="write-main">
    <div class="write-card">
        <div class="write-title">✏️ 글쓰기</div>
        <form action="writeProcess.jsp" method="post" enctype="multipart/form-data" onsubmit="return buildXMLandSubmit();">
            <input type="hidden" name="csrfToken" id="csrfToken" value="<%= csrfToken %>">
            <input type="hidden" name="xml" id="xmlField">

            <label for="title" class="write-label">제목</label>
            <input type="text" name="title" id="title" class="write-input" required>

            <label for="content" class="write-label">내용</label>
            <textarea name="content" id="content" class="write-textarea" rows="6" required></textarea>

            <label for="file" class="write-label">파일 업로드</label>
            <input type="file" name="file" id="file" class="write-file">

            <button type="submit" class="write-btn">전송</button>
        </form>
    </div>
</main>

<footer class="mobile-footer">
    <span style="font-size:1.1em;">&copy; 2025 TESTGAMES</span><br>
    <span style="font-size:0.98em; color:#bbb;">이 웹사이트는 테스트 용도로 만들어졌습니다.</span>
</footer>

<!-- 모바일 하단 네비게이션 -->
<nav class="mobile-nav">
    <a href="/mobile/index.jsp">
        <svg viewBox="0 0 24 24" fill="none"><path d="M3 12L12 4l9 8" stroke="currentColor" stroke-width="2"/><path d="M5 10v10h14V10" stroke="currentColor" stroke-width="2"/></svg>
        홈
    </a>
    <a href="/mobile/board/board.jsp">
        <svg viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="14" rx="2" stroke="currentColor" stroke-width="2"/><path d="M7 10h10M7 14h6" stroke="currentColor" stroke-width="2"/></svg>
        게시판
    </a>
    <a href="/mobile/mypage/mypage.jsp">
        <svg viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="2"/><path d="M4 20c0-4 4-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="2"/></svg>
        마이페이지
    </a>
</nav>
</body>
</html>
