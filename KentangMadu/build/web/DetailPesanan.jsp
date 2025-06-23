<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat, java.util.Locale" %>

<%
    String idPesanan = request.getParameter("id");
    if (idPesanan == null || idPesanan.trim().isEmpty()) {
        out.println("<p class='text-danger'>ID Pesanan tidak diberikan.</p>");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    List<Map<String, Object>> detailPesanan = new ArrayList<>();

    String dbURL = "jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true";
    String dbUser = "root";
    String dbPass = "root";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        String sql = "SELECT d.id_detail, d.id_pesanan, d.id_barang, d.nama_barang, d.gambar, d.qty, d.subtotal, b.harga " +
                     "FROM detail_pesanan d " +
                     "JOIN data_barang b ON d.id_barang = b.id_barang " +
                     "WHERE d.id_pesanan = ?";

        ps = conn.prepareStatement(sql);
        ps.setString(1, idPesanan);
        rs = ps.executeQuery();

        while (rs.next()) {
            Map<String, Object> row = new HashMap<>();
            row.put("id_detail", rs.getInt("id_detail"));
            row.put("id_pesanan", rs.getInt("id_pesanan"));
            row.put("id_barang", rs.getInt("id_barang"));
            row.put("nama_barang", rs.getString("nama_barang"));
            row.put("gambar", rs.getString("gambar"));
            row.put("qty", rs.getInt("qty"));
            row.put("subtotal", rs.getLong("subtotal"));
            row.put("harga", rs.getLong("harga"));
            detailPesanan.add(row);
        }
    } catch (Exception e) {
        out.println("<p class='text-danger'>Terjadi kesalahan: " + e.getMessage() + "</p>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8" />
    <title>Detail Pesanan | DripmooRizz</title>
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

        .btn-back {
            background-color: #6c757d;
            color: white;
            border-radius: 10px;
            font-weight: 500;
            padding: 8px 18px;
            border: none;
        }

        .btn-back:hover {
            background-color: #5a6268;
        }

        img.product-img {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 10px;
            border: 2px solid #ddd;
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
        <h3 class="mb-4">📦 Detail Pesanan ID: <%= idPesanan %></h3>
        <table class="table table-bordered table-hover shadow-sm">
            <thead class="text-center">
                <tr>
                    <th>Gambar</th>
                    <th>Nama Barang</th>
                    <th>Harga</th>
                    <th>Jumlah</th>
                    <th>Subtotal</th>
                </tr>
            </thead>
            <tbody>
                <%
                    NumberFormat formatter = NumberFormat.getInstance(new Locale("id", "ID"));
                    if (!detailPesanan.isEmpty()) {
                        for (Map<String, Object> d : detailPesanan) {
                %>
                <tr>
                    <td class="text-center">
                        <img src="images/<%= d.get("gambar") %>" alt="barang" class="product-img" />
                    </td>
                    <td class="text-center"><%= d.get("nama_barang") %></td>
                    <td class="text-center">Rp <%= formatter.format(d.get("harga")) %></td>
                    <td class="text-center"><%= d.get("qty") %></td>
                    <td class="text-center">Rp <%= formatter.format(d.get("subtotal")) %></td>
                </tr>
                <%
                        }
                    } else {
                %>
                <tr>
                    <td colspan="5" class="text-center text-danger">Detail pesanan tidak ditemukan.</td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <div class="text-end mt-3">
            <a href="DataPesanan.jsp" class="btn btn-back">⬅ Kembali</a>
        </div>
    </div>
</div>
</body>
</html>
