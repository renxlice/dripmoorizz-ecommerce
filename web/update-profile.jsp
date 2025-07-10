<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    String updateStatus = "";
    String sessionNama = (String) session.getAttribute("nama");

    if (sessionNama == null) {
        updateStatus = "Sesi tidak valid. Silakan login ulang.";
    } else if ("POST".equalsIgnoreCase(request.getMethod())) {
        String namaBaru = request.getParameter("nama");
        String emailBaru = request.getParameter("email");
        String passwordBaru = request.getParameter("password");

        boolean updateNama = namaBaru != null && !namaBaru.trim().isEmpty();
        boolean updateEmail = emailBaru != null && !emailBaru.trim().isEmpty();
        boolean updatePassword = passwordBaru != null && !passwordBaru.trim().isEmpty();

        if (!updateNama && !updateEmail && !updatePassword) {
            updateStatus = "Silakan isi setidaknya satu kolom yang ingin diperbarui.";
        } else {
            Connection conn = null;
            PreparedStatement pstmt = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true", "root", "root");

                // Build SQL query dynamically
                StringBuilder sql = new StringBuilder("UPDATE regis_tb SET ");
                if (updateNama) sql.append("nama = ?");
                if (updateNama && updateEmail) sql.append(", ");
                if (updateEmail) sql.append("email = ?");
                if ((updateNama || updateEmail) && updatePassword) sql.append(", ");
                if (updatePassword) sql.append("password = ?");
                sql.append(" WHERE nama = ?");

                pstmt = conn.prepareStatement(sql.toString());

                int paramIndex = 1;
                if (updateNama) pstmt.setString(paramIndex++, namaBaru);
                if (updateEmail) pstmt.setString(paramIndex++, emailBaru);
                if (updatePassword) pstmt.setString(paramIndex++, passwordBaru); // plaintext
                pstmt.setString(paramIndex, sessionNama); // WHERE nama = ?

                int rows = pstmt.executeUpdate();
                if (rows > 0) {
                    // Update session attributes if needed
                    if (updateNama) session.setAttribute("nama", namaBaru);
                    if (updateEmail) session.setAttribute("email", emailBaru);
                    session.setAttribute("updateStatus", "Data berhasil diperbarui!");
                    response.sendRedirect("dashboard.jsp?status=success");
                    return;
                } else {
                    updateStatus = "Gagal memperbarui data. Nama tidak ditemukan.";
                }
            } catch (Exception e) {
                updateStatus = "Error: " + e.getMessage();
            } finally {
                if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
                if (conn != null) try { conn.close(); } catch (Exception e) {}
            }
        }
    } else {
        updateStatus = "Akses tidak valid.";
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Update Profile</title>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        .swal2-popup-custom {
            font-size: 1rem;
            border-radius: 15px;
            padding: 1.5rem;
        }
    </style>
</head>
<body>
<%
    String status = request.getParameter("status");
    if ("success".equals(status)) {
%>
<script>
    Swal.fire({
        title: "Berhasil!",
        text: "Data profil berhasil diperbarui.",
        icon: "success",
        confirmButtonText: "OK",
        customClass: {
            popup: 'swal2-popup-custom'
        }
    }).then(() => {
        window.location.href = "dashboard.jsp";
    });
</script>
<%
    } else if (!updateStatus.isEmpty()) {
%>
<script>
    Swal.fire({
        title: "Gagal!",
        text: "<%= updateStatus %>",
        icon: "error",
        confirmButtonText: "OK",
        customClass: {
            popup: 'swal2-popup-custom'
        }
    });
</script>
<%
    }
%>
</body>
</html>
