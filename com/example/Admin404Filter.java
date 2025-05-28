package com.example;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class Admin404Filter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException { }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        String uri = req.getRequestURI();

        // /admin 또는 /admin/인 경우만 404
        if (uri.endsWith("/admin") || uri.endsWith("/admin/")) {
            ((HttpServletResponse) response).sendError(HttpServletResponse.SC_NOT_FOUND, "Not Found");
            return;
        }
        chain.doFilter(request, response);
    }


    @Override
    public void destroy() { }
}
