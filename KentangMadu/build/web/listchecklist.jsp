<%-- 
    Document   : listchecklist
    Created on : Mar 26, 2025, 3:34:49 PM
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
       <center>
        <h1>Using POST Method to Read Form Data Mahasigma</h1>
        
        <ul>
            <li><p><b>NIM:</b>
                <%= request.getParameter("nim")%>
            </p></li>
            <li><P><b>Nama:</b>
                <%= request.getParameter("nama")%>
            </P></li>
            <li><P><b>Jenis Kelamin:</b>
                <%= request.getParameter("jenis_kelamin")%>
            </P></li>
            <li><P><b>Tanggal Lahir:</b>
                <%= request.getParameter("tanggal")%>
            </P></li>
            <li><P><b>Bulan:</b>
                <%= request.getParameter("bulan")%>
            </P></li>
            <li><P><b>Tahun:</b>
                <%= request.getParameter("tahun")%>
            </P></li>
            <li><P><b>Tempat Lahir:</b>
                <%= request.getParameter("tempat_lahir")%>
            </P></li>
            <li><P><b>Jurusan:</b>
                <%= request.getParameter("jurusan")%>
            </P></li>
            <li><P><b>Tahun Masuk:</b>
                <%= request.getParameter("tahun_masuk")%>
            </P></li>
        </ul>
    </center>
    </body>
</html>
