<%@ page import="java.sql.*" %>
<%
    String idPesanan = request.getParameter("id_pesanan");

    String dbURL = "jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true";
    String dbUser = "root";
    String dbPass = "root";

    Connection conn = null;
    PreparedStatement ps = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        String sql = "UPDATE data_pesanan SET status = 'Dikonfirmasi' WHERE id_pesanan = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, idPesanan);
        int updated = ps.executeUpdate();

        if (updated > 0) {
            // Simulasikan kirim notifikasi (misalnya, nanti bisa diganti jadi email atau dashboard user)
            session.setAttribute("notif", "Pesanan ID " + idPesanan + " berhasil dikonfirmasi dan sedang diproses.");
        } else {
            session.setAttribute("notif", "Gagal mengonfirmasi pesanan.");
        }

    } catch (Exception e) {
        session.setAttribute("notif", "Terjadi error: " + e.getMessage());
    } finally {
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }

    response.sendRedirect("DetailPesanan.jsp?id=" + idPesanan + "&confirm=success");
%>
