<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String categoryFilter = request.getParameter("category"); 
    if (categoryFilter == null) categoryFilter = "all";

    String loggedUser = (String) session.getAttribute("nama");
    int cartItems = session.getAttribute("cartItems") != null ? (int) session.getAttribute("cartItems") : 0;

    // Koneksi database
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    // Siapkan set untuk kategori dan list untuk produk
    Set<String> kategoriSet = new HashSet<>();
    List<Map<String, Object>> productList = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true", 
            "root", 
            "root"
        );

        ps = conn.prepareStatement("SELECT * FROM data_barang");
        rs = ps.executeQuery();

        while (rs.next()) {
            String kategori = rs.getString("kategori").trim();
            kategoriSet.add(kategori);

            // Filter sesuai kategori jika dipilih
            if (!categoryFilter.equalsIgnoreCase("all") && !kategori.equalsIgnoreCase(categoryFilter)) {
                continue;
            }

            Map<String, Object> product = new HashMap<>();
            product.put("id", rs.getString("id_barang"));
            product.put("nama", rs.getString("nama_barang"));
            product.put("keterangan", rs.getString("keterangan"));
            product.put("harga", rs.getInt("harga"));
            product.put("stok", rs.getInt("stok"));
            product.put("gambar", rs.getString("gambar"));
            product.put("kategori", kategori);

            productList.add(product);
        }

    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DripmooRizz</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
            background: #f8f9fa;
            color: var(--dark-color);
        }

        .navbar {
            background: linear-gradient(to right, #667eea, #764ba2);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            padding: 12px 0;
        }

        .navbar-brand {
            font-weight: 700;
            font-size: 1.5rem;
            color: #fff !important;
        }

        .nav-link {
            font-weight: 500;
            color: rgba(255, 255, 255, 0.9) !important;
            margin: 0 10px;
            transition: all 0.3s ease;
        }

        .nav-link:hover {
            color: #fff !important;
            transform: translateY(-2px);
        }

        .btn-outline-light {
            border-radius: 20px;
            margin-left: 10px;
            font-weight: 500;
            padding: 8px 20px;
            transition: all 0.3s ease;
        }

        .btn-outline-light:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        .hero-section {
            min-height: 80vh;
            padding: 120px 0 80px;
            background: linear-gradient(to right, rgba(102, 126, 234, 0.8), rgba(118, 75, 162, 0.8)), url('images/Milk-Protein-Panel.jpg') no-repeat center center;
            background-size: cover;
            position: relative;
            color: #fff;
            display: flex;
            align-items: center;
        }

        .hero-content {
            text-align: center;
        }

        .hero-content h1 {
            font-size: 3.5rem;
            font-weight: 700;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
        }

        .hero-content p {
            font-size: 1.3rem;
            margin-bottom: 30px;
            opacity: 0.9;
        }

        .btn-custom {
            background-color: var(--primary-color);
            color: white;
            border-radius: 30px;
            font-weight: 600;
            padding: 12px 30px;
            transition: all 0.3s ease;
            border: none;
        }

        .btn-custom:hover {
            background-color: var(--secondary-color);
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
            color: white;
        }

        .section {
            padding: 80px 0;
        }

        .section-title {
            font-weight: 700;
            margin-bottom: 50px;
            position: relative;
            display: inline-block;
        }

        .section-title:after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 0;
            width: 60px;
            height: 4px;
            background: var(--primary-color);
            border-radius: 2px;
        }

        .card {
            border: none;
            border-radius: 15px;
            overflow: hidden;
            transition: all 0.3s ease;
            margin-bottom: 30px;
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.1);
        }

        .card:hover {
            transform: translateY(-10px);
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15);
        }

        .card-img-container {
            position: relative;
            overflow: hidden;
            height: 220px;
        }

        .card-img-top {
            height: 100%;
            object-fit: cover;
            transition: transform 0.5s ease;
        }

        .card:hover .card-img-top {
            transform: scale(1.05);
        }

        .card-body {
            padding: 20px;
        }

        .card-title {
            font-weight: 600;
            margin-bottom: 10px;
            font-size: 1.1rem;
        }

        .card-subtitle {
            color: #6c757d;
            font-size: 0.9rem;
            margin-bottom: 15px;
        }

        .price-tag {
            background-color: var(--accent-color);
            color: white;
            padding: 5px 12px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.9rem;
            display: inline-block;
            margin-bottom: 15px;
        }

        .btn-add-cart {
            background-color: var(--primary-color);
            color: white;
            border-radius: 10px;
            padding: 8px 15px;
            font-weight: 500;
            font-size: 0.9rem;
            transition: all 0.3s ease;
            border: none;
        }

        .btn-add-cart:hover {
            background-color: var(--secondary-color);
            color: white;
        }

        .btn-detail {
            background-color: transparent;
            color: var(--primary-color);
            border: 1px solid var(--primary-color);
            border-radius: 10px;
            padding: 8px 15px;
            font-weight: 500;
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }

        .btn-detail:hover {
            background-color: var(--primary-color);
            color: white;
        }
        
        .btn-subscribe {
            background-color: var(--primary-color);
            color: white;
            border-radius: 10px;
            padding: 12px 20px;
            font-weight: 500;
            transition: all 0.3s ease;
            border: none;
            height: 100%;
        }

        .btn-subscribe:hover {
            background-color: var(--secondary-color);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        .form-control-lg {
            padding: 12px 20px;
            height: auto;
        }

        .testimonial-card {
            background-color: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
        }

        .testimonial-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15);
        }

        .testimonial-text {
            font-style: italic;
            margin-bottom: 20px;
            position: relative;
        }

        .testimonial-text:before {
            content: '"';
            font-size: 50px;
            color: rgba(108, 99, 255, 0.2);
            position: absolute;
            top: -25px;
            left: -10px;
        }

        .testimonial-author {
            display: flex;
            align-items: center;
        }

        .testimonial-author img {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            margin-right: 15px;
            object-fit: cover;
        }

        .author-info h5 {
            margin-bottom: 0;
            font-weight: 600;
        }

        .author-info p {
            color: #6c757d;
            margin-bottom: 0;
            font-size: 0.9rem;
        }

        .stats-container {
            background-color: var(--primary-color);
            padding: 40px 0;
            color: white;
        }

        .stat-item {
            text-align: center;
            padding: 20px;
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .stat-text {
            font-size: 1.1rem;
            font-weight: 500;
            opacity: 0.9;
        }

        footer {
            background-color: var(--dark-color);
            color: #ddd;
            padding: 60px 0 30px;
        }

        .footer-logo {
            font-weight: 700;
            font-size: 1.8rem;
            margin-bottom: 20px;
            display: inline-block;
        }

        .footer-text {
            color: #aaa;
            margin-bottom: 20px;
            line-height: 1.7;
            max-width: 400px;
        }

        .footer-links {
            list-style: none;
            padding: 0;
        }

        .footer-links li {
            margin-bottom: 10px;
        }

        .footer-links a {
            color: #aaa;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .footer-links a:hover {
            color: white;
            transform: translateX(5px);
        }

        .footer-title {
            font-weight: 600;
            margin-bottom: 25px;
            position: relative;
        }

        .footer-title:after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 0;
            width: 40px;
            height: 3px;
            background: var(--primary-color);
            border-radius: 2px;
        }

        .social-icons {
            list-style: none;
            padding: 0;
            display: flex;
            gap: 15px;
        }

        .social-icons a {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 40px;
            height: 40px;
            background-color: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            transition: all 0.3s ease;
            color: white;
        }

        .social-icons a:hover {
            background-color: var(--primary-color);
            transform: translateY(-5px);
        }

        .copyright {
            text-align: center;
            padding-top: 30px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            margin-top: 40px;
            color: #aaa;
        }

        .cart-icon {
            position: relative;
        }

        .cart-badge {
            position: absolute;
            top: -8px;
            right: -8px;
            background-color: var(--accent-color);
            color: white;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.7rem;
            font-weight: 600;
        }

        .featured-badge {
            position: absolute;
            top: 15px;
            right: 15px;
            background-color: var(--accent-color);
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.8rem;
            z-index: 1;
        }

        .user-greeting {
            display: flex;
            align-items: center;
            color: white;
            margin-right: 15px;
        }

        .user-greeting i {
            margin-right: 5px;
        }

        .category-pills {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 30px;
            justify-content: center;
        }

        .category-pill {
            background-color: white;
            border: 1px solid var(--primary-color);
            color: var(--primary-color);
            border-radius: 30px;
            padding: 8px 20px;
            font-weight: 500;
            transition: all 0.3s ease;
            text-decoration: none;
            cursor: pointer;
        }

        .category-pill:hover, .category-pill.active {
            background-color: var(--primary-color);
            color: white;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .animate-fade-in {
            animation: fadeIn 0.5s ease forwards;
        }
        
        .badge {
            font-size: 0.75rem;
            font-weight: 600;
            padding: 5px 10px;
            border-radius: 15px;
        }

        .card-img-container .badge {
            z-index: 2;
        }
        
        .modal-content {
            border-radius: 15px;
            overflow: hidden;
            border: none;
        }

        .modal-header {
            background-color: var(--primary-color);
            color: white;
            border-bottom: none;
        }

        .modal-body {
            padding: 30px;
        }

        .btn-close {
            filter: invert(1);
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark fixed-top">
    <div class="container">
        <a class="navbar-brand" href="index.jsp">
            <i class="fas fa-milk-carton me-2"></i>DripmooRizz
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse justify-content-end" id="navbarNav">
            <ul class="navbar-nav me-3">
                <li class="nav-item">
                    <a class="nav-link" href="#home">Home</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#products">Products</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#about">About</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#testimonials">Testimonials</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#contact">Contact</a>
                </li>
            </ul>

         <% if (loggedUser == null) { %>
    <a href="login.jsp" class="btn btn-outline-light">Login</a>
    <a href="tb1.html" class="btn btn-outline-light">Register</a>
<% } else { %>
    <div class="user-greeting text-white me-3">
        <i class="fas fa-user-circle"></i>
        <span>Hello, <strong><%= loggedUser %></strong></span>
    </div>

    <a href="cart.jsp" class="btn btn-outline-light me-2 cart-icon">
        <i class="fas fa-shopping-cart"></i>
        <% if(session.getAttribute("cartItems") != null && (int)session.getAttribute("cartItems") > 0) { %>
            <span class="cart-badge"><%= session.getAttribute("cartItems") %></span>
        <% } %>
    </a>

    <%-- Jika admin, tampilkan dashboard --%>
    
    <%-- Tombol Status Pesanan (untuk semua user yang login) --%>
    <a href="pesanan-user.jsp" class="btn btn-outline-light me-2">
        <i class="fas fa-receipt me-1"></i> 
    </a>
    
    <% if ("Andi Ryaas Saputra Effendy".equals(loggedUser)) { %>
        <a href="dashboard.jsp" class="btn btn-outline-light me-2">Dashboard</a>
    <% } %>


    <a href="logout.jsp" class="btn btn-outline-light">Logout</a>
<% } %>

        </div>
    </div>
</nav>

<!-- Hero Section -->
<section id="home" class="hero-section">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-lg-6 animate-fade-in">
                <div class="hero-content text-lg-start">
                    <h1>Welcome to DripmooRizz</h1>
                    <p>Where Style Meets Sip. Dairy with drip. Milk with rizz. 🥛🔥</p>
                    <div>
                        <a href="#products" class="btn btn-custom">Explore Products</a>
                        <a href="#about" class="btn btn-outline-light ms-3">Learn More</a>
                    </div>
                </div>
            </div>
            <div class="col-lg-6 d-none d-lg-block animate-fade-in">
                <img src="https://images.unsplash.com/photo-1550583724-b2692b85b150" alt="Premium milk products" class="img-fluid rounded shadow-lg">
            </div>
        </div>
    </div>
</section>

<!-- Products Section -->
<section id="products" class="section">
    <div class="container">
        <div class="text-center mb-5">
            <h2 class="section-title">Our Products</h2>
            <p class="text-muted">Discover our premium, trendy milk products</p>
        </div>

        <!-- Tombol Kategori -->
        <div id="categoryPills" class="category-pills mb-4 text-center">
            <a href="?category=all" class="btn btn-outline-primary category-pill me-2 active">All Product</a>
            <% for (String kat : kategoriSet) { %>
                <a href="?category=<%= kat.toLowerCase() %>" class="btn btn-outline-primary category-pill me-2"><%= kat %></a>
            <% } %>
        </div>

        <!-- Produk -->
        <div class="row" id="productList">
            <% for (Map<String, Object> p : productList) {
                String id = (String) p.get("id");
                String nama = (String) p.get("nama");
                String keterangan = (String) p.get("keterangan");
                int harga = (Integer) p.get("harga");
                int stok = (Integer) p.get("stok");
                String gambar = (String) p.get("gambar");
                String kategori = (String) p.get("kategori");

                String badge = "";
                if (stok == 0) {
                    badge = "<span class='badge bg-danger position-absolute top-0 end-0 m-2'>Sold Out</span>";
                } else if (stok <= 3) {
                    badge = "<span class='badge bg-warning text-dark position-absolute top-0 end-0 m-2'>Limited</span>";
                }
            %>
            <div class="col-md-6 col-lg-4 col-xl-3 mb-4 product-item" data-category="<%= kategori.toLowerCase() %>">
                <div class="card">
                    <div class="card-img-container">
                        <%= badge %>
                        <img src="images/<%= gambar %>" class="card-img-top" alt="<%= nama %>">
                    </div>
                    <div class="card-body">
                        <h5 class="card-title"><%= nama %></h5>
                        <p class="card-subtitle"><%= keterangan %></p>
                        <div class="d-flex justify-content-between align-items-center">
                            <div class="price-tag">Rp. <%= String.format("%,d", harga) %></div>
                            <span class="badge bg-secondary"><%= kategori %></span>
                        </div>
                        <div class="d-flex justify-content-between mt-2">
                            <button onclick="showProductDetail('<%= id %>')" class="btn btn-detail">Detail</button>
                            <% if (stok > 0) { %>
                                <a href="add-to-cart?id=<%= id %>" class="btn btn-add-cart">Add to Cart</a>
                            <% } else { %>
                                <button class="btn btn-add-cart" disabled>Sold Out</button>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
        </div>

        <div class="text-center mt-4">
            <a href="shop.jsp" class="btn btn-custom">View All Products</a>
        </div>
    </div>
</section>


<!-- About Section -->
<section id="about" class="section bg-light">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-lg-6 mb-4 mb-lg-0">
                <img src="https://cdn.pixabay.com/photo/2016/12/06/18/27/milk-1887234_1280.jpg" alt="About DripmooRizz" class="img-fluid rounded shadow">
            </div>
            <div class="col-lg-6">
                <h2 class="section-title">About DripmooRizz</h2>
                <p>DripmooRizz is a premium milk and dairy brand that combines the timeless goodness of farm-fresh milk with trendy, modern flavors and packaging. Born from a passion for quality dairy and a love for contemporary culture, we bring you dairy with drip, milk with rizz.</p>
                <p>Our mission is to revolutionize how you experience milk - elevating it from a basic kitchen staple to a statement beverage that's as stylish as it is nutritious.</p>
                <p>We partner with local farms that practice sustainable and ethical farming methods to ensure that every bottle of DripmooRizz not only tastes amazing but also contributes to a better world.</p>
                <a href="about.jsp" class="btn btn-custom mt-3">Learn More About Us</a>
            </div>
        </div>
    </div>
</section>

<!-- Product Detail Modal -->
<div class="modal fade" id="productDetailModal" tabindex="-1" aria-labelledby="productDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="productDetailModalLabel">Product Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-md-6">
                        <img id="detailProductImage" src="" alt="Product Image" class="img-fluid rounded">
                    </div>
                    <div class="col-md-6">
                        <h3 id="detailProductName"></h3>
                        <p id="detailProductCategory" class="text-muted"></p>
                        <p id="detailProductDescription" class="my-3"></p>
                        <div class="d-flex align-items-center mb-3">
                            <span id="detailProductPrice" class="price-tag"></span>
                            <span id="detailProductStock" class="badge ms-2"></span>
                        </div>
                        <div class="d-flex justify-content-between mt-4">
                            <button class="btn btn-detail" data-bs-dismiss="modal">Close</button>
                            <a id="detailAddToCartBtn" href="add-to-cart?id=" class="btn btn-add-cart">Add to Cart</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Stats Section -->
<section class="stats-container">
    <div class="container">
        <div class="row">
            <div class="col-md-3 col-6">
                <div class="stat-item">
                    <div class="stat-number">15+</div>
                    <div class="stat-text">Unique Products</div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="stat-item">
                    <div class="stat-number">10k+</div>
                    <div class="stat-text">Happy Customers</div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="stat-item">
                    <div class="stat-number">8</div>
                    <div class="stat-text">Partner Farms</div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="stat-item">
                    <div class="stat-number">24h</div>
                    <div class="stat-text">Delivery Time</div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Testimonials Section -->
<section id="testimonials" class="section">
    <div class="container">
        <div class="text-center mb-5">
            <h2 class="section-title">Customer Testimonials</h2>
            <p class="text-muted">What our customers say about DripmooRizz</p>
        </div>

        <div class="row">
            <!-- Testimonial 1 -->
            <div class="col-md-6 col-lg-4">
                <div class="testimonial-card">
                    <div class="testimonial-text">
                        The Classic Premium Milk is simply outstanding! You can really taste the difference in quality. It's become a daily staple in my home.
                    </div>
                    <div class="testimonial-author">
                        <img src="https://randomuser.me/api/portraits/women/12.jpg" alt="Sarah J.">
                        <div class="author-info">
                            <h5>Sarah J.</h5>
                            <p>Regular Customer</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Testimonial 2 -->
            <div class="col-md-6 col-lg-4">
                <div class="testimonial-card">
                    <div class="testimonial-text">
                        My kids absolutely love the Strawberry Dream! It's the perfect blend of sweetness without being too overpowering. And I love that it uses natural ingredients!
                    </div>
                    <div class="testimonial-author">
                        <img src="https://randomuser.me/api/portraits/men/32.jpg" alt="Michael T.">
                        <div class="author-info">
                            <h5>Michael T.</h5>
                            <p>Parent</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Testimonial 3 -->
            <div class="col-md-6 col-lg-4">
                <div class="testimonial-card">
                    <div class="testimonial-text">
                        As someone who's lactose intolerant, finding the Almond Milk from DripmooRizz was a game-changer. It's creamy, flavorful, and mixes perfectly with my morning coffee.
                    </div>
                    <div class="testimonial-author">
                        <img src="https://randomuser.me/api/portraits/women/28.jpg" alt="Aisha K.">
                        <div class="author-info">
                            <h5>Aisha K.</h5>
                            <p>Verified Buyer</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Newsletter Section -->
<section class="section bg-light">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-8 text-center">
                <h2 class="section-title">Subscribe to Our Newsletter</h2>
                <p class="mb-4">Stay updated with our latest products, offers, and dairy tips!</p>
                <form class="row g-3 justify-content-center">
                    <div class="col-md-8 col-12">
                        <input type="email" class="form-control form-control-lg" placeholder="Your email address" required>
                    </div>
                    <div class="col-md-4 col-12">
                        <button type="submit" class="btn btn-subscribe w-100">Subscribe</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>

<!-- Contact Section -->
<section id="contact" class="section">
    <div class="container">
        <div class="row">
            <div class="col-lg-6 mb-4 mb-lg-0">
                <h2 class="section-title">Get In Touch</h2>
                <p class="mb-4">Have questions, feedback, or want to place a bulk order? Reach out to us!</p>
                <form>
                    <div class="mb-3">
                        <label for="name" class="form-label">Your Name</label>
                        <input type="text" class="form-control" id="name" placeholder="Enter your name">
                    </div>
                    <div class="mb-3">
                        <label for="email" class="form-label">Email Address</label>
                        <input type="email" class="form-control" id="email" placeholder="Enter your email">
                    </div>
                    <div class="mb-3">
                        <label for="subject" class="form-label">Subject</label>
                        <input type="text" class="form-control" id="subject" placeholder="Enter subject">
                    </div>
                    <div class="mb-3">
                        <label for="message" class="form-label">Message</label>
                        <textarea class="form-control" id="message" rows="5" placeholder="Enter your message"></textarea>
                    </div>
                    <button type="submit" class="btn btn-custom">Send Message</button>
                </form>
            </div>
            <div class="col-lg-6">
                <div class="bg-light p-4 rounded shadow-sm h-100">
                    <h4 class="mb-4">Contact Information</h4>
                    <div class="d-flex mb-3">
                        <i class="fas fa-map-marker-alt me-3 mt-1 text-primary"></i>
                        <div>
                            <h5 class="mb-1">Address</h5>
                            <p>Jl. Susu Segar No. 123, Bandung, Indonesia</p>
                        </div>
                    </div>
                    <div class="d-flex mb-3">
                        <i class="fas fa-phone-alt me-3 mt-1 text-primary"></i>
                        <div>
                            <h5 class="mb-1">Phone</h5>
                            <p>+62 22 1234 5678</p>
                        </div>
                    </div>
                    <div class="d-flex mb-3">
                        <i class="fas fa-envelope me-3 mt-1 text-primary"></i>
                        <div>
                            <h5 class="mb-1">Email</h5>
                            <p>info@dripmoorrizz.com</p>
                        </div>
                    </div>
                    <div class="d-flex">
                        <i class="fas fa-clock me-3 mt-1 text-primary"></i>
                        <div>
                            <h5 class="mb-1">Opening Hours</h5>
                            <p>Monday - Friday: 9:00 AM - 6:00 PM<br>Saturday: 10:00 AM - 4:00 PM</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Footer -->
<footer>
    <div class="container">
        <div class="row">
            <div class="col-lg-4 mb-4 mb-lg-0">
                <a href="#" class="footer-logo text-white">
                    <i class="fas fa-milk-carton me-2"></i>DripmooRizz
                </a>
                <p class="footer-text">Premium milk products with style. We're revolutionizing the dairy industry one bottle at a time.</p>
                <ul class="social-icons">
                    <li><a href="#"><i class="fab fa-facebook-f"></i></a></li>
                    <li><a href="#"><i class="fab fa-twitter"></i></a></li>
                    <li><a href="#"><i class="fab fa-instagram"></i></a></li>
                    <li><a href="#"><i class="fab fa-tiktok"></i></a></li>
                </ul>
            </div>
            <div class="col-md-4 col-lg-2 mb-4 mb-md-0">
                <h5 class="footer-title">Quick Links</h5>
                <ul class="footer-links">
                    <li><a href="index.jsp">Home</a></li>
                    <li><a href="shop.jsp">Shop</a></li>
                    <li><a href="about.jsp">About Us</a></li>
                    <li><a href="contact.jsp">Contact</a></li>
                    <li><a href="faq.jsp">FAQs</a></li>
                </ul>
            </div>
            <div class="col-md-4 col-lg-3 mb-4 mb-md-0">
                <h5 class="footer-title">Products</h5>
                <ul class="footer-links">
                    <li><a href="category.jsp?id=1">Premium Milk</a></li>
                    <li><a href="category.jsp?id=2">Flavored Drinks</a></li>
                    <li><a href="category.jsp?id=3">Milk Alternatives</a></li>
                    <li><a href="category.jsp?id=4">Merchandise</a></li>
                    <li><a href="new-releases.jsp">New Releases</a></li>
                </ul>
            </div>
            <div class="col-md-4 col-lg-3">
                <h5 class="footer-title">Customer Support</h5>
                <ul class="footer-links">
                    <li><a href="track-order.jsp">Track Your Order</a></li>
                    <li><a href="returns.jsp">Returns & Exchanges</a></li>
                    <li><a href="shipping.jsp">Shipping Information</a></li>
                    <li><a href="privacy-policy.jsp">Privacy Policy</a></li>
                    <li><a href="terms.jsp">Terms & Conditions</a></li>
                </ul>
            </div>
        </div>
        <div class="copyright">
            <p>&copy; 2025 DripmooRizz. All Rights Reserved.</p>
        </div>
    </div>
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<!-- Custom JavaScript -->
<script>
document.addEventListener("DOMContentLoaded", function () {
    // === Smooth Scrolling ===
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;
            const target = document.querySelector(targetId);
            if (target) {
                const navbarHeight = document.querySelector('.navbar').offsetHeight;
                const targetPosition = target.getBoundingClientRect().top + window.pageYOffset;
                window.scrollTo({ top: targetPosition - navbarHeight, behavior: 'smooth' });
            }
        });
    });

    // === Active Nav Link on Scroll ===
    window.addEventListener('scroll', function () {
        const sections = document.querySelectorAll('section');
        const navLinks = document.querySelectorAll('.nav-link');
        let current = '';
        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            const sectionHeight = section.clientHeight;
            if (pageYOffset >= sectionTop - 200) {
                current = section.getAttribute('id');
            }
        });
        navLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href') === `#${current}`) {
                link.classList.add('active');
            }
        });
    });

    // === Fade In Animation ===
    const fadeElements = document.querySelectorAll('.animate-fade-in');
    const fadeInOnScroll = () => {
        fadeElements.forEach(element => {
            const elementPosition = element.getBoundingClientRect().top;
            const windowHeight = window.innerHeight;
            if (elementPosition < windowHeight * 0.9) {
                element.style.opacity = '1';
                element.style.transform = 'translateY(0)';
            }
        });
    };
    fadeElements.forEach(element => {
        element.style.opacity = '0';
        element.style.transform = 'translateY(20px)';
        element.style.transition = 'all 0.5s ease';
    });
    window.addEventListener('scroll', fadeInOnScroll);
    fadeInOnScroll();

    // === Kategori Filter ===
    const categoryPills = document.querySelectorAll('.category-pill');
    const productItems = document.querySelectorAll('.product-item');

    function filterProducts(category) {
        productItems.forEach(item => {
            const itemCategory = item.getAttribute("data-category");
            if (!category || category.toLowerCase() === "all" || itemCategory.toLowerCase() === category.toLowerCase()) {
                item.style.display = "block";
            } else {
                item.style.display = "none";
            }
        });
    }

    categoryPills.forEach(pill => {
        pill.addEventListener("click", function (e) {
            e.preventDefault();
            const urlParams = new URLSearchParams(this.getAttribute("href").split('?')[1]);
            const category = urlParams.get("category");

            categoryPills.forEach(p => p.classList.remove("active"));
            this.classList.add("active");

            filterProducts(category);
            history.replaceState(null, '', '#products'); // Hilangkan ?category di URL jika perlu
        });
    });

    // Auto-filter saat page pertama kali dimuat jika ada ?category=
    const initialParams = new URLSearchParams(window.location.search);
    const initialCategory = initialParams.get("category");
    if (initialCategory) {
        filterProducts(initialCategory);
        categoryPills.forEach(pill => {
            const pillCategory = new URLSearchParams(pill.getAttribute("href").split('?')[1]).get("category");
            if (pillCategory && pillCategory.toLowerCase() === initialCategory.toLowerCase()) {
                pill.classList.add("active");
            } else {
                pill.classList.remove("active");
            }
        });
    }

    // === Show Product Detail Modal ===
    window.showProductDetail = function (productId) {
        fetch('product-detail.jsp?id=' + productId)
            .then(response => response.json())
            .then(data => {
                document.getElementById('detailProductName').textContent = data.nama_barang;
                document.getElementById('detailProductCategory').textContent = data.kategori || 'No category';
                document.getElementById('detailProductDescription').textContent = data.keterangan;
                document.getElementById('detailProductPrice').textContent = 'Rp. ' + data.harga.toLocaleString();
                document.getElementById('detailProductImage').src = 'images/' + data.gambar;

                const stockBadge = document.getElementById('detailProductStock');
                const addToCartBtn = document.getElementById('detailAddToCartBtn');

                if (data.stok == 0) {
                    stockBadge.textContent = 'Sold Out';
                    stockBadge.className = 'badge bg-danger ms-2';
                    addToCartBtn.style.display = 'none';
                } else if (data.stok <= 3) {
                    stockBadge.textContent = 'Limited Stock: ' + data.stok;
                    stockBadge.className = 'badge bg-warning text-dark ms-2';
                    addToCartBtn.style.display = 'block';
                    addToCartBtn.href = 'add-to-cart?id=' + productId;
                } else {
                    stockBadge.textContent = 'In Stock: ' + data.stok;
                    stockBadge.className = 'badge bg-success ms-2';
                    addToCartBtn.style.display = 'block';
                    addToCartBtn.href = 'add-to-cart?id=' + productId;
                }

                const modal = new bootstrap.Modal(document.getElementById('productDetailModal'));
                modal.show();
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Failed to load product details');
            });
    }
});
</script>
</body>
</html>