<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
String loggedUser = (String) session.getAttribute("nama");
if (loggedUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

String deleteStatus = null;
if ("POST".equalsIgnoreCase(request.getMethod())) {
    if (request.getParameter("delete_id") != null) {
        Connection connDel = null;
        PreparedStatement psDel = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connDel = DriverManager.getConnection("jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true", "root", "root");
            psDel = connDel.prepareStatement("DELETE FROM data_barang WHERE id_barang = ?");
            psDel.setString(1, request.getParameter("delete_id"));
            int result = psDel.executeUpdate();
            deleteStatus = (result > 0) ? "success" : "fail";
        } catch (Exception e) {
            deleteStatus = "error";
            e.printStackTrace();
        } finally {
            if (psDel != null) try { psDel.close(); } catch (Exception e) {}
            if (connDel != null) try { connDel.close(); } catch (Exception e) {}
        }
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Data Barang | DripmooRizz</title>
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

    .btn-add {
        background-color: #28a745;
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

    .btn-add:hover {
        background-color: #218838;
    }

    .action-buttons {
        display: flex;
        gap: 6px;
    }
    
    .product-img {
        width: 80px;
        height: 80px;
        object-fit: cover;
        border-radius: 8px;
    }
    
    .price-cell {
        font-weight: 600;
        color: #28a745;
    }
    
    .stock-cell {
        font-weight: 500;
    }
    
    .in-stock {
        color: #28a745;
    }
    
    .out-of-stock {
        color: #dc3545;
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
            <h3 class="mb-0">📦 Data Barang</h3>
            <button class="btn btn-add btn-sm" data-bs-toggle="modal" data-bs-target="#modalTambahBarang">➕ Tambah Barang</button>
        </div>
        <table class="table table-bordered table-hover shadow-sm">
            <thead>
                <tr>
                    <th>No</th>
                    <th>Gambar</th>
                    <th>Nama Barang</th>
                    <th>Keterangan</th>
                    <th>Kategori</th>
                    <th>Harga</th>
                    <th>Stok</th>
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
                    rs = stmt.executeQuery("SELECT * FROM data_barang");
                    while (rs.next()) {
                        String idBarang = rs.getString("id_barang");
                        String namaBarang = rs.getString("nama_barang").replace("'", "\\'");
                        String keterangan = rs.getString("keterangan").replace("'", "\\'");
                        String kategori = rs.getString("kategori").replace("'", "\\'");
                        int harga = rs.getInt("harga");
                        int stok = rs.getInt("stok");
                        String gambar = rs.getString("gambar").replace("'", "\\'");
                %>
                <tr>
                <td><%= no++ %></td>
                <td><img src="images/<%= gambar %>" class="product-img"></td>
                <td><%= namaBarang %></td>
                <td><%= keterangan %></td>
                <td><%= kategori %></td>
                <td>Rp <%= harga %></td>
                <td><%= stok %></td>
                <td>
                    <div class="action-buttons">
                        <button class="btn btn-edit btn-sm"
                            onclick="editBarang('<%= idBarang %>', '<%= namaBarang %>', '<%= keterangan %>', '<%= kategori %>', <%= harga %>, <%= stok %>, '<%= gambar %>')"
                            data-bs-toggle="modal" data-bs-target="#modalEditBarang">Edit</button>
                        <form method="post" onsubmit="return confirmDelete(event, '<%= idBarang %>')" style="margin: 0;">
                            <input type="hidden" name="delete_id" id="delete_id_<%= idBarang %>" value="<%= idBarang %>">
                            <button type="submit" class="btn btn-delete btn-sm">Delete</button>
                        </form>
                    </div>
                </td>
            </tr>
                <% } } catch (Exception e) { out.println("<tr><td colspan='8'>Error: " + e.getMessage() + "</td></tr>"); } finally {
                    if (rs != null) try { rs.close(); } catch (Exception e) {}
                    if (stmt != null) try { stmt.close(); } catch (Exception e) {}
                    if (conn != null) try { conn.close(); } catch (Exception e) {}
                } %>
            </tbody>
        </table>
    </div>
</div>

<!-- Modal Tambah Barang -->
<div class="modal fade" id="modalTambahBarang" tabindex="-1" aria-labelledby="modalTambahBarangLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content text-dark" style="border-radius: 20px; backdrop-filter: blur(10px);">
      <div class="modal-header bg-success text-white">
        <h5 class="modal-title" id="modalTambahBarangLabel">➕ Tambah Barang</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <form action="proses-tambah-barang" method="post" enctype="multipart/form-data">
        <div class="modal-body p-4">
          <div class="mb-3">
            <label class="form-label">Nama Barang</label>
            <input type="text" class="form-control" name="nama_barang" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Keterangan</label>
            <textarea class="form-control" name="keterangan" rows="2" required></textarea>
          </div>
          <div class="mb-3">
        <label class="form-label">Kategori</label>
        <select class="form-select" name="kategori" required>
            <option value="">Pilih Kategori</option>
            <option value="Premium Milk">Premium Milk</option>
            <option value="Flavored Drinks">Flavored Drinks</option>
            <option value="Milk Alternatives">Milk Alternatives</option>
            <option value="Merchandise">Merchandise</option>
        </select>
        </div>
          <div class="mb-3">
            <label class="form-label">Harga</label>
            <input type="number" class="form-control" name="harga" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Stok</label>
            <input type="number" class="form-control" name="stok" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Gambar</label>
            <input type="file" class="form-control" name="gambar" accept="image/*" required>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
          <button type="submit" class="btn btn-success">Simpan</button>
        </div>
      </form>
    </div>
  </div>
</div>


<!-- Modal Edit Barang -->
<div class="modal fade" id="modalEditBarang" tabindex="-1" aria-labelledby="modalEditBarangLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content text-dark" style="border-radius: 20px; backdrop-filter: blur(10px);">
      <div class="modal-header bg-warning text-dark">
        <h5 class="modal-title" id="modalEditBarangLabel">✏️ Edit Barang</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <form action="proses-edit-barang" method="post" enctype="multipart/form-data">
        <input type="hidden" name="id_barang" id="edit-id">
        <div class="modal-body p-4">
          <div class="mb-3">
            <label class="form-label">Nama Barang</label>
            <input type="text" class="form-control" name="nama_barang" id="edit-nama" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Keterangan</label>
            <textarea class="form-control" name="keterangan" id="edit-keterangan" rows="2" required></textarea>
          </div>
          <div class="mb-3">
        <label class="form-label">Kategori</label>
        <select class="form-select" name="kategori" required>
            <option value="">Pilih Kategori</option>
            <option value="Premium Milk">Premium Milk</option>
            <option value="Flavored Drinks">Flavored Drinks</option>
            <option value="Milk Alternatives">Milk Alternatives</option>
            <option value="Merchandise">Merchandise</option>
        </select>
        </div>
          <div class="mb-3">
            <label class="form-label">Harga</label>
            <input type="number" class="form-control" name="harga" id="edit-harga" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Stok</label>
            <input type="number" class="form-control" name="stok" id="edit-stok" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Gambar Baru (jika ingin diganti)</label>
            <input type="file" class="form-control" name="gambar" accept="image/*">
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
          <button type="submit" class="btn btn-warning text-dark">Update</button>
        </div>
      </form>
    </div>
  </div>
</div>


<script>
    function confirmDelete(event, id) {
        event.preventDefault();
        Swal.fire({
            title: 'Yakin ingin menghapus?',
            text: "Data barang akan dihapus permanen!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#dc3545',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Ya, hapus!',
            cancelButtonText: 'Batal'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById("delete_id_" + id).form.submit();
            }
        });
        return false;
    }

    function editBarang(id, nama, keterangan, kategori, harga, stok, gambar) {
        document.getElementById('edit-id').value = id;
        document.getElementById('edit-nama').value = nama;
        document.getElementById('edit-keterangan').value = keterangan;
        document.getElementById('edit-kategori').value = kategori;
        document.getElementById('edit-harga').value = harga;
        document.getElementById('edit-stok').value = stok;
    }
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
