<%@ page contentType="text/html;charset=UTF-8" language="java" session="true" %>
<%@ page import="java.sql.*" %>
<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true", "root", "root");

        String query = "SELECT * FROM regis_tb WHERE email=? AND password=?";
        ps = conn.prepareStatement(query);
        ps.setString(1, email);
        ps.setString(2, password);

        rs = ps.executeQuery();

        if (rs.next()) {
            String nama = rs.getString("nama");
            session.setAttribute("nama", nama);
            session.setAttribute("email", rs.getString("email"));

            if ("Andi Ryaas Saputra Effendy".equalsIgnoreCase(nama)) {
                response.sendRedirect("dashboard.jsp");
            } else {
                response.sendRedirect("home.jsp");
            }
        } else {
            response.sendRedirect("login.jsp?error=1");
        }
    } catch (Exception e) {
        response.sendRedirect("login.jsp?error=2");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
