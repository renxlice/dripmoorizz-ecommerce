<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    String loggedUser = (String) session.getAttribute("nama");
    String email = (String) session.getAttribute("email");
    Boolean isGoogleLogin = (Boolean) session.getAttribute("isGoogleLogin");

    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String id = "";
    String password = "";

    if (Boolean.TRUE.equals(isGoogleLogin)) {
        // User login via Google, data sudah ada di session: loggedUser & email
        // Password biasanya tidak tersedia, bisa disable edit password di UI
    } else {
        // Login manual: ambil data dari database berdasarkan nama user
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true", 
                    "root", "root")) {
                String sql = "SELECT id, email, password FROM regis_tb WHERE nama = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, loggedUser);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            id = rs.getString("id");
                            email = rs.getString("email");
                            password = rs.getString("password");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Dashboard | DripmooRizz</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
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
            top: 0;
            left: 0;
            height: 100vh;
            width: 250px;
            background-color: rgba(0, 0, 0, 0.8);
            padding: 40px 20px 30px 20px;
            color: #fff;
            z-index: 1000;
        }

        .sidebar h2 {
            font-size: 1.6rem;
            font-weight: 600;
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
            flex: 1;
            padding: 40px;
        }

        .card-glass {
            background-color: rgba(255, 255, 255, 0.1);
            border: none;
            border-radius: 20px;
            padding: 30px;
            color: #fff;
            backdrop-filter: blur(15px);
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.5);
            margin-bottom: 30px;
        }

        .card-glass h3 {
            font-weight: 600;
            margin-bottom: 20px;
        }

        .btn-custom {
            background-color: #6c63ff;
            border: none;
            padding: 10px 20px;
            color: #fff;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-custom:hover {
            background-color: #574b90;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(108, 99, 255, 0.4);
        }

        footer {
            text-align: center;
            padding: 15px;
            background: rgba(0, 0, 0, 0.4);
            color: #ccc;
        }

        /* Modal Styles */
        .modal-glass {
            background-color: rgba(0, 0, 0, 0.7);
            backdrop-filter: blur(10px);
        }

        .modal-content-glass {
            background-color: rgba(255, 255, 255, 0.1);
            border: none;
            border-radius: 20px;
            color: #fff;
            backdrop-filter: blur(15px);
            box-shadow: 0 0 30px rgba(108, 99, 255, 0.3);
        }

        .modal-header-glass {
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .modal-footer-glass {
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

        .form-control-glass {
            background-color: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: #fff;
            border-radius: 10px;
            padding: 12px 15px;
            transition: all 0.3s ease;
        }

        .form-control-glass:focus {
            background-color: rgba(255, 255, 255, 0.2);
            border-color: #6c63ff;
            color: #fff;
            box-shadow: 0 0 0 0.25rem rgba(108, 99, 255, 0.25);
        }

        .form-label {
            font-weight: 500;
            margin-bottom: 8px;
            color: #ddd;
        }

        .password-toggle {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #aaa;
        }

        .password-toggle:hover {
            color: #6c63ff;
        }

        .password-container {
            position: relative;
        }
    </style>
</head>
<body>
<div class="wrapper">
    <!-- Sidebar -->
    <div class="sidebar">
        <h2>📊 Dashboard</h2>
        <a href="home.jsp">🏠 Home</a>
        <a href="DataRegister.jsp">📁 Data Register</a>
        <a href="DataBarang.jsp">📦 Data Barang</a>
        <a href="DataPesanan.jsp">🗃️ Data Pesanan</a>
        <a href="logout.jsp">🚪 Logout</a>
    </div>

    <!-- Content Area -->
    <div class="content">
        <div class="card-glass">
            <h3>👋 Welcome Back, <%= loggedUser %>!</h3>
            <p><strong>Email:</strong> <%= email %></p>
            <button type="button" class="btn btn-custom mt-3" data-bs-toggle="modal" data-bs-target="#editProfileModal">
                Edit Profile
            </button>
        </div>

        <div class="card-glass">
            <h3>📨 Help contact</h3>
            <p>Need help? Contact our support team.</p>
            <a href="mailto:support@dripmoorizz.com" class="btn btn-custom mt-3">Contact Support</a>
        </div>
    </div>
</div>

<!-- Footer -->
<footer>
    &copy; 2025 DripmooRizz
</footer>

<!-- Edit Profile Modal -->
<div class="modal fade modal-glass" id="editProfileModal" tabindex="-1" aria-labelledby="editProfileModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content modal-content-glass">
            <div class="modal-header modal-header-glass">
                <h5 class="modal-title" id="editProfileModalLabel">✏️ Edit Profil</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="UpdateProfileServlet" method="post">
                <div class="modal-body">
                    <input type="hidden" name="id" value="<%= id %>">
                    
                    <div class="mb-4">
                        <label for="nama" class="form-label">Full Name</label>
                        <input type="text" class="form-control form-control-glass" id="nama" name="nama" value="<%= loggedUser %>" required>
                    </div>
                    
                    <div class="mb-4">
                        <label for="email" class="form-label">Email</label>
                        <input type="email" class="form-control form-control-glass" id="email" name="email" value="<%= email %>" required>
                    </div>
                    
                    <div class="mb-4 password-container">
                        <label for="password" class="form-label">Password</label>
                        <input type="password" class="form-control form-control-glass" id="password" name="password" value="<%= password %>" required>
                        <i class="password-toggle fas fa-eye" onclick="togglePassword()"></i>
                    </div>
                    
                    <div class="form-text text-muted">
                        Make sure the data you enter is valid and correct.
                    </div>
                </div>
                <div class="modal-footer modal-footer-glass d-flex justify-content-between">
                    <button type="button" class="btn btn-danger" onclick="confirmDeleteAccount('<%= id %>', '<%= loggedUser %>')">
                        <i class="fas fa-trash-alt"></i> Delete Account
                    </button>
                    <div>
                        <button type="button" class="btn btn-secondary me-2" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-custom">Save</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // Add this function to handle account deletion
    function confirmDeleteAccount(id, nama) {
        Swal.fire({
            title: 'HAPUS AKUN ANDA?',
            html: `<p>Anda akan menghapus akun <strong>${nama}</strong> secara permanen!</p>
                  <p class="text-danger">Setelah dihapus, semua data akan hilang dan Anda akan otomatis logout.</p>`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#dc3545',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Ya, Hapus Akun Saya',
            cancelButtonText: 'Batal',
            reverseButtons: true,
            focusCancel: true
        }).then((result) => {
            if (result.isConfirmed) {
                // Submit deletion form
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'DataRegister.jsp'; // Same as your delete handler
                
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'delete_id';
                input.value = id;
                
                form.appendChild(input);
                document.body.appendChild(form);
                form.submit();
            }
        });
    }

    // Password toggle function (existing)
    function togglePassword() {
        const passwordField = document.getElementById('password');
        const toggleIcon = document.querySelector('.password-toggle');
        
        if (passwordField.type === 'password') {
            passwordField.type = 'text';
            toggleIcon.classList.remove('fa-eye');
            toggleIcon.classList.add('fa-eye-slash');
        } else {
            passwordField.type = 'password';
            toggleIcon.classList.remove('fa-eye-slash');
            toggleIcon.classList.add('fa-eye');
        }
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>

<script>
    // Password toggle function
    function togglePassword() {
        const passwordField = document.getElementById('password');
        const toggleIcon = document.querySelector('.password-toggle');
        
        if (passwordField.type === 'password') {
            passwordField.type = 'text';
            toggleIcon.classList.remove('fa-eye');
            toggleIcon.classList.add('fa-eye-slash');
        } else {
            passwordField.type = 'password';
            toggleIcon.classList.remove('fa-eye-slash');
            toggleIcon.classList.add('fa-eye');
        }
    }
</script>

<%-- SweetAlert for update status --%>
<%
    String updateStatus = (String) session.getAttribute("updateStatus");
    if (updateStatus != null) {
        session.removeAttribute("updateStatus");
%>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        Swal.fire({
            title: "Berhasil!",
            text: "<%= updateStatus.replace("\"", "\\\"") %>",
            icon: "success",
            confirmButtonText: "OK"
        });
    });
</script>
<% } %>
</body>
</html>