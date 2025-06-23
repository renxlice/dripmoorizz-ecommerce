<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.text.NumberFormat, java.util.Locale" %>
<%
String loggedUser = (String) session.getAttribute("nama");
if (loggedUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Database settings
String dbURL = "jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true";
String dbUser = "root";
String dbPass = "root";

// DELETE logic (via GET parameter)
String deleteId = request.getParameter("delete_id");
if (deleteId != null && !deleteId.trim().isEmpty()) {
    Connection delConn = null;
    PreparedStatement delDetail = null;
    PreparedStatement delPesanan = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        delConn = DriverManager.getConnection(dbURL, dbUser, dbPass);
        delConn.setAutoCommit(false);

        delDetail = delConn.prepareStatement("DELETE FROM detail_pesanan WHERE id_pesanan = ?");
        delDetail.setInt(1, Integer.parseInt(deleteId));
        delDetail.executeUpdate();

        delPesanan = delConn.prepareStatement("DELETE FROM data_pesanan WHERE id_pesanan = ?");
        delPesanan.setInt(1, Integer.parseInt(deleteId));
        delPesanan.executeUpdate();

        delConn.commit();
    } catch (Exception e) {
        if (delConn != null) delConn.rollback();
        out.println("<script>alert('Gagal menghapus data: " + e.getMessage() + "');</script>");
    } finally {
        if (delDetail != null) delDetail.close();
        if (delPesanan != null) delPesanan.close();
        if (delConn != null) delConn.close();
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Data Pesanan | DripmooRizz</title>
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

        .btn-detail {
            background-color: #0d6efd;
            color: white;
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

        .btn-detail:hover {
            background-color: #0b5ed7;
        }

        .btn-delete:hover {
            background-color: #bb2d3b;
        }

        .action-buttons {
            display: flex;
            gap: 6px;
            justify-content: center;
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
        <h3 class="mb-4">🗃️ Data Pesanan</h3>
        <table class="table table-bordered table-hover shadow-sm">
            <thead class="text-center">
                <tr>
                    <th>ID</th>
                    <th>Nama</th>
                    <th>Telepon</th>
                    <th>Alamat</th>
                    <th>Barang</th>
                    <th>Pengiriman</th>
                    <th>Pembayaran</th>
                    <th>Total</th>
                    <th>Tanggal</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
            <%
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;
                boolean hasData = false;
                NumberFormat formatter = NumberFormat.getInstance(new Locale("id", "ID"));
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                    stmt = conn.createStatement();
                    String sql = "SELECT p.id_pesanan, p.nama_pembeli, p.telepon, p.alamat, p.metode_pengiriman, p.metode_pembayaran, " +
                                 "p.total_harga, p.tanggal_pesanan, GROUP_CONCAT(b.nama_barang SEPARATOR ', ') AS daftar_barang " +
                                 "FROM data_pesanan p " +
                                 "LEFT JOIN detail_pesanan d ON p.id_pesanan = d.id_pesanan " +
                                 "LEFT JOIN data_barang b ON d.id_barang = b.id_barang " +
                                 "GROUP BY p.id_pesanan " +
                                 "ORDER BY p.tanggal_pesanan DESC";
                    rs = stmt.executeQuery(sql);
                    while (rs.next()) {
                        hasData = true;
                        String id = rs.getString("id_pesanan");
                        String nama = rs.getString("nama_pembeli");
                        String telepon = rs.getString("telepon");
                        String alamat = rs.getString("alamat");
                        String barang = rs.getString("daftar_barang");
                        String pengiriman = rs.getString("metode_pengiriman");
                        String pembayaran = rs.getString("metode_pembayaran");
                        long total = rs.getLong("total_harga");
                        String tanggal = rs.getString("tanggal_pesanan");
            %>
                <tr>
                    <td class="text-center"><%= id %></td>
                    <td><%= nama %></td>
                    <td class="text-center"><%= telepon %></td>
                    <td><%= alamat %></td>
                    <td><%= (barang != null) ? barang : "-" %></td>
                    <td class="text-center"><%= pengiriman %></td>
                    <td class="text-center"><%= pembayaran %></td>
                    <td class="text-end">Rp <%= formatter.format(total) %></td>
                    <td class="text-center"><%= tanggal %></td>
                    <td>
                        <div class="action-buttons">
                            <a href="DetailPesanan.jsp?id=<%= id %>" class="btn btn-detail btn-sm">Detail</a>
                            <button class="btn btn-delete btn-sm btn-hapus" data-id="<%= id %>">Delete</button>
                        </div>
                    </td>
                </tr>
            <%
                    }
                    if (!hasData) {
                        out.println("<tr><td colspan='10' class='text-center'>Tidak ada data pesanan.</td></tr>");
                    }
                } catch (Exception e) {
                    out.println("<tr><td colspan='10' class='text-danger'>Terjadi kesalahan: " + e.getMessage() + "</td></tr>");
                } finally {
                    try { if (rs != null) rs.close(); } catch (Exception e) {}
                    try { if (stmt != null) stmt.close(); } catch (Exception e) {}
                    try { if (conn != null) conn.close(); } catch (Exception e) {}
                }
            %>
            </tbody>
        </table>
    </div>
</div>

<script>
    document.querySelectorAll('.btn-hapus').forEach(function(button) {
        button.addEventListener('click', function() {
            const id = this.getAttribute('data-id');
            Swal.fire({
                title: 'Yakin ingin menghapus pesanan?',
                text: "Data ini tidak bisa dikembalikan setelah dihapus.",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Ya, hapus',
                cancelButtonText: 'Batal'
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = 'DataPesanan.jsp?delete_id=' + id;
                }
            });
        });
    });
</script>
</body>
</html>
