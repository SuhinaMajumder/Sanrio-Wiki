<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Sanrio Friends Wiki</title>
    <style>
        body { 
            background-image: url('images/sanriobg.png');
            background-repeat: repeat;
            background-color: #fff0f5;
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
            font-size: 48px; 
            margin: 0;
        }
        h3 { 
            text-align: center; 
            color: #666; 
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
        .intro-box {
            background: #ffe4e1;
            padding: 25px;
            margin: 20px 0;
            border-radius: 20px;
            text-align: center;
            border: 2px solid #ff69b4;
        }
        .intro-box p {
            font-size: 18px;
            line-height: 1.8;
            color: #555;
            margin: 0;
        }
        .intro-box span {
            color: #ff69b4;
            font-weight: bold;
        }
        .marquee-box {
            background: #ffe4e1;
            padding: 30px 0;
            margin: 30px 0;
            border-top: 3px solid #ff69b4;
            border-bottom: 3px solid #ff69b4;
            overflow: hidden;
        }
        .marquee-content {
            display: flex;
            width: fit-content;
            animation: scroll 25s linear infinite;
        }
        .marquee-content:hover {
            animation-play-state: paused;
        }
        @keyframes scroll {
            0% { transform: translateX(0); }
            100% { transform: translateX(-50%); }
        }
        .character-card {
            width: 200px;
            margin: 0 20px;
            text-align: center;
            background: white;
            padding: 15px;
            border-radius: 15px;
            border: 2px solid #ff69b4;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .character-card img {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            border: 3px solid #ff69b4;
            object-fit: cover;
        }
        .character-card h3 {
            color: #ff69b4;
            margin: 10px 0 5px;
        }
        .logo-section {
            text-align: center;
            padding: 30px;
            background: #ff69b4;
            border-radius: 50px;
            margin: 30px 0;
        }
        .logo-section img {
            max-width: 300px;
        }
        .logo-section p {
            color: white;
            font-size: 20px;
        }
        .footer {
            text-align: center;
            padding: 20px;
            background: #333;
            color: white;
            border-radius: 50px;
        }
    </style>
</head>
<body>

<div class="container">
    <h1>Sanrio Friends Wiki</h1>
    <h3>Meet your favorite characters!</h3>
    
    <div class="navbar">
        <a href="sanrio.jsp">Home</a>
        <a href="sanrio-list.jsp">Gallery</a>
        <a href="calendar.jsp">Birthdays</a>
        <a href="series.jsp">Series</a>
        <a href="sanrio.jsp?action=showadd">Add Friend</a>
    </div>

    <div class="intro-box">
        <p>
            <span>Sanrio</span> is a Japanese company known for creating cute characters since 1974. 
            Their most famous character, <span>Hello Kitty</span>, has become a global icon of kawaii culture. 
            This wiki celebrates the wonderful world of Sanrio friends - from the classic Hello Kitty 
            and My Melody to newer favorites like Cinnamoroll and Gudetama. Each character has their 
            own unique personality, story, and special charm that brings joy to fans worldwide.
        </p>
    </div>

<%
Connection con = null;
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sanrio","root","Splendor@1970");
    
    String action = request.getParameter("action");
    
    if(action != null && action.equals("showadd")) {
%>
        <h2 style="text-align:center;">Add New Friend</h2>
        <form method="post" style="background:#f9f9f9; padding:20px; border-radius:10px;">
            <table align="center">
                <tr><td>Name:</td><td><input type="text" name="name" required></td></tr>
                <tr><td>Image:</td><td><input type="text" name="image_url" value="images/"></td></tr>
                <tr><td>Species:</td><td><input type="text" name="species"></td></tr>
                <tr><td>Birthday (text):</td><td><input type="text" name="birthday" placeholder="e.g., Nov 1"></td></tr>
                <tr><td>Birth Date (for calendar):</td><td><input type="date" name="birth_date"></td></tr>
                <tr><td>Description:</td><td><textarea name="description"></textarea></td></tr>
                <tr><td colspan="2" style="text-align:center;"><input type="submit" name="btnadd" value="Add"></td></tr>
            </table>
        </form>
<%
    }
    
    String btnadd = request.getParameter("btnadd");
    if(btnadd != null) {
        String name = request.getParameter("name");
        String image = request.getParameter("image_url");
        String species = request.getParameter("species");
        String bday = request.getParameter("birthday");
        String birthDate = request.getParameter("birth_date");
        String desc = request.getParameter("description");
        
        PreparedStatement ps = con.prepareStatement(
            "insert into characters(name,image_url,species,birthday,birth_date,description) values(?,?,?,?,?,?)"
        );
        ps.setString(1, name);
        ps.setString(2, image);
        ps.setString(3, species);
        ps.setString(4, bday);
        ps.setString(5, birthDate != null && !birthDate.equals("") ? birthDate : null);
        ps.setString(6, desc);
        ps.executeUpdate();
        out.println("<p style='color:green; text-align:center;'>Added!</p>");
    }
    
    Statement st = con.createStatement();
    ResultSet rs = st.executeQuery("select * from characters");
    List<Map<String,String>> characters = new ArrayList<>();
    while(rs.next()) {
        Map<String,String> ch = new HashMap<>();
        ch.put("name", rs.getString("name"));
        ch.put("image", rs.getString("image_url"));
        ch.put("species", rs.getString("species"));
        ch.put("birthday", rs.getString("birthday"));
        characters.add(ch);
    }
    rs.close();
%>

<div class="marquee-box">
    <div class="marquee-content">
        <% for(Map<String,String> ch : characters) { %>
            <div class="character-card">
                <img src="<%= ch.get("image") %>">
                <h3><%= ch.get("name") %></h3>
                <p><%= ch.get("species") %></p>
                <small><%= ch.get("birthday") %></small>
            </div>
        <% } %>
        <% for(Map<String,String> ch : characters) { %>
            <div class="character-card">
                <img src="<%= ch.get("image") %>">
                <h3><%= ch.get("name") %></h3>
                <p><%= ch.get("species") %></p>
                <small><%= ch.get("birthday") %></small>
            </div>
        <% } %>
    </div>
</div>

<div class="logo-section">
    <img src="images/sanriologo.png" alt="Sanrio Logo">
    <p>Welcome to Sanrio World!</p>
</div>

<%
} catch(Exception e) {
    out.println("<p style='color:red; text-align:center;'>Error: " + e.getMessage() + "</p>");
} finally {
    try { con.close(); } catch(Exception e) {}
}
%>

<div class="footer">
    Sanrio Friends Wiki
</div>

</div>
</body>
</html>