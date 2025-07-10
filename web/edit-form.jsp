<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String id = request.getParameter("id");
    String nama = request.getParameter("nama");
    String email = request.getParameter("email");
    String updateStatus = request.getParameter("edit");

    // Hindari nilai null di input field
    if (id == null) id = "";
    if (nama == null) nama = "";
    if (email == null) email = "";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Data User</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: url('images/Milk-Protein-Panel.jpg') no-repeat center center fixed;
            background-size: cover;
            min-height: 100vh;
            margin: 0;
        }

        .overlay {
            background: rgba(0, 0, 0, 0.6);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 40px 20px;
        }

        .card-form {
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            width: 100%;
            max-width: 500px;
            color: #fff;
            box-shadow: 0 12px 24px rgba(0,0,0,0.3);
        }

        .form-control {
            background-color: rgba(255, 255, 255, 0.9);
            border: none;
            border-radius: 12px;
            padding: 12px;
        }

        .form-label {
            font-weight: 600;
            color: #fff;
        }

        .btn-primary {
            background-color: #6c63ff;
            border: none;
            border-radius: 10px;
            padding: 10px 20px;
            font-weight: 600;
        }

        .btn-primary:hover {
            background-color: #574b90;
        }

        .btn-cancel {
            background-color: transparent;
            color: #fff;
            border: 2px solid #fff;
            border-radius: 10px;
            padding: 10px 20px;
            font-weight: 600;
        }

        .btn-cancel:hover {
            background-color: rgba(255, 255, 255, 0.2);
        }
    </style>
</head>
<body>
<div class="overlay">
    <div class="card-form">
        <h3 class="text-center mb-4">✏️ Edit Data User</h3>
        <form action="update-user.jsp" method="post">
            <input type="hidden" name="id" value="<%= id %>">

            <div class="mb-3">
                <label for="nama" class="form-label">Name</label>
                <input type="text" class="form-control" name="nama" id="nama" value="<%= nama %>" required>
            </div>

            <div class="mb-3">
                <label for="email" class="form-label">Email</label>
                <input type="email" class="form-control" name="email" id="email" value="<%= email %>" required>
            </div>

            <div class="mb-3">
                <label for="password" class="form-label">Password</label>
                <input type="password" class="form-control" name="password" id="password" placeholder="Masukkan password baru">
            </div>

            <div class="d-flex justify-content-between mt-4">
                <button type="submit" class="btn btn-primary">Save</button>
                <a href="DataRegister.jsp" class="btn btn-cancel">Cancel</a>
            </div>
        </form>
    </div>
</div>

<% if ("success".equals(updateStatus)) { %>
<script>
    window.onload = function() {
        Swal.fire({
            icon: 'success',
            title: 'Berhasil Diperbarui',
            text: 'Data pengguna berhasil disimpan.',
            timer: 2000,
            showConfirmButton: false
        });

        // Hapus parameter ?edit=success dari URL setelah ditampilkan
        const url = new URL(window.location.href);
        url.searchParams.delete("edit");
        window.history.replaceState(null, "", url.toString());
    };
</script>
<% } %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
