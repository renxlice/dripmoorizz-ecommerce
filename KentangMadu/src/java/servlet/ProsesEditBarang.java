package servlet;

import java.io.*;
import java.math.BigDecimal;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;

@WebServlet("/proses-edit-barang")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 1024 * 1024 * 5,
    maxRequestSize = 1024 * 1024 * 10
)
public class ProsesEditBarang extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String loggedUser = (String) session.getAttribute("nama");
        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String id_barang = request.getParameter("id_barang");
        String nama_barang = request.getParameter("nama_barang");
        String keterangan = request.getParameter("keterangan");
        String kategori = request.getParameter("kategori");

        BigDecimal harga;
        int stok;

        try {
            harga = new BigDecimal(request.getParameter("harga"));
            stok = Integer.parseInt(request.getParameter("stok"));
        } catch (NumberFormatException e) {
            response.sendRedirect("edit-barang.jsp?id_barang=" + id_barang + "&error=format");
            return;
        }

        Part filePart = request.getPart("gambar");
        String gambar = null;

        if (filePart != null && filePart.getSize() > 0 && filePart.getSubmittedFileName() != null) {
            String fileName = new File(filePart.getSubmittedFileName()).getName();
            String uploadPath = "/Users/mac/NetBeansProjects/KentangMadu/web/images";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            String filePath = uploadPath + File.separator + fileName;
            try (InputStream input = filePart.getInputStream();
                 OutputStream output = new FileOutputStream(filePath)) {
                byte[] buffer = new byte[1024];
                int length;
                while ((length = input.read(buffer)) > 0) {
                    output.write(buffer, 0, length);
                }
            } catch (IOException e) {
                e.printStackTrace();
                response.sendRedirect("edit-barang.jsp?id_barang=" + id_barang + "&error=upload");
                return;
            }
            gambar = fileName;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true",
                    "root", "root"
            )) {
                String sql;
                PreparedStatement ps;

                if (gambar != null) {
                    sql = "UPDATE data_barang SET nama_barang=?, keterangan=?, kategori=?, harga=?, stok=?, gambar=? WHERE id_barang=?";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, nama_barang);
                    ps.setString(2, keterangan);
                    ps.setString(3, kategori);
                    ps.setBigDecimal(4, harga);
                    ps.setInt(5, stok);
                    ps.setString(6, gambar);
                    ps.setString(7, id_barang);
                } else {
                    sql = "UPDATE data_barang SET nama_barang=?, keterangan=?, kategori=?, harga=?, stok=? WHERE id_barang=?";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, nama_barang);
                    ps.setString(2, keterangan);
                    ps.setString(3, kategori);
                    ps.setBigDecimal(4, harga);
                    ps.setInt(5, stok);
                    ps.setString(6, id_barang);
                }

                int result = ps.executeUpdate();
                if (result > 0) {
                    response.sendRedirect("DataBarang.jsp?update=success");
                } else {
                    response.sendRedirect("edit-barang.jsp?id_barang=" + id_barang + "&error=fail");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("edit-barang.jsp?id_barang=" + id_barang + "&error=db&msg=" + e.getMessage());
        }
    }
}
