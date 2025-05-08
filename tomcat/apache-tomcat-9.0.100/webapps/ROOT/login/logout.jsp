<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // 쿠키 초기화 및 만료
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("authToken".equals(cookie.getName())) {
                cookie.setValue(null);
                cookie.setMaxAge(0); // 즉시 만료
                cookie.setPath("/"); // 경로 일치해야 삭제됨
                response.addCookie(cookie);
            }
        }
    }

    // 리다이렉트
    response.sendRedirect("../index.jsp");
%>
