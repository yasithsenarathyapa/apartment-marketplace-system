package com.project.servlet;

import com.project.DAO.AdminDAO;
import com.project.model.Admin;
import com.project.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/AdminDiagnosticServlet")
public class AdminDiagnosticServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Admin Login Diagnostic</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; margin: 20px; }");
        out.println(".success { color: green; background: #d4edda; padding: 10px; border-radius: 5px; margin: 5px 0; }");
        out.println(".error { color: red; background: #f8d7da; padding: 10px; border-radius: 5px; margin: 5px 0; }");
        out.println(".info { color: blue; background: #d1ecf1; padding: 10px; border-radius: 5px; margin: 5px 0; }");
        out.println("</style></head><body>");
        
        out.println("<h1>🔍 Admin Login Diagnostic</h1>");
        
        // Test 1: Database Connection
        out.println("<h2>1. Database Connection Test</h2>");
        try (Connection conn = DBUtil.getConnection()) {
            out.println("<div class='success'>✅ Database connection successful</div>");
            out.println("<p>Database: Apartment_05</p>");
            out.println("<p>Connection URL: jdbc:sqlserver://localhost:1433;databaseName=Apartment_05</p>");
        } catch (Exception e) {
            out.println("<div class='error'>❌ Database connection failed: " + e.getMessage() + "</div>");
            out.println("</body></html>");
            return;
        }
        
        // Test 2: Check if admins table exists
        out.println("<h2>2. Admins Table Check</h2>");
        try (Connection conn = DBUtil.getConnection()) {
            String checkTableSql = "SELECT COUNT(*) FROM admins";
            try (PreparedStatement stmt = conn.prepareStatement(checkTableSql)) {
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    int count = rs.getInt(1);
                    out.println("<div class='success'>✅ Admins table exists with " + count + " records</div>");
                }
            }
        } catch (SQLException e) {
            out.println("<div class='error'>❌ Admins table check failed: " + e.getMessage() + "</div>");
        }
        
        // Test 3: Check admin records
        out.println("<h2>3. Admin Records Check</h2>");
        try (Connection conn = DBUtil.getConnection()) {
            String selectSql = "SELECT adminId, username, email, firstName, lastName, isActive FROM admins";
            try (PreparedStatement stmt = conn.prepareStatement(selectSql)) {
                ResultSet rs = stmt.executeQuery();
                out.println("<table border='1' style='border-collapse: collapse; width: 100%;'>");
                out.println("<tr><th>Admin ID</th><th>Username</th><th>Email</th><th>Name</th><th>Active</th></tr>");
                boolean hasRecords = false;
                while (rs.next()) {
                    hasRecords = true;
                    out.println("<tr>");
                    out.println("<td>" + rs.getString("adminId") + "</td>");
                    out.println("<td>" + rs.getString("username") + "</td>");
                    out.println("<td>" + rs.getString("email") + "</td>");
                    out.println("<td>" + rs.getString("firstName") + " " + rs.getString("lastName") + "</td>");
                    out.println("<td>" + (rs.getBoolean("isActive") ? "Yes" : "No") + "</td>");
                    out.println("</tr>");
                }
                out.println("</table>");
                if (!hasRecords) {
                    out.println("<div class='error'>❌ No admin records found in database</div>");
                }
            }
        } catch (SQLException e) {
            out.println("<div class='error'>❌ Failed to query admin records: " + e.getMessage() + "</div>");
        }
        
        // Test 4: Test admin authentication
        out.println("<h2>4. Admin Authentication Test</h2>");
        try {
            AdminDAO adminDAO = new AdminDAO();
            Admin admin = adminDAO.authenticateAdmin("admin", "admin123");
            if (admin != null) {
                out.println("<div class='success'>✅ Admin authentication successful</div>");
                out.println("<p>Authenticated Admin: " + admin.getUsername() + " (" + admin.getFullName() + ")</p>");
            } else {
                out.println("<div class='error'>❌ Admin authentication failed</div>");
                out.println("<p>Username: admin, Password: admin123</p>");
            }
        } catch (Exception e) {
            out.println("<div class='error'>❌ Admin authentication test failed: " + e.getMessage() + "</div>");
        }
        
        // Test 5: Check if admin is active
        out.println("<h2>5. Active Admin Check</h2>");
        try (Connection conn = DBUtil.getConnection()) {
            String activeSql = "SELECT COUNT(*) FROM admins WHERE username = 'admin' AND isActive = 1";
            try (PreparedStatement stmt = conn.prepareStatement(activeSql)) {
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    int activeCount = rs.getInt(1);
                    if (activeCount > 0) {
                        out.println("<div class='success'>✅ Admin account is active</div>");
                    } else {
                        out.println("<div class='error'>❌ Admin account is not active</div>");
                    }
                }
            }
        } catch (SQLException e) {
            out.println("<div class='error'>❌ Active admin check failed: " + e.getMessage() + "</div>");
        }
        
        out.println("<br><h2>🔧 Troubleshooting Steps:</h2>");
        out.println("<ol>");
        out.println("<li>Make sure SQL Server is running on localhost:1433</li>");
        out.println("<li>Verify database 'Apartment_05' exists</li>");
        out.println("<li>Check if the schema.sql script was executed</li>");
        out.println("<li>Verify SQL Server authentication (username: sa, password: 123)</li>");
        out.println("</ol>");
        
        out.println("<br><a href='adminlogin.jsp'>← Back to Admin Login</a>");
        out.println("</body></html>");
    }
}
