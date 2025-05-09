<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<head>
    <meta charset="UTF-8">
    <title>글쓰기</title>
    <link rel="stylesheet" href="add.css">
</head>
<form action="add_process.jsp" method="post" enctype="multipart/form-data">
    <label>제목:</label><br>
    <input type="text" name="title" required><br><br>
    
    <label>내용:</label><br>
    <textarea name="content" rows="6" cols="60" required></textarea><br><br>

    <label>파일 첨부:</label><br>
    <input type="file" name="file"><br><br>

    <button type="submit">등록</button>
</form>
