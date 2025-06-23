<%-- 
    Document   : operator
    Created on : Mar 26, 2025, 2:42:57 PM
    Author     : mac
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <%-- Proses Pendeklarasian:--%>
        <%!
        String nama;
        String makanan;
        int harga = 15000;
        int total;
        %>
        
        Setelah Pendeklarasian: <br><br>
        <%
        nama = "Tuan Andi";
        makanan = "Nasi Goreng";
        total = harga*2;
        
        out.println("Nama Customer : " + nama + "<br>");
        out.println("Menu Makanan : " + makanan + "<br>");
        out.println("Harga : " + harga);
        out.println("Total : " + total);
        %>
    </body>
</html>
