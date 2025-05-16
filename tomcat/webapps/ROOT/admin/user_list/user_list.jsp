<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="io.jsonwebtoken.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>



<!DOCTYPE html>
<html>
<head>
    <title>사용자 목록</title>
    <link rel="stylesheet" href="user_list_styles.css">
</head>
<body>
    <h1>사용자 목록</h1>
    <table border="1">
        <tr>
            <th>Name</th>
            <th>Email</th>
        </tr>
        <%
            // Database connection parameters
            String dbURL = System.getenv("DB_URL");
            String dbUser = System.getenv("DB_USER");
            String dbPassword = System.getenv("DB_PASSWORD");
            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;

            try {
                // Load the JDBC driver
                Class.forName("com.mysql.cj.jdbc.Driver");

                // Establish the connection
                conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

                // Create a statement
                stmt = conn.createStatement();

                // Execute the query
                String query = "SELECT id, username, email FROM users";
                rs = stmt.executeQuery(query);

                // Iterate through the result set and display the data
                while (rs.next()) {
                    int id = rs.getInt("id");
                    String name = rs.getString("username");
                    String email = rs.getString("email");
        %>
        <tr>
            <td><%= name %></td>
            <td><%= email %></td>
        </tr>
        <%
                }
            } catch (Exception e) {
                out.println("<p>Error: " + e.getMessage() + "</p>");
            } finally {
                // Close resources
                if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
                if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
            }
        %>
    </table>
    <form action="/admin/index.jsp" method="post" style="display:inline;">
        <button type="submit">관리자 페이지</button>
    </form>
    <form action="/admin/add_user/add_user.jsp" method="post" style="display:inline;">
        <button type="submit">사용자 추가</button>
    </form>
    <form action="/admin/delete_user/delete_user.jsp" method="post" style="display:inline;">
        <button type="submit">사용자 삭제</button>
    </form>
</body>
</html>