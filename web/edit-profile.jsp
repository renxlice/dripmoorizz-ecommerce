<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String nama = (String) session.getAttribute("nama");
    if (nama == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String email = "";
    String password = "";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true", "root", "root");

        if ("POST".equalsIgnoreCase(request.getMethod()) && "delete".equals(request.getParameter("action"))) {
            ps = conn.prepareStatement("DELETE FROM regis_tb WHERE nama = ?");
            ps.setString(1, nama);
            int deleted = ps.executeUpdate();
            if (deleted > 0) {
                session.invalidate();
                session = request.getSession();
                session.setAttribute("deleteSuccess", "Akun Anda berhasil dihapus.");
                response.sendRedirect("logout.jsp");
                return;
            } else {
                session.setAttribute("deleteFail", "Gagal menghapus akun.");
            }
        }

        ps = conn.prepareStatement("SELECT email, password FROM regis_tb WHERE nama = ?");
        ps.setString(1, nama);
        rs = ps.executeQuery();
        if (rs.next()) {
            email = rs.getString("email");
            password = rs.getString("password"); // plaintext
        }

    } catch (Exception e) {
        session.setAttribute("deleteFail", "Error: " + e.getMessage());
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Profile</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: url('images/Milk-Protein-Panel.jpg') no-repeat center center fixed;
            background-size: cover;
            color: #fff;
            min-height: 100vh;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow-x: hidden;
        }

        .overlay {
            background: rgba(0, 0, 0, 0.6);
            min-height: 100vh;
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .container {
            max-width: 500px;
            width: 100%;
            background: rgba(255, 255, 255, 0.08);
            padding: 30px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
            text-align: center;
        }

        label {
            font-weight: 600;
        }

        .btn-custom {
            background-color: #6c63ff;
            color: white;
            border-radius: 8px;
            font-weight: 600;
        }

        .btn-custom:hover {
            background-color: #574b90;
        }

        .btn-cancel {
            background-color: transparent;
            color: #fff;
            border: 2px solid #fff;
            border-radius: 8px;
            font-weight: 600;
        }

        .btn-cancel:hover {
            background-color: rgba(255, 255, 255, 0.2);
        }

        .btn-danger {
            border-radius: 8px;
            font-weight: 600;
        }

        .btn-group {
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 10px;
        }
    </style>
</head>
<body>
<div class="overlay">
    <div class="container">
        <h2 class="text-center mb-4">Edit Profile</h2>
        <form action="update-profile.jsp" method="post">
            <div class="mb-3">
                <label for="nama">Nama</label>
                <input type="text" class="form-control" id="nama" name="nama" value="<%= nama %>" required>
            </div>
            <div class="mb-3">
                <label for="email">Email</label>
                <input type="email" class="form-control" id="email" name="email" value="<%= email %>" required>
            </div>
            <div class="mb-3">
                <label for="password">Password</label>
                <input type="text" class="form-control" id="password" name="password" placeholder="Masukkan Password Baru" required>
            </div>
            <div class="btn-group mt-4">
                <button type="submit" class="btn btn-custom">Update</button>
                <a href="dashboard.jsp" class="btn btn-cancel">Cancel</a>
            </div>
        </form>

        <form method="post" class="mt-4" onsubmit="return confirmDelete(event)">
            <input type="hidden" name="action" value="delete">
            <button type="submit" class="btn btn-danger w-100">🗑️ Delete Account</button>
        </form>
    </div>
</div>

<script>
    function confirmDelete(event) {
        event.preventDefault();
        Swal.fire({
            title: 'Yakin ingin menghapus akun?',
            text: "Akun Anda akan dihapus permanen!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#aaa',
            confirmButtonText: 'Ya, hapus!',
            cancelButtonText: 'Batal'
        }).then((result) => {
            if (result.isConfirmed) {
                event.target.submit();
            }
        });
        return false;
    }
</script>

<% if (session.getAttribute("deleteFail") != null) { %>
<script>
    Swal.fire({
        icon: 'error',
        title: 'Oops!',
        text: "<%= session.getAttribute("deleteFail") %>"
    });
</script>
<% session.removeAttribute("deleteFail"); } %>

</body>
</html>
