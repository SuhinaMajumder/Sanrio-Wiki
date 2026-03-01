<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Sanrio Series & Categories</title>
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
        .series-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        .series-card {
            background: #ffe4e1;
            border-radius: 15px;
            padding: 20px;
            border: 2px solid #ff69b4;
        }
        .series-card h2 {
            color: #ff69b4;
            margin-top: 0;
        }
        .character-list {
            list-style: none;
            padding: 0;
        }
        .character-list li {
            background: white;
            margin: 5px 0;
            padding: 8px;
            border-radius: 25px;
            border: 1px solid #ff69b4;
        }
        .character-list img {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            vertical-align: middle;
            margin-right: 10px;
        }
        .add-form {
            background: #f9f9f9;
            padding: 20px;
            border-radius: 15px;
            margin: 20px 0;
        }
        input, select {
            padding: 8px;
            border: 2px solid #ff69b4;
            border-radius: 25px;
            margin: 5px;
        }
        .btn {
            background: #ff69b4;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 25px;
            cursor: pointer;
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
    <h1>Sanrio Series & Categories</h1>
    
    <div class="navbar">
        <a href="sanrio.jsp">Home</a>
        <a href="sanrio-list.jsp">Gallery</a>
        <a href="calendar.jsp">Birthdays</a>
        <a href="series.jsp">Series</a>
        <a href="sanrio.jsp?action=showadd">Add Friend</a>
    </div>

<%
Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sanrio","root","Splendor@1970");
    
    // Handle Add Series Form
    String addSeries = request.getParameter("addSeries");
    if(addSeries != null) {
        String seriesName = request.getParameter("seriesName");
        String debutYear = request.getParameter("debutYear");
        
        ps = con.prepareStatement("INSERT INTO series (series_name, debut_year) VALUES (?, ?)");
        ps.setString(1, seriesName);
        ps.setInt(2, Integer.parseInt(debutYear));
        ps.executeUpdate();
        response.sendRedirect("series.jsp");
        return;
    }
    
    // Handle Assign Character to Series
    String assignSeries = request.getParameter("assignSeries");
    if(assignSeries != null) {
        int charId = Integer.parseInt(request.getParameter("characterId"));
        int seriesId = Integer.parseInt(request.getParameter("seriesId"));
        
        ps = con.prepareStatement("INSERT INTO character_series (character_id, series_id) VALUES (?, ?)");
        ps.setInt(1, charId);
        ps.setInt(2, seriesId);
        ps.executeUpdate();
        response.sendRedirect("series.jsp");
        return;
    }
%>

<!-- Add New Series Form -->
<div class="add-form">
    <h3 style="color:#ff69b4;">Add New Series</h3>
    <form method="post" style="display: inline;">
        <input type="text" name="seriesName" placeholder="Series Name" required>
        <input type="number" name="debutYear" placeholder="Debut Year" required>
        <input type="submit" name="addSeries" value="Add Series" class="btn">
    </form>
</div>

<!-- Assign Character to Series Form -->
<div class="add-form">
    <h3 style="color:#ff69b4;">Assign Character to Series</h3>
    <form method="post">
        <select name="characterId" required>
            <option value="">Select Character</option>
            <%
            Statement st = con.createStatement();
            rs = st.executeQuery("SELECT id, name FROM characters ORDER BY name");
            while(rs.next()) {
            %>
                <option value="<%= rs.getInt("id") %>"><%= rs.getString("name") %></option>
            <%
            }
            rs.close();
            %>
        </select>
        
        <select name="seriesId" required>
            <option value="">Select Series</option>
            <%
            rs = st.executeQuery("SELECT series_id, series_name FROM series ORDER BY series_name");
            while(rs.next()) {
            %>
                <option value="<%= rs.getInt("series_id") %>"><%= rs.getString("series_name") %></option>
            <%
            }
            rs.close();
            %>
        </select>
        
        <input type="submit" name="assignSeries" value="Assign" class="btn">
    </form>
</div>

<!-- Display All Series -->
<h2 style="color:#ff69b4;">All Series</h2>

<div class="series-grid">
<%
    rs = st.executeQuery("SELECT * FROM series ORDER BY debut_year");
    
    while(rs.next()) {
        int seriesId = rs.getInt("series_id");
        String seriesName = rs.getString("series_name");
        int debutYear = rs.getInt("debut_year");
%>
    <div class="series-card">
        <h2><%= seriesName %> (<%= debutYear %>)</h2>
        
        <h4>Characters in this series:</h4>
        <ul class="character-list">
        <%
        ps = con.prepareStatement(
            "SELECT c.id, c.name, c.image_url FROM characters c " +
            "JOIN character_series cs ON c.id = cs.character_id " +
            "WHERE cs.series_id = ? ORDER BY c.name"
        );
        ps.setInt(1, seriesId);
        ResultSet rs2 = ps.executeQuery();
        
        boolean hasChars = false;
        while(rs2.next()) {
            hasChars = true;
        %>
            <li>
                <img src="<%= rs2.getString("image_url") %>">
                <a href="sanrio-details.jsp?id=<%= rs2.getInt("id") %>"><%= rs2.getString("name") %></a>
            </li>
        <%
        }
        if(!hasChars) {
            out.println("<li>No characters assigned yet</li>");
        }
        rs2.close();
        %>
        </ul>
    </div>
<%
    }
%>
</div>

<%
} catch(Exception e) {
    out.println("<p style='color:red; text-align:center;'>Error: " + e.getMessage() + "</p>");
} finally {
    try { if(rs != null) rs.close(); } catch(Exception e) {}
    try { if(ps != null) ps.close(); } catch(Exception e) {}
    try { if(con != null) con.close(); } catch(Exception e) {}
}
%>

    <div class="footer">
        Sanrio Friends Wiki - Series
    </div>
</div>
</body>
</html>