<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Character</title>
    <style>
        body { 
            background-image: url('images/sanriobg.png');
            background-repeat: repeat;
            font-family: Arial; 
            margin: 0; 
            padding: 20px; 
        }
        .container { 
            background: white; 
            max-width: 800px; 
            margin: 0 auto; 
            padding: 30px; 
            border-radius: 20px; 
            box-shadow: 0 0 10px #ff69b4;
        }
        h1 { 
            color: #ff69b4; 
            text-align: center; 
        }
        .navbar { 
            background: #ff69b4; 
            padding: 15px; 
            text-align: center; 
            border-radius: 50px; 
            margin: 20px 0; 
        }
        .navbar a { 
            color: white; 
            text-decoration: none; 
            margin: 0 20px; 
            font-weight: bold; 
        }
        form {
            background: #f9f9f9;
            padding: 30px;
            border-radius: 15px;
            border: 2px solid #ff69b4;
            margin: 20px 0;
        }
        table {
            width: 100%;
        }
        td {
            padding: 10px;
        }
        input[type="text"], input[type="date"], textarea {
            width: 100%;
            padding: 10px;
            border: 2px solid #ff69b4;
            border-radius: 25px;
            box-sizing: border-box;
        }
        textarea {
            height: 100px;
        }
        input[type="submit"], .cancel-btn {
            background: #ff69b4;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 25px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
            text-decoration: none;
            display: inline-block;
        }
        .cancel-btn {
            background: #999;
            margin-left: 10px;
        }
        .preview-img {
            text-align: center;
            margin: 20px 0;
        }
        .preview-img img {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            border: 4px solid #ff69b4;
            object-fit: cover;
        }
        .back-link {
            display: block;
            text-align: center;
            margin-top: 20px;
            color: #ff69b4;
            text-decoration: none;
        }
        small {
            color: #666;
            font-size: 12px;
        }
    </style>
</head>
<body>

<div class="container">
    <h1>Edit Character</h1>
    
    <div class="navbar">
        <a href="sanrio.jsp">Home</a>
        <a href="sanrio-list.jsp">Gallery</a>
        <a href="calendar.jsp">Birthdays</a>
        <a href="series.jsp">Series</a>
        <a href="sanrio.jsp?action=showadd">Add New Friend</a>
    </div>

<%
String id = request.getParameter("id");
String btnupdate = request.getParameter("btnupdate");

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sanrio","root","Splendor@1970");
    
    if(btnupdate != null) {
        String name = request.getParameter("name");
        String image = request.getParameter("image_url");
        String species = request.getParameter("species");
        String bday = request.getParameter("birthday");
        String birthDate = request.getParameter("birth_date");
        String desc = request.getParameter("description");
        String pid = request.getParameter("id");
        
        ps = con.prepareStatement(
            "update characters set name=?, image_url=?, species=?, birthday=?, birth_date=?, description=? where id=?"
        );
        ps.setString(1, name);
        ps.setString(2, image);
        ps.setString(3, species);
        ps.setString(4, bday);
        ps.setString(5, birthDate != null && !birthDate.equals("") ? birthDate : null);
        ps.setString(6, desc);
        ps.setInt(7, Integer.parseInt(pid));
        ps.executeUpdate();
        
        response.sendRedirect("sanrio-list.jsp");
        return;
    }
    
    if(id != null) {
        ps = con.prepareStatement("select * from characters where id=?");
        ps.setInt(1, Integer.parseInt(id));
        rs = ps.executeQuery();
        
        if(rs.next()) {
            String name = rs.getString("name");
            String image = rs.getString("image_url");
            String species = rs.getString("species");
            String bday = rs.getString("birthday");
            String birthDate = "";
            if(rs.getDate("birth_date") != null) {
                birthDate = rs.getDate("birth_date").toString();
            }
            String desc = rs.getString("description");
%>

    <div class="preview-img">
        <img src="<%= image %>" alt="<%= name %>">
    </div>

    <form action="sanrio-edit.jsp" method="post">
        <input type="hidden" name="id" value="<%= id %>">
        <table>
            <tr><td><b>Name:</b></td><td><input type="text" name="name" value="<%= name %>" required></td></tr>
            <tr><td><b>Image URL:</b></td><td><input type="text" name="image_url" value="<%= image %>"></td></tr>
            <tr><td><b>Species:</b></td><td><input type="text" name="species" value="<%= species != null ? species : "" %>"></td></tr>
            <tr><td><b>Birthday (text):</b></td><td><input type="text" name="birthday" value="<%= bday != null ? bday : "" %>" placeholder="e.g., Nov 1"></td></tr>
            <tr><td><b>Birth Date (for calendar):</b></td>
                <td>
                    <input type="date" name="birth_date" value="<%= birthDate %>">
                    <small>Select actual date for calendar</small>
                </td>
            </tr>
            <tr><td><b>Description:</b></td><td><textarea name="description"><%= desc != null ? desc : "" %></textarea></td></tr>
            <tr><td colspan="2" style="text-align: center;">
                <input type="submit" name="btnupdate" value="Update Character">
                <a href="sanrio-list.jsp" class="cancel-btn">Cancel</a>
            </td></tr>
        </table>
    </form>

<%
        } else {
            out.println("<p style='text-align:center; color:red;'>Character not found!</p>");
        }
    } else {
        out.println("<p style='text-align:center; color:red;'>No character ID provided!</p>");
    }
} catch(Exception e) {
    out.println("<p style='color:red; text-align:center;'>Error: " + e.getMessage() + "</p>");
} finally {
    try { if(rs != null) rs.close(); } catch(Exception e) {}
    try { if(ps != null) ps.close(); } catch(Exception e) {}
    try { if(con != null) con.close(); } catch(Exception e) {}
}
%>

    <a href="sanrio-list.jsp" class="back-link">← Back to Gallery</a>

</div>
</body>
</html>