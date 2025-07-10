<%@ page import="java.sql.*, org.json.simple.JSONObject" %>
<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%
    String productId = request.getParameter("id");
    JSONObject product = new JSONObject();
    
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true", "root", "root");
        
        String sql = "SELECT * FROM data_barang WHERE id_barang = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, productId);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            product.put("id_barang", rs.getString("id_barang"));
            product.put("nama_barang", rs.getString("nama_barang"));
            product.put("keterangan", rs.getString("keterangan"));
            product.put("kategori", rs.getString("kategori")); 
            product.put("harga", rs.getInt("harga"));
            product.put("stok", rs.getInt("stok"));
            product.put("gambar", rs.getString("gambar"));
        }
        
        out.print(product.toJSONString());
        out.flush();
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>