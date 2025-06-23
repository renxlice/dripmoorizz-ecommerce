<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
String notifStatus = null;
String notifMessage = null;
String notifType = null;

// Ambil cart dari session untuk tampilan ringkasan belanja
List<Map<String, Object>> cart = (List<Map<String, Object>>) session.getAttribute("cart");
double totalPrice = 0;

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String fullName = request.getParameter("fullName");
    String phone = request.getParameter("phone");
    String address = request.getParameter("address");
    String shipping = request.getParameter("shipping");
    String payment = request.getParameter("payment");
    String namaPemesan = (String) session.getAttribute("nama");

    boolean success = false;
    String pesan = "";
    String tipe = "";

    if (cart != null && !cart.isEmpty() && namaPemesan != null
        && fullName != null && phone != null && address != null
        && shipping != null && payment != null) {

        Connection conn = null;
        PreparedStatement psPesanan = null;
        PreparedStatement psDetail = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:8889/tb1?useSSL=false", "root", "root");
            conn.setAutoCommit(false);

            double total = 0;
            for (Map<String, Object> item : cart) {
                int qty = (Integer) item.get("qty");
                double harga = (Double) item.get("harga");
                total += harga * qty;
            }

            String sqlPesanan = "INSERT INTO data_pesanan (nama_pembeli, telepon, alamat, metode_pengiriman, metode_pembayaran, total_harga, tanggal_pesanan) VALUES (?, ?, ?, ?, ?, ?, NOW())";
            psPesanan = conn.prepareStatement(sqlPesanan, Statement.RETURN_GENERATED_KEYS);
            psPesanan.setString(1, fullName);
            psPesanan.setString(2, phone);
            psPesanan.setString(3, address);
            psPesanan.setString(4, shipping);
            psPesanan.setString(5, payment);
            psPesanan.setDouble(6, total);
            psPesanan.executeUpdate();

            rs = psPesanan.getGeneratedKeys();
            int idPesanan = rs.next() ? rs.getInt(1) : 0;

            String sqlDetail = "INSERT INTO detail_pesanan (id_pesanan, id_barang, nama_barang, gambar, qty, subtotal) VALUES (?, ?, ?, ?, ?, ?)";
            psDetail = conn.prepareStatement(sqlDetail);

            for (Map<String, Object> item : cart) {
                int qty = (Integer) item.get("qty");
                double harga = (Double) item.get("harga");
                double subtotal = harga * qty;

                psDetail.setInt(1, idPesanan);
                psDetail.setString(2, item.get("id").toString());
                psDetail.setString(3, item.get("nama").toString());
                psDetail.setString(4, item.get("gambar").toString());
                psDetail.setInt(5, qty);
                psDetail.setDouble(6, subtotal);
                psDetail.addBatch();
            }
            psDetail.executeBatch();
            conn.commit();

            session.removeAttribute("cart");
            session.setAttribute("cartItems", 0);

            success = true;
            pesan = "Pesanan berhasil dibuat!";
            tipe = "success";
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception ignore) {}
            pesan = "Gagal membuat pesanan: " + e.getMessage().replace("\"", "\\\"");
            tipe = "error";
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ignore) {}
            if (psPesanan != null) try { psPesanan.close(); } catch (Exception ignore) {}
            if (psDetail != null) try { psDetail.close(); } catch (Exception ignore) {}
            if (conn != null) try { conn.close(); } catch (Exception ignore) {}
        }

    } else {
        pesan = "Keranjang kosong atau data belum lengkap!";
        tipe = "warning";
    }

    notifStatus = success ? "success" : "failed";
    notifMessage = pesan;
    notifType = tipe;
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Checkout</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        :root {
            --primary-color: #6c63ff;
            --secondary-color: #574b90;
            --light-color: #ffffff;
            --dark-color: #333;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #e0c3fc, #8ec5fc);
            color: var(--dark-color);
            min-height: 100vh;
            padding: 20px;
        }

        h2, h4 {
            font-weight: 700;
            color: var(--primary-color);
        }

        .glass-card {
            background: rgba(255, 255, 255, 0.6);
            border-radius: 15px;
            box-shadow: 0 8px 32px rgba(31, 38, 135, 0.15);
            backdrop-filter: blur(10px);
            padding: 30px;
        }

        .btn-outline-secondary,
        .btn-success {
            border-radius: 10px;
            font-weight: 600;
        }

        .btn-success {
            background-color: var(--primary-color);
            border: none;
        }

        .btn-success:hover {
            background-color: var(--secondary-color);
        }

        .product-img {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 6px;
        }

        .card-header {
            background-color: var(--primary-color);
            color: white;
            font-weight: 600;
        }
    </style>
