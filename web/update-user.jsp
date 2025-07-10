<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String id = request.getParameter("id");
        String nama = request.getParameter("nama");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true", "root", "root");

            String sql;
            if (password != null && !password.trim().isEmpty()) {
                sql = "UPDATE regis_tb SET nama = ?, email = ?, password = ? WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, nama);
                pstmt.setString(2, email);
                pstmt.setString(3, password);
                pstmt.setString(4, id);
            } else {
                sql = "UPDATE regis_tb SET nama = ?, email = ? WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, nama);
                pstmt.setString(2, email);
                pstmt.setString(3, id);
            }

            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                response.sendRedirect("DataRegister.jsp?edit=success");
            } else {
                response.sendRedirect("DataRegister.jsp?edit=fail");
            }

        } catch (Exception e) {
            response.sendRedirect("DataRegister.jsp?edit=fail");
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }

    } else {
        response.sendRedirect("DataRegister.jsp?edit=fail");
    }
%>
