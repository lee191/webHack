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
    <title>회원정보 수정</title>
    <link rel="stylesheet" href="/mypage/edit_styles.css">
</head>
<body>
    <div class="container">
        <h1>소개글 수정</h1>
        <form action="editProcess.jsp" method="post" enctype="multipart/form-data">
            <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
            <label for="intro">소개글</label>
            <textarea name="intro" id="intro" placeholder="소개글 입력..."></textarea>
            <button type="submit">저장</button>
        </form>
    </div>
</body>
</html>
