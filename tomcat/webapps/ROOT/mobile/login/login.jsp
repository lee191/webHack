<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>로그인</title>
    <!-- 모바일 전용 로그인 CSS -->
    <link rel="stylesheet" type="text/css" href="login_styles.css">
</head>
<body>

    <div class="login-main">
        <h1>LOGIN</h1>

        <form action="processLogin.jsp" method="post">
            <label for="username">ID</label>
            <input 
                type="text" 
                id="username" 
                name="username" 
                placeholder="아이디 입력" 
                required
            >

            <label for="password">Password</label>
            <input 
                type="password" 
                id="password" 
                name="password" 
                placeholder="비밀번호 입력" 
                required
            >

            <button type="submit">Login</button>
        </form>

        <div class="login-links" style="display:flex; gap:10px; justify-content:center; margin-top:20px;">
            <a href="/mobile/login/edit_pass.jsp" style="
                display:inline-flex; align-items:center; gap:6px;
                background:#ffe082; color:#232323; font-weight:600;
                border-radius: 18px; padding: 10px 18px; font-size:1em;
                box-shadow:0 2px 8px #0002; text-decoration:none;
                transition:background 0.18s, color 0.18s, transform 0.13s;
            " onmouseover="this.style.background='#e53935';this.style.color='#fffde7';this.style.transform='scale(1.04)';" onmouseout="this.style.background='#ffe082';this.style.color='#232323';this.style.transform='none';">
                <span style="font-size:1.2em;">🔑</span> 비밀번호 변경
            </a>
            <a href="/mobile/signup/signup.jsp" style="
                display:inline-flex; align-items:center; gap:6px;
                background:#8e24aa; color:#fff; font-weight:600;
                border-radius: 18px; padding: 10px 18px; font-size:1em;
                box-shadow:0 2px 8px #0002; text-decoration:none;
                transition:background 0.18s, color 0.18s, transform 0.13s;
            " onmouseover="this.style.background='#5e35b1';this.style.color='#fffde7';this.style.transform='scale(1.04)';" onmouseout="this.style.background='#8e24aa';this.style.color='#fff';this.style.transform='none';">
                <span style="font-size:1.2em; color:#fff;">👤</span> 회원가입
            </a>
            <a href="/mobile/index.jsp" style="
                display:inline-flex; align-items:center; gap:6px;
                background:#43c43a; color:#fff; font-weight:600;
                border-radius: 18px; padding: 10px 18px; font-size:1em;
                box-shadow:0 2px 8px #0002; text-decoration:none;
                transition:background 0.18s, color 0.18s, transform 0.13s;
            " onmouseover="this.style.background='#388e3c';this.style.color='#fffde7';this.style.transform='scale(1.04)';" onmouseout="this.style.background='#43c43a';this.style.color='#fff';this.style.transform='none';">
                <span style="font-size:1.2em;">🏠</span> 메인으로
            </a>
        </div>
    </div>

</body>
</html>
