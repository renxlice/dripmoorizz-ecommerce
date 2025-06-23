<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    String loggedUser = (String) session.getAttribute("nama");
    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String deleteStatus = null;
    boolean deleteSelf = false;
    
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("delete_id") != null) {
        Connection connDel = null;
        PreparedStatement psDel = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connDel = DriverManager.getConnection("jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true", "root", "root");
            
            // Check if we're deleting the currently logged in user
            psDel = connDel.prepareStatement("SELECT nama FROM regis_tb WHERE id = ?");
            psDel.setString(1, request.getParameter("delete_id"));
            ResultSet rs = psDel.executeQuery();
            
            if (rs.next()) {
                String deletedUser = rs.getString("nama");
                deleteSelf = deletedUser.equals(loggedUser);
            }
            
            // Perform the deletion
            psDel = connDel.prepareStatement("DELETE FROM regis_tb WHERE id = ?");
            psDel.setString(1, request.getParameter("delete_id"));
            int result = psDel.executeUpdate();
            deleteStatus = (result > 0) ? "success" : "fail";
            
            // If user deleted themselves, invalidate session
            if (deleteSelf) {
                session.invalidate();
                response.sendRedirect("login.jsp?deleted=self");
                return;
            }
            
        } catch (Exception e) {
            deleteStatus = "error";
        } finally {
            if (psDel != null) try { psDel.close(); } catch (Exception e) {}
            if (connDel != null) try { connDel.close(); } catch (Exception e) {}
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Data Register | DripmooRizz</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        html, body {
            height: 100%;
            margin: 0;
            font-family: 'Poppins', sans-serif;
            background: url('images/Milk-Protein-Panel.jpg') no-repeat center center fixed;
            background-size: cover;
            color: #fff;
        }
        
        .wrapper {
        display: flex;
        min-height: 100vh;
        background: rgba(0, 0, 0, 0.6);
        backdrop-filter: blur(5px);
        }

        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            width: 250px;
            height: 100vh;
            background-color: rgba(0, 0, 0, 0.8);
            padding: 30px 20px;
            color: #fff;
            z-index: 1000;
        }

        .sidebar h2 {
            font-size: 1.6rem;
            font-weight: 700;
            margin-bottom: 40px;
        }

        .sidebar a {
            display: block;
            margin: 15px 0;
            color: #fff;
            text-decoration: none;
            font-weight: 500;
            transition: 0.3s;
        }

        .sidebar a:hover {
            color: #6c63ff;
        }

        .content {
            margin-left: 250px;
            padding: 40px;
            min-height: 100vh;
            background: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(5px);
        }

        .card-glass {
            background-color: rgba(255, 255, 255, 0.08);
            border: none;
            border-radius: 20px;
            padding: 30px;
            color: #fff;
            backdrop-filter: blur(15px);
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.5);
        }

        .table {
            background-color: rgba(255, 255, 255, 0.95);
            border-radius: 12px;
            overflow: hidden;
            color: #333;
        }

        .table thead {
            background-color: #6c63ff;
            color: white;
        }

        .table td, .table th {
            vertical-align: middle;
            padding: 14px;
        }

        .table tbody tr:hover {
            background-color: #f5f5f5;
        }

        .btn-edit {
            background-color: #ffc107;
            color: black;
            border-radius: 10px;
            font-weight: 500;
            padding: 6px 14px;
            border: none;
        }

        .btn-delete {
            background-color: #dc3545;
            color: white;
            border-radius: 10px;
            font-weight: 500;
            padding: 6px 14px;
            border: none;
        }

        .btn-edit:hover {
            background-color: #e0a800;
        }

        .btn-delete:hover {
            background-color: #c82333;
        }

        .action-buttons {
            display: flex;
            gap: 6px;
        }
    </style>
</head>
<body>
<div class="sidebar">
    <h2><a href="dashboard.jsp" class="text-white text-decoration-none fw-bold">📊 Dashboard</a></h2>
    <a href="home.jsp">🏠 Home</a>
    <a href="DataRegister.jsp">📁 Data Register</a>
    <a href="DataBarang.jsp">📦 Data Barang</a>
    <a href="DataPesanan.jsp">🗃️ Data Pesanan</a>
    <a href="logout.jsp">🚪 Logout</a>
</div>