</head>
<body>
<div class="container my-5">
    <div class="glass-card">
        <h2 class="mb-4">Checkout</h2>

        <!-- Ringkasan Belanja -->
        <div class="card mb-4">
            <div class="card-header">Ringkasan Belanja Anda</div>
            <div class="card-body">
                <table class="table align-middle">
                    <thead>
                    <tr>
                        <th>Gambar</th>
                        <th>Nama Produk</th>
                        <th>Jumlah</th>
                        <th>Harga</th>
                        <th>Subtotal</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                    if (cart != null && !cart.isEmpty()) {
                        for (Map<String, Object> item : cart) {
                            int qty = (item.get("qty") instanceof Integer) ? (Integer) item.get("qty") : Integer.parseInt(item.get("qty").toString());
                            double harga = (item.get("harga") instanceof Double) ? (Double) item.get("harga") : Double.parseDouble(item.get("harga").toString());
                            double subtotal = harga * qty;
                            totalPrice += subtotal;

                            String nama = item.get("nama").toString();
                            String gambar = item.get("gambar").toString();
                    %>
                    <tr>
                        <td><img src="images/<%= gambar %>" class="product-img" alt="<%= nama %>"></td>
                        <td><%= nama %></td>
                        <td><%= qty %></td>
                        <td>Rp <%= String.format("%,.0f", harga) %></td>
                        <td>Rp <%= String.format("%,.0f", subtotal) %></td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="5" class="text-center">Keranjang belanja kosong.</td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                <div class="text-end fs-5 mt-3">
                    <strong>Total: Rp <%= String.format("%,.0f", totalPrice) %></strong>
                </div>
            </div>
        </div>

        <!-- Form Checkout -->
        <h4 class="mb-3">Informasi Pengiriman & Pembayaran</h4>
        <form action="checkout.jsp" method="post">
            <div class="row">
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="fullName" class="form-label">Nama Lengkap</label>
                        <input type="text" class="form-control" id="fullName" name="fullName" required>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="phone" class="form-label">Nomor HP</label>
                        <input type="tel" class="form-control" id="phone" name="phone" required>
                    </div>
                </div>
            </div>

            <div class="mb-3">
                <label for="address" class="form-label">Alamat Lengkap</label>
                <textarea class="form-control" id="address" name="address" rows="3" required></textarea>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="shipping" class="form-label">Metode Pengiriman</label>
                        <select class="form-select" id="shipping" name="shipping" required>
                            <option value="">-- Pilih Pengiriman --</option>
                            <option value="JNE">JNE</option>
                            <option value="J&T">J&T</option>
                            <option value="SiCepat">SiCepat</option>
                        </select>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="payment" class="form-label">Metode Pembayaran</label>
                        <select class="form-select" id="payment" name="payment" required>
                            <option value="">-- Pilih Pembayaran --</option>
                            <option value="BCA">BCA Transfer</option>
                            <option value="Mandiri">Mandiri Transfer</option>
                            <option value="BNI">BNI Transfer</option>
                            <option value="OVO">OVO</option>
                            <option value="GoPay">GoPay</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="d-flex justify-content-between mt-4">
                <a href="cart.jsp" class="btn btn-outline-secondary">Kembali ke Keranjang</a>
                <button type="submit" class="btn btn-success">Buat Pesanan</button>
            </div>
        </form>
    </div>
</div>

<% if (notifMessage != null && notifType != null) { %>
<script>
    Swal.fire({
        title: "<%= notifStatus.equals("success") ? "Success" : "Failed" %>",
        text: "<%= notifMessage %>",
        icon: "<%= notifType %>",
        confirmButtonColor: '#3085d6',
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = "home.jsp";
        }
    });
</script>
<% } %>

</body>
</html>
