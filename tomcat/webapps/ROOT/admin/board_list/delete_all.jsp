<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String confirm = request.getParameter("confirm");

    if (confirm == null || !confirm.equals("true")) {
%>
    <!-- 확인 전: JavaScript로 confirm 팝업 -->
    <script>
        if (confirm("정말로 모든 게시물을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.")) {
            window.location.href = "<%= request.getRequestURI() %>?confirm=true";
        } else {
            alert("삭제가 취소되었습니다.");
            window.location.href = '/admin/board_list/board_list.jsp';
        }
    </script>
<%
        return;
    }
%>

<%-- 삭제 처리 로직 시작 --%>
<%
    String dbURL = "jdbc:mysql://172.17.0.1:3306/my_database";
    String dbUser = "test";
    String dbPassword = "test";

    Connection conn = null;
    Statement stmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        stmt = conn.createStatement();
        int result = stmt.executeUpdate("DELETE FROM posts");

        if (result > 0) {
%>
            <script>alert('전체 게시글 <%= result %>건이 삭제되었습니다.'); location.href='/admin/board_list/board_list.jsp';</script>
<%
        } else {
%>
            <script>alert('삭제할 게시글이 없습니다.'); location.href='/admin/board_list/board_list.jsp';</script>
<%
        }
    } catch (Exception e) {
%>
        <script>alert('오류 발생: <%= e.getMessage() %>'); location.href='/admin/board_list/board_list.jsp';</script>
<%
    } finally {
        if (stmt != null) try { stmt.close(); } catch (Exception ignore) {}
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>
