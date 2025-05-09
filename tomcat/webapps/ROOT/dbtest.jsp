<%@ page import="java.sql.*" %>
<%
    String jdbcUrl = "jdbc:mysql://172.17.0.1:3306/my_database";
    String dbUser = "test";
    String dbPass = "test";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
        out.println("<h2>DB [  OK  ]! </h2>");
        conn.close();
    } catch (Exception e) {
        out.println("<h2>DB [ FAIL ] </h2>");
        out.println("<pre>" + e.toString() + "</pre>");
    }
%>