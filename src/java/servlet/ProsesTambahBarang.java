package servlet;

import java.io.*;
import java.math.BigDecimal;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;

@WebServlet("/proses-tambah-barang")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 1024 * 1024 * 5,
    maxRequestSize = 1024 * 1024 * 10
)
public class ProsesTambahBarang extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        HttpSession session = request.getSession();
        String loggedUser = (String) session.getAttribute("nama");
        if (loggedUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String nama_barang = request.getParameter("nama_barang");
        String keterangan = request.getParameter("keterangan");
        String kategori = request.getParameter("kategori");
        String hargaStr = request.getParameter("harga");
        String stokStr = request.getParameter("stok");

        if (nama_barang == null || nama_barang.isEmpty() ||
            keterangan == null || keterangan.isEmpty() ||
            kategori == null || kategori.isEmpty() ||
            hargaStr == null || hargaStr.isEmpty() ||
            stokStr == null || stokStr.isEmpty()) {
            response.sendRedirect("tambah-barang.jsp?error=empty");
            return;
        }

        BigDecimal harga;
        int stok;
        try {
            harga = new BigDecimal(hargaStr);
            stok = Integer.parseInt(stokStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("tambah-barang.jsp?error=invalid");
            return;
        }

        Part filePart = request.getPart("gambar");
        if (filePart == null || filePart.getSubmittedFileName() == null || filePart.getSubmittedFileName().isEmpty()) {
            response.sendRedirect("tambah-barang.jsp?error=nogambar");
            return;
        }

        String fileName = new File(filePart.getSubmittedFileName()).getName(); // Hanya nama file
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
        }

        String gambar = fileName; 

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true",
                    "root", "root"
            )) {
                String sql = "INSERT INTO data_barang (nama_barang, keterangan, kategori, harga, stok, gambar) VALUES (?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, nama_barang);
                    ps.setString(2, keterangan);
                    ps.setString(3, kategori);
                    ps.setBigDecimal(4, harga);
                    ps.setInt(5, stok);
                    ps.setString(6, gambar); 
                    ps.executeUpdate();
                }
            }

            response.sendRedirect("DataBarang.jsp?add=success");
        } catch (IOException | ClassNotFoundException | SQLException e) {
            e.printStackTrace(); // debug
            response.sendRedirect("tambah-barang.jsp?error=db");
        }
    }
}
