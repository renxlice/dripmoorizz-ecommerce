<%-- 
    Document   : postmethod
    Created on : Mar 26, 2025, 1:52:37 PM
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
        <h1>Using POST Method to Read Form Data</h1>
        
        <ul>
            <li><p><b>First Name:</b>
                <%= request.getParameter("first_name")%>
            </p></li>
            <li><P><b>Last Name:</b>
                <%= request.getParameter("last_name")%>
            </P></li>
        </ul>
    </center>
    </body>
</html>
