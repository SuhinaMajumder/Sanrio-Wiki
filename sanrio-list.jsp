<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Sanrio Friends Gallery</title>
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
            max-width: 1200px; 
            margin: 0 auto; 
            padding: 20px; 
            border-radius: 20px; 
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
        .search-box {
            text-align: center;
            margin: 20px 0;
        }
        .search-box input[type="text"] {
            padding: 10px;
            width: 300px;
            border: 2px solid #ff69b4;
            border-radius: 25px;
        }
        .search-box input[type="submit"] {
            padding: 10px 30px;
            background: #ff69b4;
            color: white;
            border: none;
            border-radius: 25px;
            cursor: pointer;
        }
        .grid-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
            padding: 20px;
        }
        .character-card {
            background: white;
            border-radius: 15px;
            padding: 15px;
            text-align: center;
            border: 2px solid #ff69b4;
            box-shadow: 0 4px 8px rgba(255,105,180,0.2);
        }
        .character-card img {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            border: 3px solid #ff69b4;
            object-fit: cover;
        }
        .btn {
            padding: 8px 15px;
            border-radius: 20px;
            text-decoration: none;
            margin: 5px;
            display: inline-block;
        }
        .btn-green { background: #4CAF50; color: white; }
        .btn-purple { background: #9370db; color: white; }
        .friends-section {
            background: #ffe4e1;
            padding: 20px;
            border-radius: 15px;
            margin: 20px 0;
            border: 2px solid #ff69b4;
        }
        .friend-card {
            background: white;
            border-radius: 15px;
            padding: 15px;
            text-align: center;
            border: 2px solid #ff69b4;
            box-shadow: 0 4px 8px rgba(255,105,180,0.2);
        }
        .friend-card img {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            border: 3px solid #ff69b4;
            object-fit: cover;
        }
        .footer {
            text-align: center;
            padding: 20px;
            background: #333;
            color: white;
            border-radius: 50px;
            margin-top: 30px;
        }
    </style>
</head>
<body>

<div class="container">
    <h1>Sanrio Friends Gallery</h1>
    
      <div class="navbar">
        <a href="sanrio.jsp">Home</a>
        <a href="sanrio-list.jsp">Gallery</a>
        <a href="calendar.jsp">Birthdays</a>
        <a href="series.jsp">Series</a>
        <a href="sanrio.jsp?action=showadd">Add Friend</a>
    </div>

<%
String search = request.getParameter("search");
Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sanrio","root","Splendor@1970");
%>

<div class="search-box">
    <form method="get" action="sanrio-list.jsp">
        <input type="text" name="search" placeholder="Search character..." value="<%= search!=null?search:"" %>">
        <input type="submit" value="Search">
        <a href="sanrio-list.jsp" style="padding:10px 20px; background:#ccc; color:black; border-radius:25px; text-decoration:none; margin-left:10px;">Clear</a>
    </form>
</div>
<%
    String query = "SELECT * FROM characters ORDER BY name";
    if(search != null && !search.trim().equals("")) {
        query = "SELECT * FROM characters WHERE name LIKE '%" + search + "%' ORDER BY name";
    }
    rs = con.createStatement().executeQuery(query);
%>
<div class="grid-container">
<%
    boolean hasResults = false;
    while(rs.next()) {
        hasResults = true;
%>
    <div class="character-card">
        <img src="<%= rs.getString("image_url") %>" alt="<%= rs.getString("name") %>">
        <h3 style="color:#ff69b4;"><%= rs.getString("name") %></h3>
        <p><b><%= rs.getString("species") != null ? rs.getString("species") : "" %></b></p>
        <p><small>Birthday: <%= rs.getString("birthday") != null ? rs.getString("birthday") : "Unknown" %></small></p>
        <p><i><%= rs.getString("description") != null ? rs.getString("description") : "" %></i></p>
        <div>
            <a href="sanrio-edit.jsp?id=<%= rs.getInt("id") %>" class="btn btn-green">Edit</a>
            <a href="sanrio-details.jsp?id=<%= rs.getInt("id") %>" class="btn btn-purple">Details</a>
        </div>
    </div>
<%
    }
    if(!hasResults) {
        out.println("<p style='text-align:center;'>No characters found</p>");
    }
    rs.close();
%>
</div>

<%
    if(search != null && !search.trim().equals("")) {
        ps = con.prepareStatement("SELECT id FROM characters WHERE name LIKE ?");
        ps.setString(1, "%" + search + "%");
        rs = ps.executeQuery();
        
        if(rs.next()) {
            int charId = rs.getInt("id");
            rs.close();
%>
            <div class="friends-section">
                <h3 style="color:#ff69b4; text-align:center;">Friends of <%= search %></h3>
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 15px; padding: 10px;">
<%
            ps = con.prepareStatement(
                "SELECT c.id, c.name, c.image_url, c.species, c.birthday, cf.relationship FROM character_friends cf " +
                "JOIN characters c ON cf.character2_id = c.id WHERE cf.character1_id = ? " +
                "UNION " +
                "SELECT c.id, c.name, c.image_url, c.species, c.birthday, cf.relationship FROM character_friends cf " +
                "JOIN characters c ON cf.character1_id = c.id WHERE cf.character2_id = ?");
            ps.setInt(1, charId);
            ps.setInt(2, charId);
            ResultSet rs3 = ps.executeQuery();
            
            boolean hasFriends = false;
            while(rs3.next()) {
                hasFriends = true;
%>
                    <div class="friend-card">
                        <img src="<%= rs3.getString("image_url") %>" alt="<%= rs3.getString("name") %>">
                        <h4 style="color:#ff69b4; margin:10px 0 5px;"><%= rs3.getString("name") %></h4>
                        <p style="margin:5px 0;"><b><%= rs3.getString("species") %></b></p>
                        <p style="margin:5px 0;"><small>Birthday: <%= rs3.getString("birthday") != null ? rs3.getString("birthday") : "Unknown" %></small></p>
                        <p style="margin:5px 0; font-style:italic; color:#666;">Relationship: <%= rs3.getString("relationship") %></p>
                        <div style="margin-top:10px;">
                            <a href="sanrio-details.jsp?id=<%= rs3.getInt("id") %>" 
                               style="background:#9370db; color:white; padding:5px 15px; border-radius:20px; text-decoration:none; font-size:12px;">View Details</a>
                        </div>
                    </div>
<%
            }
            if(!hasFriends) {
                out.println("<p style='text-align:center;'>No friends listed</p>");
            }
            rs3.close();
%>
                </div>
            </div>
<%
        }
    }
%>
<%
} catch(Exception e) {
    out.println("<div style='color:red; text-align:center; padding:20px; background:#ffebee; margin:20px;'>Error: " + e.getMessage() + "</div>");
} finally {
    try { if(rs != null) rs.close(); } catch(Exception e) {}
    try { if(ps != null) ps.close(); } catch(Exception e) {}
    try { if(con != null) con.close(); } catch(Exception e) {}
}
%>

    <div style="text-align:center; margin:30px 0;">
        <img src="images/sanriologo.png" alt="Sanrio Logo" style="max-width:300px;">
    </div>

    <div class="footer">
        Sanrio Friends Wiki
    </div>

</div>
</body>
</html>