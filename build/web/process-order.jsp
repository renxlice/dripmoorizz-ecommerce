<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
String notifStatus = null;
String notifMessage = null;
String notifType = null;

List<Map<String, Object>> cart = (List<Map<String, Object>>) session.getAttribute("cart");
double totalPrice = 0;

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String namaPembeli = (String) session.getAttribute("nama");
    String phone = request.getParameter("phone");
    String address = request.getParameter("address");
    String shipping = request.getParameter("shipping");
    String payment = request.getParameter("payment");

    boolean success = false;
    String pesan = "";
    String tipe = "";

    if (cart != null && !cart.isEmpty() && namaPembeli != null
        && phone != null && address != null && shipping != null && payment != null) {

        Connection conn = null;
        PreparedStatement psPesanan = null;
        PreparedStatement psDetail = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true", "root", "root");
            conn.setAutoCommit(false);

            double total = 0;
            for (Map<String, Object> item : cart) {
                int qty = (Integer) item.get("qty");
                double harga = (Double) item.get("harga");
                total += harga * qty;
            }

            String sqlPesanan = "INSERT INTO data_pesanan (nama_pembeli, telepon, alamat, metode_pengiriman, metode_pembayaran, total_harga, tanggal_pesanan, status) VALUES (?, ?, ?, ?, ?, ?, NOW(), 'Belum Dikonfirmasi')";
            psPesanan = conn.prepareStatement(sqlPesanan, Statement.RETURN_GENERATED_KEYS);
            psPesanan.setString(1, namaPembeli);
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
    <title>Proses Pesanan</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>
<% if (notifMessage != null && notifType != null) { %>
<script>
    Swal.fire({
        title: "<%= notifStatus.equals("success") ? "Berhasil" : "Gagal" %>",
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
