package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

@WebServlet("/GoogleLoginServlet")
public class GoogleLoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // Email admin yang diarahkan ke dashboard
    private static final String ADMIN_EMAIL = "andiryaas49@gmail.com";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Ambil data dari Google Sign-In
        String nama = request.getParameter("nama");
        String email = request.getParameter("email");

        if (nama != null && !nama.isEmpty() && email != null && !email.isEmpty()) {
            // Cek atau insert user ke database
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                try (Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true",
                        "root", "root")) {

                    String checkSql = "SELECT id FROM regis_tb WHERE email = ?";
                    try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                        checkStmt.setString(1, email);
                        try (ResultSet rs = checkStmt.executeQuery()) {
                            if (!rs.next()) {
                                // Email belum ada, insert user baru
                                String insertSql = "INSERT INTO regis_tb (nama, email, password) VALUES (?, ?, '')";
                                try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                                    insertStmt.setString(1, nama);
                                    insertStmt.setString(2, email);
                                    insertStmt.executeUpdate();
                                }
                            }
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("login.jsp?error=database_error");
                return;
            }

            // Simpan session login
            HttpSession session = request.getSession(true);
            session.setAttribute("nama", nama);
            session.setAttribute("email", email);
            session.setAttribute("isGoogleLogin", true);

            // Redirect sesuai role (admin atau user biasa)
            if (ADMIN_EMAIL.equalsIgnoreCase(email)) {
                response.sendRedirect("dashboard.jsp");
            } else {
                response.sendRedirect("home.jsp");
            }

        } else {
            // Data tidak lengkap
            response.sendRedirect("login.jsp?error=invalid_google_data");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Akses GET diarahkan ke login
        response.sendRedirect("login.jsp");
    }
}
