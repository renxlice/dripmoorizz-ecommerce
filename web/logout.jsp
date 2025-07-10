<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    session.invalidate(); // Hapus semua session
    response.sendRedirect("home.jsp"); // Redirect ke halaman utama
%>
