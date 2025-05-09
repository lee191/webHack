<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>게시물 삭제</title>
    <link rel="stylesheet" type="text/css" href="delete.css">
</head>
<body>
    <h1>게시물 삭제</h1>
    <form action="delete_process.jsp" method="post">
        <label for="id">삭제할 게시물 ID:</label>
        <input type="int" id="id" name="id" required><br>

        <label for="password">관리자 비밀번호:</label>
        <input type="password" id="password" name="password" required><br>

        <button type="submit">게시물 삭제</button>
    </form>
    <a href="/admin/board_list/board_list.jsp">게시판 관리 페이지로 돌아가기</a>

</body>
</html>