<%@ page import="java.sql.*" %>
<%
    String DBname = "my_database";
    String jdbcUrl = "jdbc:mysql://localhost:3306/" + DBname;
    String dbUser = "test";
    String dbPass = "test";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
        out.println("<h2>DB Connection Success!</h2>");
        out.println("<h2>DBname : " + DBname + "</h2>");
        out.println("<h2>DBuser : " + dbUser + "</h2>");
        conn.close();
    } catch (Exception e) {
        out.println("<h2>DB [ FAIL ] </h2>");
        out.println("<pre>" + e.toString() + "</pre>");
    }
%>