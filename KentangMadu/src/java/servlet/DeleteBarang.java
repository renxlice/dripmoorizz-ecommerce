package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/deleteBarang")
public class DeleteBarang extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Info koneksi DB
    private static final String DB_URL = "jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "root";

    // Handle request GET, bisa redirect ke halaman DataBarang.jsp
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("DataBarang.jsp");
    }

    // Handle request POST untuk delete data
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idBarang = request.getParameter("id_barang");
        if (idBarang == null || idBarang.isEmpty()) {
            response.sendRedirect("DataBarang.jsp?delete=missingId");
            return;
        }

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            String sql = "DELETE FROM data_barang WHERE id_barang = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, idBarang);

            int rowsDeleted = ps.executeUpdate();

            if (rowsDeleted > 0) {
                response.sendRedirect("DataBarang.jsp?delete=success");
            } else {
                response.sendRedirect("DataBarang.jsp?delete=fail");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("DataBarang.jsp?delete=error");
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}
