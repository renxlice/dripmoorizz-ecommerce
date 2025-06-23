<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, jakarta.servlet.http.*, jakarta.servlet.*, java.sql.*" %>

<%
    String loggedUser = (String) session.getAttribute("nama");
    if (loggedUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Map<String, Object>> cart = (List<Map<String, Object>>) session.getAttribute("cart");
    if (cart == null) {
        cart = new ArrayList<>();
        session.setAttribute("cart", cart);
    }

    double grandTotal = 0;
%>

<!DOCTYPE html>
<html>
<head>
    <title>Cart - DripmooRizz</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
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
    </style>
</head>
<body>

<div class="container my-5">
    <div class="glass-card animate-fade-in">
        <h2 class="mb-4">Cart</h2>

        <div class="table-responsive">
            <table class="table align-middle table-bordered bg-white rounded">
                <thead class="table-dark text-center">
                    <tr>
                        <th>Product</th>
                        <th>Price</th>
                        <th>Qty</th>
                        <th>Total</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <% if (!cart.isEmpty()) {
                    for (Map<String, Object> item : cart) {
                        String nama = (String) item.get("nama");
                        String gambar = (String) item.get("gambar");

                        int qty = item.get("qty") instanceof Integer ? (Integer) item.get("qty") : Integer.parseInt((String) item.get("qty"));
                        double harga = item.get("harga") instanceof Double ? (Double) item.get("harga") : Double.parseDouble((String) item.get("harga"));
                        int id = item.get("id") instanceof Integer ? (Integer) item.get("id") : Integer.parseInt((String) item.get("id"));

                        double subtotal = qty * harga;
                        grandTotal += subtotal;
                %>
                    <tr>
                        <td>
                            <div class="d-flex align-items-center">
                                <img src="images/<%= gambar %>" class="product-img">
                                <span><%= nama %></span>
                            </div>
                        </td>
                        <td class="text-center">Rp <%= String.format("%,.0f", harga) %></td>
                        <td class="text-center">
                            <div class="input-group mx-auto" style="width: 120px;">
                                <a href="add-to-cart?action=decrease&id=<%= id %>" class="btn btn-outline-secondary">-</a>
                                <input type="text" class="form-control text-center" value="<%= qty %>" readonly>
                                <a href="add-to-cart?id=<%= id %>" class="btn btn-outline-secondary">+</a>
                            </div>
                        </td>
                        <td class="text-center">Rp <%= String.format("%,.0f", subtotal) %></td>
                        <td class="text-center">
                            <a href="add-to-cart?action=remove&id=<%= id %>" class="btn btn-danger btn-sm">Delete</a>
                        </td>
                    </tr>
                <% }
                  } else { %>
                    <tr>
                        <td colspan="5" class="text-center">Empty shopping cart!</td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>

        <div class="d-flex justify-content-between mt-3">
            <a href="home.jsp" class="btn btn-outline-secondary btn-consistent">Back To Shopping</a>

            <% if (!cart.isEmpty()) { %>
            <div class="d-flex align-items-center gap-3">
                <h5 class="mb-0">Total: <strong>Rp <%= String.format("%,.0f", grandTotal) %></strong></h5>
                <a href="checkout.jsp" class="btn btn-success btn-consistent">Checkout</a>
            </div>
            <% } %>
        </div>

    </div>
</div>

</body>
</html>
