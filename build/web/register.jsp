<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    String nama = request.getParameter("nama");
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true";
        String user = "root";
        String pass = "root";

        conn = DriverManager.getConnection(url, user, pass);

        // Cek apakah email sudah terdaftar
        String checkQuery = "SELECT * FROM regis_tb WHERE email = ?";
        ps = conn.prepareStatement(checkQuery);
        ps.setString(1, email);
        rs = ps.executeQuery();

        if ("andiryaas49@gmail.com".equalsIgnoreCase(email)) {
            // Email admin tidak boleh didaftarkan ulang
            response.sendRedirect("tb1.html?error=admin_email_dilarang");
        } else if (rs.next()) {
            // Email sudah ada di database
            response.sendRedirect("tb1.html?error=email_terdaftar");
        } else {
            // Insert data baru
            ps.close(); // Tutup statement sebelumnya
            String insertQuery = "INSERT INTO regis_tb (nama, email, password) VALUES (?, ?, ?)";
            ps = conn.prepareStatement(insertQuery);
            ps.setString(1, nama);
            ps.setString(2, email);
            ps.setString(3, password);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                // Login otomatis setelah berhasil register
                session.setAttribute("nama", nama);
                session.setAttribute("email", email);
                response.sendRedirect("home.jsp");
            } else {
                response.sendRedirect("tb1.html?error=gagal_register");
            }
        }

    } catch (Exception e) {
        response.sendRedirect("tb1.html?error=server");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
