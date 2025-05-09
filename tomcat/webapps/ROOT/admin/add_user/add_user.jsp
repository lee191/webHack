<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>사용자 추가</title>
    <link rel="stylesheet" type="text/css" href="add_user_styles.css">
</head>
<body>
    <h1>사용자 추가</h1>
    <form action="add_user_process.jsp" method="post">
        <label for="username">아이디:</label>
        <input type="text" id="username" name="username" required><br>

        <label for="password">비밀번호:</label>
        <input type="password" id="password" name="password" required><br>

        <label for="email">이메일:</label>
        <input type="email" id="email" name="email" required><br>

        <button type="submit">User Add</button>
    </form>
    <a href="/admin/user_list/user_list.jsp">사용자 목록 페이지</a>

</body>
</html>


