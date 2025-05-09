<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

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
            <th>Password</th>
        </tr>
        <%
            // Database connection parameters
            String url = "jdbc:mysql://172.17.0.1:3306/my_database?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
            String username = "test";
            String db_password = "test";

            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;

            try {
                // Load the JDBC driver
                Class.forName("com.mysql.cj.jdbc.Driver");

                // Establish the connection
                conn = DriverManager.getConnection(url, username, db_password);

                // Create a statement
                stmt = conn.createStatement();

                // Execute the query
                String query = "SELECT id, username, email, password FROM users";
                rs = stmt.executeQuery(query);

                // Iterate through the result set and display the data
                while (rs.next()) {
                    int id = rs.getInt("id");
                    String name = rs.getString("username");
                    String email = rs.getString("email");
                    String password = rs.getString("password"); // MD5 해시된 비밀번호
        %>
        <tr>
            <td><%= name %></td>
            <td><%= email %></td>
            <td><%= password %></td>
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
    <form action="/admin/admin.jsp" method="post" style="display:inline;">
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