<div class="content">
    <div class="card-glass">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="mb-0">📋 Data Register</h3>
            <a href="dashboard.jsp" class="btn btn-custom btn-sm">← Dashboard</a>
        </div>

        <table class="table table-bordered table-hover shadow-sm">
            <thead>
            <tr>
                <th>No</th>
                <th>Name</th>
                <th>Email</th>
                <th style="width: 140px;">Action</th>
            </tr>
            </thead>
            <tbody>
            <%
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;
                int no = 1;

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true", "root", "root");
                    stmt = conn.createStatement();
                    rs = stmt.executeQuery("SELECT * FROM regis_tb");

                    while (rs.next()) {
                        String id = rs.getString("id");
                        String nama = rs.getString("nama");
                        String email = rs.getString("email");
            %>
            <tr>
                <td><%= no++ %></td>
                <td><%= nama %></td>
                <td><%= email %></td>
                <td>
                    <div class="action-buttons">
                        <button type="button" class="btn btn-edit btn-sm"
                                onclick="openEditModal('<%= id %>', '<%= nama %>', '<%= email %>')">Edit</button>
                        <form method="post" onsubmit="return confirmDelete(event, '<%= id %>')">
                            <input type="hidden" name="delete_id" id="delete_id_<%= id %>" value="<%= id %>">
                            <button type="submit" class="btn btn-delete btn-sm">Delete</button>
                        </form>
                    </div>
                </td>
            </tr>
            <%
                    }
                } catch (Exception e) {
                    out.println("<tr><td colspan='4'>Error: " + e.getMessage() + "</td></tr>");
                } finally {
                    if (rs != null) try { rs.close(); } catch (Exception e) {}
                    if (stmt != null) try { stmt.close(); } catch (Exception e) {}
                    if (conn != null) try { conn.close(); } catch (Exception e) {}
                }
            %>
            </tbody>
        </table>
    </div>
</div>

<!-- Edit Modal -->
<div class="modal fade" id="editModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-0" style="background: rgba(255,255,255,0.08); backdrop-filter: blur(15px); border-radius: 20px; box-shadow: 0 0 30px rgba(0,0,0,0.6); color: #fff;">
      <form action="update-user.jsp" method="post">
        <div class="modal-header border-0 pb-0">
          <h5 class="modal-title fw-semibold">✏️ Edit Data</h5>
          <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body px-4 py-3">
          <input type="hidden" name="id" id="edit-id">
          <div class="mb-3">
            <label for="edit-nama" class="form-label">👤 Name</label>
            <input type="text" class="form-control bg-light text-dark border-0 rounded-3 py-2 px-3" name="nama" id="edit-nama" required>
          </div>
          <div class="mb-3">
            <label for="edit-email" class="form-label">📧 Email</label>
            <input type="email" class="form-control bg-light text-dark border-0 rounded-3 py-2 px-3" name="email" id="edit-email" required>
          </div>
          <div class="mb-3">
            <label for="edit-password" class="form-label">🔒 New Password <span class="text-muted">(optional)</span></label>
            <input type="password" class="form-control bg-light text-dark border-0 rounded-3 py-2 px-3" name="password" id="edit-password" placeholder="Change Password">
          </div>
        </div>
        <div class="modal-footer border-0 px-4 pb-4 d-flex justify-content-between">
          <button type="submit" class="btn btn-success px-4 py-2 rounded-3 fw-semibold">💾 Save</button>
          <button type="button" class="btn btn-outline-light px-4 py-2 rounded-3 fw-semibold" data-bs-dismiss="modal">✖ Cancel</button>
        </div>
      </form>
    </div>
  </div>
</div>

<script>
    <% if ("success".equals(request.getParameter("edit"))) { %>
    Swal.fire({ icon: 'success', title: 'Berhasil Diperbarui', text: 'Data berhasil diedit!', timer: 2000, showConfirmButton: false });
    <% } %>

    <% if ("success".equals(deleteStatus)) { %>
    Swal.fire({ icon: 'success', title: 'Berhasil Dihapus', text: 'Data telah dihapus.', timer: 2000, showConfirmButton: false });
    <% } else if ("fail".equals(deleteStatus)) { %>
    Swal.fire({ icon: 'warning', title: 'Gagal Menghapus', text: 'Data tidak ditemukan!' });
    <% } else if ("error".equals(deleteStatus)) { %>
    Swal.fire({ icon: 'error', title: 'Kesalahan', text: 'Terjadi kesalahan saat menghapus data.' });
    <% } %>

    function confirmDelete(event, id, nama) {
        event.preventDefault();
        
        // Check if deleting own account
        const isSelf = '<%= loggedUser %>' === nama;
        const warningText = isSelf 
            ? "Anda akan menghapus AKUN ANDA SENDIRI! Setelah dihapus, Anda akan otomatis logout dan tidak bisa login lagi."
            : "Data akan dihapus permanen!";
            
        Swal.fire({
            title: isSelf ? 'HAPUS AKUN ANDA SENDIRI?' : 'Yakin ingin menghapus?',
            text: warningText,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#dc3545',
            cancelButtonColor: '#6c757d',
            confirmButtonText: isSelf ? 'Ya, hapus akun saya!' : 'Ya, hapus!',
            cancelButtonText: 'Batal',
            reverseButtons: true
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById("delete_id_" + id).form.submit();
            }
        });
        return false;
    }

    function openEditModal(id, nama, email) {
        document.getElementById('edit-id').value = id;
        document.getElementById('edit-nama').value = nama;
        document.getElementById('edit-email').value = email;
        document.getElementById('edit-password').value = "";
        new bootstrap.Modal(document.getElementById('editModal')).show();
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>