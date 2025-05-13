<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="freemarker.template.*, java.io.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%
    Configuration cfg = new Configuration(Configuration.VERSION_2_3_32);
    cfg.setDirectoryForTemplateLoading(new File(application.getRealPath("/templates"))); // 템플릿 위치
    cfg.setDefaultEncoding("UTF-8");

    Template temp = cfg.getTemplate("sample.ftl");

    // 데이터 모델 설정
    Map<String, Object> data = new HashMap<>();
    data.put("username", "성진");
    data.put("message", "환영합니다!");

    Writer outWriter = response.getWriter();
    temp.process(data, outWriter); // 템플릿 + 데이터 결합
%>
