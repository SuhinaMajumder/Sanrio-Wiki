<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Character Details</title>
    <style>
        body { 
            background-image: url('images/sanriobg.png');
            background-repeat: repeat;
            font-family: Arial; 
            padding:20px; 
            margin:0;
        }
        .container { 
            background:white; 
            max-width:1000px; 
            margin:auto; 
            padding:20px; 
            border-radius:20px; 
            box-shadow:0 0 10px #ff69b4;
        }
        h1 { 
            color:#ff69b4; 
            text-align:center; 
        }
        .navbar { 
            background:#ff69b4; 
            padding:15px; 
            text-align:center; 
            border-radius:50px; 
            margin:20px 0; 
        }
        .navbar a { 
            color:white; 
            text-decoration:none; 
            margin:0 20px; 
            font-weight:bold; 
        }
        table { 
            width:100%; 
            border-collapse:collapse; 
            margin:20px 0; 
        }
        th { 
            background:#ff69b4; 
            color:white; 
            padding:10px; 
        }
        td { 
            padding:10px; 
            border-bottom:1px solid #ffe4e1; 
        }
        input, select, textarea { 
            padding:8px; 
            width:100%; 
            border:2px solid #ff69b4; 
            border-radius:25px; 
            margin:5px 0; 
            box-sizing:border-box;
        }
        .btn { 
            background:#ff69b4; 
            color:white; 
            padding:10px 30px; 
            border:none; 
            border-radius:25px; 
            cursor:pointer; 
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
    </style>
</head>
<body>
<div class="container">
    <h1>Character Details</h1>
 <div class="navbar">
    <a href="sanrio.jsp">Home</a>
    <a href="sanrio-list.jsp">Gallery</a>
    <a href="calendar.jsp">Birthdays</a>
    <a href="series.jsp">Series</a>
</div>

<%
String id = request.getParameter("id");
String factText = request.getParameter("factText");
String factCategory = request.getParameter("factCategory");
String addFact = request.getParameter("addFact");
String friendId = request.getParameter("friendId");
String relationship = request.getParameter("relationship");
String addFriend = request.getParameter("addFriend");
Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sanrio","root","Splendor@1970");
    if(addFact != null && factText != null && !factText.trim().equals("")) {
        ps = con.prepareStatement("insert into character_facts (character_id, fact_text, category) values (?, ?, ?)");
        ps.setInt(1, Integer.parseInt(id));
        ps.setString(2, factText);
        ps.setString(3, factCategory);
        ps.executeUpdate();
        response.sendRedirect("sanrio-details.jsp?id=" + id);
        return;
    }                                                                                                                                                         
    if(addFriend != null && friendId != null && !friendId.equals("") && relationship != null) {
        ps = con.prepareStatement("insert into character_friends (character1_id, character2_id, relationship) values (?, ?, ?)");
        ps.setInt(1, Integer.parseInt(id));
        ps.setInt(2, Integer.parseInt(friendId));
        ps.setString(3, relationship);
        ps.executeUpdate();
        response.sendRedirect("sanrio-details.jsp?id=" + id);
        return;
    }
    ps = con.prepareStatement("select * from characters where id=?");
    ps.setInt(1, Integer.parseInt(id));
    rs = ps.executeQuery();
    if(rs.next()) {
        String name = rs.getString("name");
%>
    <div style="text-align:center;">
        <img src="<%= rs.getString("image_url") %>" width="200" height="200" style="border-radius:50%; border:4px solid #ff69b4;">
        <h2><%= name %></h2>
        <p><b>Species:</b> <%= rs.getString("species") %></p>
        <p><b>Birthday:</b> <%= rs.getString("birthday") %></p>
        <p><i><%= rs.getString("description") %></i></p>
    </div>
    <h3>Fun Facts</h3>
    <form method="post" style="background:#f9f9f9; padding:15px; border-radius:10px; margin-bottom:20px;">
        <input type="hidden" name="id" value="<%= id %>">
        <table>
            <tr><td><input type="text" name="factCategory" placeholder="Category"></td>
                <td><input type="text" name="factText" placeholder="Enter new fact..." required></td>
                <td><input type="submit" name="addFact" value="Add Fact" class="btn"></td>
            </tr>
        </table>
    </form>
    <table border="1">
        <tr><th>Category</th><th>Fact</th></tr>
<%
        ps = con.prepareStatement("select * from character_facts where character_id=?");
        ps.setInt(1, Integer.parseInt(id));
        ResultSet rs2 = ps.executeQuery();
        boolean hasFacts = false;
        while(rs2.next()) {
            hasFacts = true;
%>
        <tr><td><%= rs2.getString("category") %></td><td><%= rs2.getString("fact_text") %></td></tr>
<%
        }
        if(!hasFacts) { out.println("<tr><td colspan='2' style='text-align:center;'>No facts yet</td></tr>"); }
        rs2.close();
%>
    </table>
    <h3>Add Friend Relationship</h3>
    <form method="post" style="background:#f9f9f9; padding:15px; border-radius:10px; margin:20px 0;">
        <input type="hidden" name="id" value="<%= id %>">
        <table>
            <tr>
                <td><select name="friendId" required style="width:100%; padding:8px;">
                    <option value="">Select Friend</option>
<%
                    Statement st = con.createStatement();
                    ResultSet rsFriends = st.executeQuery("select id, name from characters where id !=" + id + " order by name");
                    while(rsFriends.next()) {
%>
                    <option value="<%= rsFriends.getInt("id") %>"><%= rsFriends.getString("name") %></option>
<%
                    }
                    rsFriends.close();
%>
                </select></td>
                <td><input type="text" name="relationship" placeholder="e.g., Best Friends, Rivals" required></td>
                <td><input type="submit" name="addFriend" value="Add Friend" class="btn"></td>
            </tr>
        </table>
    </form>
    <h3>Friends</h3>
    <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 15px; padding: 10px;">
<%
        ps = con.prepareStatement(
            "SELECT c.id, c.name, c.image_url, c.species, c.birthday, cf.relationship FROM character_friends cf " +
            "JOIN characters c ON cf.character2_id = c.id WHERE cf.character1_id = ? " +
            "UNION " +
            "SELECT c.id, c.name, c.image_url, c.species, c.birthday, cf.relationship FROM character_friends cf " +
            "JOIN characters c ON cf.character1_id = c.id WHERE cf.character2_id = ?");
        ps.setInt(1, Integer.parseInt(id));
        ps.setInt(2, Integer.parseInt(id));
        ResultSet rs3 = ps.executeQuery();
        boolean hasFriends = false;
        while(rs3.next()) {
            hasFriends = true;
%>
        <div class="friend-card">
            <img src="<%= rs3.getString("image_url") %>">
            <h4 style="color:#ff69b4;"><%= rs3.getString("name") %></h4>
            <p><b><%= rs3.getString("species") %></b></p>
            <p><small>Birthday: <%= rs3.getString("birthday") %></small></p>
            <p style="font-style:italic;">Relationship: <%= rs3.getString("relationship") %></p>
            <a href="sanrio-details.jsp?id=<%= rs3.getInt("id") %>" style="background:#9370db; color:white; padding:5px 15px; border-radius:20px; text-decoration:none; display:inline-block; margin-top:10px;">View</a>
        </div>
<%
        }
        if(!hasFriends) { out.println("<p style='text-align:center;'>No friends yet</p>"); }
        rs3.close();
%>
    </div>
    <div style="text-align:center; margin:20px;">
        <a href="sanrio-list.jsp" style="background:#ff69b4; color:white; padding:10px 30px; border-radius:25px; text-decoration:none;">Back to Gallery</a>
    </div>
    <h3>📺 Series Appearances</h3>
<%
ps = con.prepareStatement(
    "SELECT s.series_name, s.debut_year FROM series s " +
    "JOIN character_series cs ON s.series_id = cs.series_id " +
    "WHERE cs.character_id = ?"
);
ps.setInt(1, Integer.parseInt(id));
ResultSet rsSeries = ps.executeQuery();
boolean hasSeries = false;
while(rsSeries.next()) {
    hasSeries = true;
%>
    <div style="background:#ffe4e1; padding:10px; margin:5px; border-radius:15px; display:inline-block;">
        <%= rsSeries.getString("series_name") %> (<%= rsSeries.getInt("debut_year") %>)
    </div>
<%
}
if(!hasSeries) {
    out.println("<p>No series assigned</p>");
}
rsSeries.close();
%>
<%
    }
} catch(Exception e) {
    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
} finally {
    try { if(rs != null) rs.close(); } catch(Exception e) {}
    try { if(ps != null) ps.close(); } catch(Exception e) {}
    try { if(con != null) con.close(); } catch(Exception e) {}
}
%>
    <div style="text-align:center; margin:20px 0;">
        <img src="images/sanriologo.png" alt="Sanrio Logo" style="max-width:200px;">
    </div>

</div>
</body>
</html>