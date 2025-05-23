<%@ page import="java.sql.*" %>
<%
    // 환경변수에서 DB 정보 읽기 (없으면 기본값 사용)
    String jdbcUrl = System.getenv("DB_URL");
    String dbUser = System.getenv("DB_USER");
    String dbPass = System.getenv("DB_PASSWORD");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
        out.println("<h2>DB Connection Success!</h2>");
        out.println("<h2>DB URL : " + jdbcUrl + "</h2>");
        out.println("<h2>DB User : " + dbUser + "</h2>");
        conn.close();
    } catch (Exception e) {
        out.println("<h2>DB [ FAIL ] </h2>");
        out.println("<pre>" + e.toString() + "</pre>");
    }
%>