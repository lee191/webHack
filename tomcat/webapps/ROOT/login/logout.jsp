<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // 1. JWT 쿠키 제거
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("authToken".equals(cookie.getName())) {
                cookie.setValue("");
                cookie.setMaxAge(0);
                cookie.setPath("/");       // 반드시 동일한 path 지정
                cookie.setHttpOnly(true);  // 클라이언트 JS 접근 차단
                response.addCookie(cookie);
            }
        }
    }

    // 2. 세션 종료
    session.invalidate();

    // 3. 캐시 방지 (뒤로가기 방지 목적)
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // 4. 메인 페이지로 리디렉션
    response.sendRedirect("/index.jsp");
%>
