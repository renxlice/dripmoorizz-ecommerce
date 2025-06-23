<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, jakarta.servlet.http.*" %>

<%
    String loggedUser = (String) session.getAttribute("nama");
    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Map<String, Object>> cart = (List<Map<String, Object>>) session.getAttribute("cart");
    if (cart == null || cart.isEmpty()) {
        response.sendRedirect("cart.jsp");
        return;
    }

    double totalPrice = 0;
    String status = request.getParameter("status");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Checkout - DripmooRizz</title>
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
            <div class="card-header">Summary Of Your Shopping</div>
            <div class="card-body">
                <table class="table align-middle">
                    <thead>
                    <tr>
                        <th>Image</th>
                        <th>Product Name</th>
                        <th>Qty</th>
                        <th>Price</th>
                        <th>Subtotal</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        for (Map<String, Object> item : cart) {
                            int qty = (item.get("qty") instanceof Integer) ? (Integer) item.get("qty") : Integer.parseInt(item.get("qty").toString());
                            double harga = (item.get("harga") instanceof Double) ? (Double) item.get("harga") : Double.parseDouble(item.get("harga").toString());
                            double subtotal = harga * qty;
                            totalPrice += subtotal;

                            String nama = item.get("nama").toString();
                            String gambar = item.get("gambar").toString();
                    %>
                    <tr>
                        <td><img src="images/<%= gambar %>" class="product-img"></td>
                        <td><%= nama %></td>
                        <td><%= qty %></td>
                        <td>Rp <%= String.format("%,.0f", harga) %></td>
                        <td>Rp <%= String.format("%,.0f", subtotal) %></td>
                    </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
                <div class="text-end fs-5 mt-3">
                    <strong>Total: Rp <%= String.format("%,.0f", totalPrice) %></strong>
                </div>
            </div>
        </div>

        <!-- Form Checkout -->
        <h4 class="mb-3">Shipping & Payment Information</h4>
        <form action="process-order.jsp" method="post">
            <div class="row">
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="fullName" class="form-label">Full Name</label>
                        <input type="text" class="form-control" id="fullName" name="fullName" required>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="phone" class="form-label">Phone Number</label>
                        <input type="tel" class="form-control" id="phone" name="phone" required>
                    </div>
                </div>
            </div>

            <div class="mb-3">
                <label for="address" class="form-label">Address</label>
                <textarea class="form-control" id="address" name="address" rows="3" required></textarea>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="shipping" class="form-label">Shipping method</label>
                        <select class="form-select" id="shipping" name="shipping" required>
                            <option value="">-- Select Shipping --</option>
                            <option value="JNE">JNE</option>
                            <option value="J&T">J&T</option>
                            <option value="SiCepat">SiCepat</option>
                        </select>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="mb-3">
                        <label for="payment" class="form-label">Payment Method</label>
                        <select class="form-select" id="payment" name="payment" required>
                            <option value="">-- Select Payment --</option>
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
                <a href="cart.jsp" class="btn btn-outline-secondary">Back To Cart</a>
                <button type="submit" class="btn btn-success">Make an Order</button>
            </div>
        </form>
    </div>
</div>

<!-- SweetAlert2 Pop-up -->
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const status = "<%= status != null ? status : "" %>";

        if (status === "success") {
            Swal.fire({
                icon: 'success',
                title: 'Pesanan Berhasil Dibuat!',
                text: 'Terima kasih telah berbelanja di DripmooRizz.',
                confirmButtonColor: '#6c63ff'
            });
        } else if (status === "failed") {
            Swal.fire({
                icon: 'error',
                title: 'Gagal Membuat Pesanan',
                text: 'Silakan coba lagi atau hubungi admin.',
                confirmButtonColor: '#6c63ff'
            });
        }

        // Hapus parameter dari URL setelah popup
        if (status !== "") {
            window.history.replaceState({}, document.title, window.location.pathname);
        }
    });
</script>

</body>
</html>
