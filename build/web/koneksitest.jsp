<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.mysql.cj.jdbc.Driver" %>

<%
    Connection connection = null;
    String status = "";
    try {
        String connectionURL = "jdbc:mysql://localhost:8889/tb1?useSSL=false&allowPublicKeyRetrieval=true";
        String username = "root";
        String password = "root";

        Class.forName("com.mysql.cj.jdbc.Driver");
        connection = DriverManager.getConnection(connectionURL, username, password);

        if (connection == null)
            status = "gagal";
        else
            status = "berhasil";

        connection.close();
    } catch (ClassNotFoundException ex) {
        status = "Driver Error: " + ex.getMessage();
    } catch (SQLException ex) {
        status = "SQL Error: " + ex.getMessage();
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Test Koneksi DB</title>
    </head>
    <body>
        <h2>Koneksi ke database: <%= status %></h2>
    </body>
</html>
