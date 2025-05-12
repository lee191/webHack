<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>파일 업로드 + XXE 테스트</title>
</head>
<body>
    <h2>파일 업로드 및 XML 파싱 (XXE 포함 가능)</h2>
    <form action="writeProcess.jsp" method="post" enctype="multipart/form-data">
        <label>제목:</label><br>
        <input type="text" name="title" required><br><br>

        <label>내용:</label><br>
        <textarea name="content" rows="5" cols="60" required></textarea><br><br>

        <label>파일 업로드:</label><br>
        <input type="file" name="file"><br><br>

        <label>XML 데이터 (XXE 테스트용):</label><br>
        <textarea name="xml" rows="10" cols="80" placeholder="여기에 XXE 포함 XML 입력"></textarea><br><br>

        <button type="submit">전송</button>
    </form>
</body>
</html>
