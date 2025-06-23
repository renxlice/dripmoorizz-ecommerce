package servlet;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/add-to-cart")
public class AddToCart extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        String idBarang = request.getParameter("id");
        
        HttpSession session = request.getSession();
        String loggedUser = (String) session.getAttribute("nama");

        // Periksa login pengguna
        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if (idBarang == null || idBarang.isEmpty()) {
            response.sendRedirect("DataBarang.jsp");
            return;
        }

        // Handle different actions
        if ("remove".equals(action)) {
            removeItemFromCart(session, idBarang);
            response.sendRedirect("cart.jsp");
            return;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true",
                "root", "root"
            );

            // Query untuk mendapatkan detail barang
            ps = conn.prepareStatement("SELECT * FROM data_barang WHERE id_barang = ?");
            ps.setString(1, idBarang);
            rs = ps.executeQuery();

            if (rs.next()) {
                String nama = rs.getString("nama_barang");
                double harga = rs.getDouble("harga");
                String gambar = rs.getString("gambar");
                int stok = rs.getInt("stok");

                List<Map<String, Object>> cart = (List<Map<String, Object>>) session.getAttribute("cart");
                if (cart == null) {
                    cart = new ArrayList<>();
                    session.setAttribute("cart", cart);
                }

                // Cari item di keranjang
                Map<String, Object> foundItem = null;
                int itemIndex = -1;
                for (int i = 0; i < cart.size(); i++) {
                    Map<String, Object> item = cart.get(i);
                    if (item.get("id").toString().equals(idBarang)) {
                        foundItem = item;
                        itemIndex = i;
                        break;
                    }
                }

                // Handle different actions
                if ("decrease".equals(action)) {
                    if (foundItem != null) {
                        int qty = (int) foundItem.get("qty");
                        if (qty > 1) {
                            foundItem.put("qty", qty - 1);
                            updateStock(conn, idBarang, 1); // Kembalikan stok
                        } else {
                            cart.remove(itemIndex); // Hapus jika qty = 1
                            updateStock(conn, idBarang, 1); // Kembalikan stok
                        }
                    }
                } else { // Default action (tambah)
                    if (foundItem != null) {
                        int qty = (int) foundItem.get("qty");
                        if (qty >= stok) {
                            session.setAttribute("error", "Stok tidak mencukupi");
                            response.sendRedirect("DataBarang.jsp");
                            return;
                        }
                        foundItem.put("qty", qty + 1);
                        updateStock(conn, idBarang, -1); // Kurangi stok
                    } else {
                        if (stok <= 0) {
                            session.setAttribute("error", "Stok barang habis");
                            response.sendRedirect("DataBarang.jsp");
                            return;
                        }
                        Map<String, Object> newItem = new LinkedHashMap<>();
                        newItem.put("id", idBarang);
                        newItem.put("nama", nama);
                        newItem.put("harga", harga);
                        newItem.put("qty", 1);
                        newItem.put("gambar", gambar);
                        cart.add(newItem);
                        updateStock(conn, idBarang, -1); // Kurangi stok
                    }
                }

                // Update total items in cart
                updateCartItemsCount(session);
                session.setAttribute("success", "Keranjang berhasil diperbarui");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Terjadi kesalahan: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }

        response.sendRedirect(request.getHeader("referer"));
    }

    private void removeItemFromCart(HttpSession session, String idBarang) {
    List<Map<String, Object>> cart = (List<Map<String, Object>>) session.getAttribute("cart");
    if (cart != null) {
        for (Iterator<Map<String, Object>> iterator = cart.iterator(); iterator.hasNext();) {
            Map<String, Object> item = iterator.next();
            if (item.get("id").toString().equals(idBarang)) {
                int qty = (int) item.get("qty");

                // Update stok di database
                try (Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true",
                        "root", "root"
                )) {
                    updateStock(conn, idBarang, qty); // Kembalikan stok
                } catch (SQLException e) {
                    e.printStackTrace();
                }

                iterator.remove();
                break;
            }
        }
        updateCartItemsCount(session);
    }
}

    private void updateStock(Connection conn, String idBarang, int quantityChange) throws SQLException {
        PreparedStatement ps = null;
        try {
            ps = conn.prepareStatement("UPDATE data_barang SET stok = stok + ? WHERE id_barang = ?");
            ps.setInt(1, quantityChange);
            ps.setString(2, idBarang);
            ps.executeUpdate();
        } finally {
            if (ps != null) ps.close();
        }
    }

    private void updateCartItemsCount(HttpSession session) {
        List<Map<String, Object>> cart = (List<Map<String, Object>>) session.getAttribute("cart");
        int totalItems = 0;
        if (cart != null) {
            totalItems = cart.stream().mapToInt(item -> (int) item.get("qty")).sum();
        }
        session.setAttribute("cartItems", totalItems);
    }
}