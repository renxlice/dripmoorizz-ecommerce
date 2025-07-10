<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String loggedUser = (String) session.getAttribute("nama");
    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tambah Barang | DripmooRizz</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
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
        .form-control, .form-select {
            background-color: rgba(255, 255, 255, 0.9);
            border: none;
            border-radius: 10px;
            padding: 12px 15px;
            color: #000;
        }
        .form-control:focus, .form-select:focus {
            background-color: #fff;
            box-shadow: 0 0 0 0.25rem rgba(108, 99, 255, 0.25);
        }
        .btn-submit {
            background-color: #6c63ff;
            color: white;
            border-radius: 10px;
            padding: 12px 30px;
            font-weight: 600;
            transition: all 0.3s ease;
            border: none;
        }
        .btn-submit:hover {
            background-color: #574b90;
            transform: translateY(-2px);
        }
        .btn-cancel {
            background-color: #dc3545;
            color: white;
            border-radius: 10px;
            padding: 12px 30px;
            font-weight: 600;
            transition: all 0.3s ease;
            border: none;
        }
        .btn-cancel:hover {
            background-color: #c82333;
            transform: translateY(-2px);
        }
        .preview-img {
            max-width: 200px;
            max-height: 200px;
            border-radius: 10px;
            margin-top: 10px;
            display: none;
            object-fit: cover;
        }
    </style>
</head>
<body>
<div class="sidebar">
    <h2><a href="dashboard.jsp" class="text-white text-decoration-none fw-bold">📊 Dashboard</a></h2>
    <a href="home.jsp">🏠 Home</a>
    <a href="DataRegister.jsp">📁 Data Register</a>
    <a href="DataBarang.jsp">📦 Data Barang</a>
    <a href="logout.jsp">🚪 Logout</a>
</div>

<div class="content">
    <div class="card-glass">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="mb-0">➕ Tambah Barang Baru</h3>
            <a href="DataBarang.jsp" class="btn btn-cancel">✖ Batal</a>
        </div>

        <form action="proses-tambah-barang" method="post" enctype="multipart/form-data">
            <div class="row mb-4">
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="nama_barang" class="form-label">Nama Barang</label>
                        <input type="text" class="form-control" id="nama_barang" name="nama_barang" required>
                    </div>
                    <div class="mb-3">
                        <label for="keterangan" class="form-label">Keterangan</label>
                        <textarea class="form-control" id="keterangan" name="keterangan" rows="3" required></textarea>
                    </div>
                    <div class="mb-3">
                        <label for="kategori" class="form-label">Kategori</label>
                        <select class="form-select" id="kategori" name="kategori" required>
                            <option value="">Pilih Kategori</option>
                            <option value="Premium Milk">Premium Milk</option>
                            <option value="Flavored Drinks">Flavored Drinks</option>
                            <option value="Milk Alternatives">Milk Alternatives</option>
                            <option value="Merchandise">Merchandise</option>
                        </select>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="harga" class="form-label">Harga</label>
                        <input type="number" class="form-control" id="harga" name="harga" min="0" step="0.01" required>
                    </div>
                    <div class="mb-3">
                        <label for="stok" class="form-label">Stok</label>
                        <input type="number" class="form-control" id="stok" name="stok" min="0" required>
                    </div>
                    <div class="mb-3">
                        <label for="gambar" class="form-label">Gambar Produk</label>
                        <input type="file" class="form-control" id="gambar" name="gambar" accept="image/*" required>
                        <img id="preview" class="preview-img" src="#" alt="Preview Gambar">
                    </div>
                </div>
            </div>

            <div class="d-flex justify-content-end gap-3">
                <button type="reset" class="btn btn-cancel">🔄 Reset</button>
                <button type="submit" class="btn btn-submit">💾 Simpan</button>
            </div>
        </form>
    </div>
</div>

<script>
    // Preview gambar
    document.getElementById('gambar').addEventListener('change', function(e) {
        const preview = document.getElementById('preview');
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(evt) {
                preview.src = evt.target.result;
                preview.style.display = 'block';
            }
            reader.readAsDataURL(file);
        }
    });
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
