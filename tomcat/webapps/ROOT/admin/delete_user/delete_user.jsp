<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>사용자 삭제</title>
    <link rel="stylesheet" type="text/css" href="delete_user_styles.css">
</head>
<body>
    <h1>사용자 삭제</h1>
    <form action="delete_user_process.jsp" method="post">
        <label for="username">삭제할 사용자:</label>
        <input type="text" id="username" name="username" required><br>

        <label for="password">관리자 비밀번호:</label>
        <input type="password" id="password" name="password" required><br>

        <button type="submit">Delete User</button>
    </form>
    <a href="/admin/index.jsp">관리자 페이지로 돌아가기</a>

</body>
</html>