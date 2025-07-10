<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    String loggedUser = (String) session.getAttribute("nama");
    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String id_barang = request.getParameter("id");
    if (id_barang == null) {
        response.sendRedirect("DataBarang.jsp");
        return;
    }

    String nama_barang = "";
    String keterangan = "";
    String kategori = "";
    int harga = 0;
    int stok = 0;
    String gambar = "";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true", "root", "root");
        ps = conn.prepareStatement("SELECT * FROM data_barang WHERE id_barang = ?");
        ps.setString(1, id_barang);
        rs = ps.executeQuery();

        if (rs.next()) {
            nama_barang = rs.getString("nama_barang");
            keterangan = rs.getString("keterangan");
            kategori = rs.getString("kategori");
            harga = rs.getInt("harga");
            stok = rs.getInt("stok");
            gambar = rs.getString("gambar");
        } else {
            response.sendRedirect("DataBarang.jsp");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Barang | DripmooRizz</title>
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
        }
        
        .form-control:focus, .form-select:focus {
            background-color: white;
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
            color: white;
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
            color: white;
            transform: translateY(-2px);
        }
        
        .current-img {
            max-width: 200px;
            max-height: 200px;
            border-radius: 10px;
            margin-top: 10px;
        }
        
        .preview-img {
            max-width: 200px;
            max-height: 200px;
            border-radius: 10px;
            margin-top: 10px;
            display: none;
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
            <h3 class="mb-0">✏️ Edit Barang</h3>
            <a href="DataBarang.jsp" class="btn btn-cancel">✖ Batal</a>
        </div>
        
        <form action="proses-edit-barang" method="post" enctype="multipart/form-data">
            <input type="hidden" name="id_barang" value="<%= id_barang %>">
            
            <div class="row mb-4">
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="nama_barang" class="form-label">Nama Barang</label>
                        <input type="text" class="form-control" id="nama_barang" name="nama_barang" value="<%= nama_barang %>" required>
                    </div>
                    
                    <div class="mb-3">
                        <label for="keterangan" class="form-label">Keterangan</label>
                        <textarea class="form-control" id="keterangan" name="keterangan" rows="3" required><%= keterangan %></textarea>
                    </div>
                    
                    <div class="mb-3">
                        <label for="kategori" class="form-label">Kategori</label>
                        <select class="form-select" id="kategori" name="kategori" required>
                            <option value="Premium Milk" <%= kategori.equals("Premium Milk") ? "selected" : "" %>>Premium Milk</option>
                            <option value="Flavored Drinks" <%= kategori.equals("Flavored Drinks") ? "selected" : "" %>>Flavored Drinks</option>
                            <option value="Milk Alternatives" <%= kategori.equals("Milk Alternatives") ? "selected" : "" %>>Milk Alternatives</option>
                            <option value="Merchandise" <%= kategori.equals("Merchandise") ? "selected" : "" %>>Merchandise</option>
                        </select>
                    </div>
                </div>
                
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="harga" class="form-label">Harga</label>
                        <input type="number" class="form-control" id="harga" name="harga" min="0" value="<%= harga %>" required>
                    </div>
                    
                    <div class="mb-3">
                        <label for="stok" class="form-label">Stok</label>
                        <input type="number" class="form-control" id="stok" name="stok" min="0" value="<%= stok %>" required>
                    </div>
                    
                    <div class="mb-3">
                        <label for="gambar" class="form-label">Gambar Produk</label>
                        <p class="text-muted">Gambar saat ini:</p>
                        <img src="<%= gambar %>" alt="Current Image" class="current-img">
                        <p class="text-muted mt-2">Ubah gambar (opsional):</p>
                        <input type="file" class="form-control" id="gambar" name="gambar" accept="image/*">
                        <img id="preview" class="preview-img" src="#" alt="Preview Gambar">
                    </div>
                </div>
            </div>
            
            <div class="d-flex justify-content-end gap-3">
                <button type="reset" class="btn btn-cancel">🔄 Reset</button>
                <button type="submit" class="btn btn-submit">💾 Simpan Perubahan</button>
            </div>
        </form>
    </div>
</div>

<script>
    // Preview gambar sebelum upload
    document.getElementById('gambar').addEventListener('change', function(e) {
        const preview = document.getElementById('preview');
        const file = e.target.files[0];
        const reader = new FileReader();
        
        reader.onload = function(e) {
            preview.src = e.target.result;
            preview.style.display = 'block';
        }
        
        if (file) {
            reader.readAsDataURL(file);
        }
    });
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>