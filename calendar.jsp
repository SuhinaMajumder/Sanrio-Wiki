<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Sanrio Birthday Calendar</title>
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
        .month-selector {
            text-align: center;
            margin: 30px 0;
        }
        .month-selector select, .month-selector input {
            padding: 10px;
            border: 2px solid #ff69b4;
            border-radius: 25px;
            font-size: 16px;
        }
        .month-selector input {
            background: #ff69b4;
            color: white;
            cursor: pointer;
        }
        .calendar-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 10px;
            margin: 30px 0;
        }
        .day-header {
            background: #ff69b4;
            color: white;
            padding: 15px;
            text-align: center;
            font-weight: bold;
            border-radius: 10px;
        }
        .calendar-day {
            background: #ffe4e1;
            min-height: 100px;
            padding: 10px;
            border-radius: 10px;
            border: 2px solid #ff69b4;
        }
        .day-number {
            font-weight: bold;
            color: #ff69b4;
            margin-bottom: 5px;
        }
        .birthday-item {
            background: white;
            border-radius: 15px;
            padding: 5px;
            margin: 5px 0;
            text-align: center;
            border: 1px solid #ff69b4;
            font-size: 12px;
        }
        .birthday-item img {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            vertical-align: middle;
        }
        .birthday-item a {
            text-decoration: none;
            color: #ff69b4;
            font-weight: bold;
        }
        .upcoming-section {
            background: #ffe4e1;
            padding: 20px;
            border-radius: 15px;
            margin: 30px 0;
            border: 2px solid #ff69b4;
        }
        .upcoming-card {
            display: inline-block;
            width: 150px;
            margin: 10px;
            text-align: center;
            background: white;
            padding: 15px;
            border-radius: 15px;
            border: 2px solid #ff69b4;
        }
        .upcoming-card img {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            border: 3px solid #ff69b4;
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
    <h1>Sanrio Birthday Calendar</h1>
    
    <div class="navbar">
        <a href="sanrio.jsp">Home</a>
        <a href="sanrio-list.jsp">Gallery</a>
        <a href="calendar.jsp">Birthdays</a>
        <a href="sanrio.jsp?action=showadd">Add Friend</a>
        <a href="series.jsp">Series</a>
    </div>

<%
String monthParam = request.getParameter("month");
int selectedMonth;
if(monthParam != null && !monthParam.equals("")) {
    selectedMonth = Integer.parseInt(monthParam);
} else {
    Calendar cal = Calendar.getInstance();
    selectedMonth = cal.get(Calendar.MONTH) + 1;
}

String[] monthNames = {"January", "February", "March", "April", "May", "June", 
                       "July", "August", "September", "October", "November", "December"};
String[] dayNames = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sanrio","root","Splendor@1970");
%>

<div class="month-selector">
    <form method="get" action="calendar.jsp">
        <select name="month">
            <% for(int i=1; i<=12; i++) { %>
                <option value="<%= i %>" <%= (i == selectedMonth) ? "selected" : "" %>>
                    <%= monthNames[i-1] %>
                </option>
            <% } %>
        </select>
        <input type="submit" value="View Month">
        <a href="calendar.jsp" style="padding:10px 20px; background:#ccc; color:black; border-radius:25px; text-decoration:none; margin-left:10px;">Current Month</a>
    </form>
</div>

<h2 style="color:#ff69b4; text-align:center;"><%= monthNames[selectedMonth-1] %> Birthdays</h2>

<%
    Calendar cal = Calendar.getInstance();
    cal.set(Calendar.MONTH, selectedMonth - 1);
    cal.set(Calendar.DAY_OF_MONTH, 1);
    int firstDayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
    int daysInMonth = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
    int startDay = (firstDayOfWeek == 1) ? 0 : firstDayOfWeek - 1;
%>

<div class="calendar-grid">
    <% for(String day : dayNames) { %>
        <div class="day-header"><%= day %></div>
    <% } %>
    
    <% for(int i=0; i<startDay; i++) { %>
        <div class="calendar-day" style="background: #f9f9f9;"></div>
    <% } %>
    
    <% for(int day=1; day<=daysInMonth; day++) { %>
        <div class="calendar-day">
            <div class="day-number"><%= day %></div>
            
            <% 
            ps = con.prepareStatement(
                "SELECT id, name, image_url, birthday FROM characters " +
                "WHERE MONTH(birth_date) = ? AND DAY(birth_date) = ? " +
                "ORDER BY name"
            );
            ps.setInt(1, selectedMonth);
            ps.setInt(2, day);
            ResultSet rs2 = ps.executeQuery();
            
            while(rs2.next()) { %>
                <div class="birthday-item">
                    <img src="<%= rs2.getString("image_url") %>" alt="<%= rs2.getString("name") %>">
                    <a href="sanrio-details.jsp?id=<%= rs2.getInt("id") %>">
                        <%= rs2.getString("name") %>
                    </a>
                    <div style="font-size:10px;"><%= rs2.getString("birthday") %></div>
                </div>
            <% }
            rs2.close(); %>
        </div>
    <% } %>
</div>

<div class="upcoming-section">
    <h3 style="color:#ff69b4; text-align:center;">Upcoming Birthdays (Next 30 Days)</h3>
    <div style="text-align:center;">
<%
    java.util.Date today = new java.util.Date();
    Calendar todayCal = Calendar.getInstance();
    todayCal.setTime(today);
    
    Calendar futureCal = Calendar.getInstance();
    futureCal.setTime(today);
    futureCal.add(Calendar.DAY_OF_MONTH, 30);
    
    ps = con.prepareStatement(
        "SELECT id, name, image_url, birthday, birth_date FROM characters " +
        "WHERE birth_date IS NOT NULL " +
        "ORDER BY DATE_FORMAT(birth_date, '%m-%d')"
    );
    rs = ps.executeQuery();
    
    List<Map<String,Object>> upcoming = new ArrayList<>();
    while(rs.next()) {
        java.sql.Date birthDate = rs.getDate("birth_date");
        if(birthDate != null) {
            Calendar birthCal = Calendar.getInstance();
            birthCal.setTime(birthDate);
            
            Calendar thisYearBirth = Calendar.getInstance();
            thisYearBirth.set(Calendar.MONTH, birthCal.get(Calendar.MONTH));
            thisYearBirth.set(Calendar.DAY_OF_MONTH, birthCal.get(Calendar.DAY_OF_MONTH));
            
            if(thisYearBirth.before(todayCal)) {
                thisYearBirth.add(Calendar.YEAR, 1);
            }
            
            if(!thisYearBirth.after(futureCal)) {
                Map<String,Object> bday = new HashMap<>();
                bday.put("id", rs.getInt("id"));
                bday.put("name", rs.getString("name"));
                bday.put("image", rs.getString("image_url"));
                bday.put("birthday", rs.getString("birthday"));
                bday.put("date", thisYearBirth.getTime());
                upcoming.add(bday);
            }
        }
    }
    
    Collections.sort(upcoming, new Comparator<Map<String,Object>>() {
        public int compare(Map<String,Object> a, Map<String,Object> b) {
            return ((java.util.Date)a.get("date")).compareTo((java.util.Date)b.get("date"));
        }
    });
    
    int count = 0;
    for(Map<String,Object> bday : upcoming) {
        if(count++ >= 6) break;
        java.util.Date bdayDate = (java.util.Date)bday.get("date");
        SimpleDateFormat sdf = new SimpleDateFormat("MMM d");
%>
        <div class="upcoming-card">
            <img src="<%= bday.get("image") %>" alt="<%= bday.get("name") %>">
            <h4 style="color:#ff69b4;"><%= bday.get("name") %></h4>
            <p><%= sdf.format(bdayDate) %></p>
            <p><small><%= bday.get("birthday") %></small></p>
            <a href="sanrio-details.jsp?id=<%= bday.get("id") %>" 
               style="background:#9370db; color:white; padding:5px 10px; border-radius:20px; text-decoration:none; font-size:12px;">View</a>
        </div>
<%
    }
    if(upcoming.isEmpty()) {
        out.println("<p>No upcoming birthdays in the next 30 days.</p>");
    }
%>
    </div>
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

    <div style="text-align:center; margin:20px 0;">
        <img src="images/sanriologo.png" alt="Sanrio Logo" style="max-width:300px;">
    </div>

    <div class="footer">
        Sanrio Friends Wiki - Birthday Calendar
    </div>
</div>
</body>
</html>