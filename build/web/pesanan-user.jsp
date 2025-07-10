<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String loggedUser = (String) session.getAttribute("nama");
    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Map<String, Object>> pesananList = new ArrayList<>();

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true", "root", "root");

        String sql = """
            SELECT dp.id_pesanan, dp.nama_pembeli, dp.total_harga, dp.tanggal_pesanan, dp.status,
                   dp.metode_pengiriman, dp.metode_pembayaran,
                   d.nama_barang, d.gambar
            FROM data_pesanan dp
            JOIN detail_pesanan d ON dp.id_pesanan = d.id_pesanan
            WHERE dp.nama_pembeli = ?
            ORDER BY dp.id_pesanan DESC
        """;

        ps = conn.prepareStatement(sql);
        ps.setString(1, loggedUser);
        rs = ps.executeQuery();

        while (rs.next()) {
            Map<String, Object> row = new HashMap<>();
            row.put("id_pesanan", rs.getInt("id_pesanan"));
            row.put("nama_pembeli", rs.getString("nama_pembeli"));
            row.put("total_harga", rs.getDouble("total_harga"));
            row.put("tanggal", rs.getTimestamp("tanggal_pesanan"));
            row.put("status", rs.getString("status"));
            row.put("metode_pengiriman", rs.getString("metode_pengiriman"));
            row.put("metode_pembayaran", rs.getString("metode_pembayaran"));
            row.put("nama_barang", rs.getString("nama_barang"));
            row.put("gambar", rs.getString("gambar"));
            pesananList.add(row);
        }

    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Terjadi kesalahan: " + e.getMessage() + "</div>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Status Pesanan Saya</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #6c63ff;
            --secondary-color: #574b90;
            --accent-color: #22d3ee;
            --light-color: #f8f9fa;
            --dark-color: #333;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #e0c3fc, #8ec5fc);
            color: var(--dark-color);
            min-height: 100vh;
            padding: 20px;
        }

        h2 {
            font-weight: 700;
            color: var(--primary-color);
        }

        .glass-card {
            background: rgba(255, 255, 255, 0.65);
            border-radius: 15px;
            box-shadow: 0 8px 32px rgba(31, 38, 135, 0.2);
            backdrop-filter: blur(12px);
            padding: 30px;
        }

        .product-img {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 10px;
            margin-right: 10px;
        }

        .btn-consistent {
            border-radius: 10px;
            font-weight: 600;
            padding: 10px 24px;
            font-size: 15px;
            min-width: 150px;
            text-align: center;
        }

        .btn-outline-secondary,
        .btn-danger,
        .btn-success {
            border-radius: 10px;
            font-weight: 600;
            padding: 8px 16px;
            font-size: 14px;
        }

        .btn-success {
            background-color: var(--primary-color);
            border: none;
            transition: background-color 0.3s ease;
        }

        .btn-success:hover {
            background-color: var(--secondary-color);
        }

        .table thead {
            background-color: var(--primary-color);
            color: white;
        }
    </style>
</head>
<body>
<div class="container glass-card">
    <h2 class="text-center mb-4">📦 Order History & Status</h2>

    <% if (pesananList.isEmpty()) { %>
        <div class="alert alert-info">No Orders Have Been Placed Yet.</div>
    <% } else { %>
        <div class="table-responsive">
        <table class="table table-bordered table-hover align-middle">
            <thead class="text-center">
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Product</th>
                    <th>Picture</th>
                    <th>Shipping</th>
                    <th>Payment</th>
                    <th>Date/Time</th>
                    <th>Total</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <% for (Map<String, Object> p : pesananList) { %>
                    <tr class="text-center">
                        <td><%= p.get("id_pesanan") %></td>
                        <td><%= p.get("nama_pembeli") %></td>
                        <td><%= p.get("nama_barang") %></td>
                        <td><img src="images/<%= p.get("gambar") %>" class="product-img" alt="gambar"></td>
                        <td><%= p.get("metode_pengiriman") %></td>
                        <td><%= p.get("metode_pembayaran") %></td>
                        <td><%= p.get("tanggal") %></td>
                        <td>Rp <%= String.format("%,.0f", p.get("total_harga")) %></td>
                        <td>
                            <% String status = (String)p.get("status"); %>
                            <% if ("Dikonfirmasi".equalsIgnoreCase(status)) { %>
                                <span class="badge bg-success">Confirmed</span>
                            <% } else { %>
                                <span class="badge bg-warning text-dark">Not Confirmed Yet</span>
                            <% } %>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
        </div>
    <% } %>

    <div class="text-end mt-4">
        <a href="home.jsp" class="btn btn-outline-secondary">⬅ Back To Home</a>
    </div>
</div>
</body>
</html>
