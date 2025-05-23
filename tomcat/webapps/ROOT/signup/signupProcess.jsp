<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.util.Base64" %>
<%@ page import="java.security.SecureRandom, java.security.spec.KeySpec" %>
<%@ page import="javax.crypto.SecretKeyFactory, javax.crypto.spec.PBEKeySpec" %>

<%!
    // 솔트 생성 함수
    public byte[] generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[16];
        random.nextBytes(salt);
        return salt;
    }

    // PBKDF2 해시 함수
    public String hashPassword(String password, byte[] salt) throws Exception {
        int iterations = 10000;
        int keyLength = 256;
        KeySpec spec = new PBEKeySpec(password.toCharArray(), salt, iterations, keyLength);
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        byte[] hash = factory.generateSecret(spec).getEncoded();
        return Base64.getEncoder().encodeToString(salt) + ":" + Base64.getEncoder().encodeToString(hash);
    }
%>

<%
request.setCharacterEncoding("UTF-8");

<%
request.setCharacterEncoding("UTF-8");

// 1. CSRF 토큰 검증 (multipart 전송 처리 방식)
String csrfToken = null;
for (Part part : request.getParts()) {
    if ("csrfToken".equals(part.getName())) {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(part.getInputStream(), "UTF-8"))) {
            csrfToken = reader.readLine(); // hidden field는 1줄만 입력됨
        }
        break;
    }
}
String sessionToken = (String) session.getAttribute("csrfToken");

// CSRF 토큰이 없거나 일치하지 않으면 오류 처리
if (csrfToken == null || sessionToken == null || !csrfToken.equals(sessionToken)) {
    getServletContext().log("CSRF 토큰 오류: 요청 CSRF 토큰 = " + csrfToken + ", 세션 CSRF 토큰 = " + sessionToken);
    out.println("<script>alert('CSRF 토큰이 유효하지 않습니다.'); history.back();</script>");
    return;
}
session.removeAttribute("csrfToken");


// 2. 사용자 입력 수집
String username = request.getParameter("username");
String password = request.getParameter("password");
String confirmPassword = request.getParameter("confirmPassword");
String email = request.getParameter("email");

// 3. 입력 유효성 검사
if (!password.equals(confirmPassword)) {
    out.println("<script>alert('비밀번호가 일치하지 않습니다.'); location.href='signup.jsp';</script>");
    return;
}
if (password.length() < 8) {
    out.println("<script>alert('비밀번호는 8자 이상이어야 합니다.'); location.href='signup.jsp';</script>");
    return;
}
if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
    out.println("<script>alert('이메일 형식이 올바르지 않습니다.'); location.href='signup.jsp';</script>");
    return;
}

// 4. DB 연결
String dbURL = System.getenv("DB_URL");
String dbUser = System.getenv("DB_USER");
String dbPassword = System.getenv("DB_PASSWORD");

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword)) {

        // 5. 아이디 또는 이메일 중복 체크
        String checkSQL = "SELECT COUNT(*) FROM users WHERE username = ? OR email = ?";
        try (PreparedStatement checkStmt = conn.prepareStatement(checkSQL)) {
            checkStmt.setString(1, username);
            checkStmt.setString(2, email);
            try (ResultSet rs = checkStmt.executeQuery()) {
                rs.next();
                if (rs.getInt(1) > 0) {
                    out.println("<script>alert('이미 존재하는 아이디 또는 이메일입니다.'); location.href='signup.jsp';</script>");
                    return;
                }
            }
        }

        // 6. 비밀번호 해시 및 저장
        byte[] salt = generateSalt();
        String hashedPassword = hashPassword(password, salt);

        String insertSQL = "INSERT INTO users (username, password, email) VALUES (?, ?, ?)";
        try (PreparedStatement insertStmt = conn.prepareStatement(insertSQL)) {
            insertStmt.setString(1, username);
            insertStmt.setString(2, hashedPassword);
            insertStmt.setString(3, email);
            int result = insertStmt.executeUpdate();

            if (result > 0) {
                out.println("<script>alert('회원가입 성공'); location.href='/login/login.jsp';</script>");
            } else {
                out.println("<script>alert('회원가입 실패'); location.href='signup.jsp';</script>");
            }
        }
    }
} catch (Exception e) {
    getServletContext().log("회원가입 오류", e);
    out.println("<script>alert('시스템 오류로 회원가입에 실패했습니다.'); location.href='signup.jsp';</script>");
}
%>
