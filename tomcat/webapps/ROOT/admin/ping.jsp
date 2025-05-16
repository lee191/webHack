<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.io.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String target = request.getParameter("host");

    // 환경변수에서 DB 접속 정보 불러오기
    String dbUser = System.getenv("DB_USER");
    String dbPass = System.getenv("DB_PASSWORD");

    if ("POST".equalsIgnoreCase(request.getMethod()) && target != null && !target.isEmpty()) {
        try {
            // 사용자 입력을 명령어에 직접 삽입 (취약점 유지)
            String cmd = "mysqladmin -h " + target + " -u " + dbUser + " -p" + dbPass + " ping";

            Process proc = Runtime.getRuntime().exec(new String[]{"/bin/sh", "-c", cmd});
            BufferedReader reader = new BufferedReader(new InputStreamReader(proc.getInputStream()));
            String line;
%>
            <h2>DB 상태 결과 (<?= target %>):</h2>
            <pre>
<%
            while ((line = reader.readLine()) != null) {
                out.println(line);
            }
%>
            </pre>
<%
        } catch (Exception e) {
            out.println("<b>오류 발생:</b> " + e.getMessage());
        }
    } else {
%>
    <link rel="stylesheet" href="/admin/ping_styles.css">
    <div class="container">
        <h3>DB 상태 확인 (POST)</h3>
        <form method="POST">
            <label>DB 호스트 주소:</label>
            <input type="text" name="host" placeholder="127.0.0.1">
            <button type="submit">DB Ping</button>
        </form>
    </div>
<%
    }
%>
