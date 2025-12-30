package com.project.servlet;

import com.project.DAO.AdminDAO;
import com.project.model.Admin;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;

@WebServlet("/CreateAdminServlet")
public class CreateAdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html><head><title>Create Admin Account</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; margin: 20px; }");
        out.println(".success { color: green; background: #d4edda; padding: 10px; border-radius: 5px; margin: 5px 0; }");
        out.println(".error { color: red; background: #f8d7da; padding: 10px; border-radius: 5px; margin: 5px 0; }");
        out.println("</style></head><body>");
        
        out.println("<h1>🔧 Create Default Admin Account</h1>");
        
        try {
            AdminDAO adminDAO = new AdminDAO();
            
            // Check if admin already exists
            Admin existingAdmin = adminDAO.getAdminByUsername("admin");
            if (existingAdmin != null) {
                out.println("<div class='success'>✅ Admin account already exists</div>");
                out.println("<p>Username: " + existingAdmin.getUsername() + "</p>");
                out.println("<p>Email: " + existingAdmin.getEmail() + "</p>");
                out.println("<p>Active: " + (existingAdmin.isActive() ? "Yes" : "No") + "</p>");
            } else {
                // Create new admin account
                Admin admin = new Admin();
                admin.setUsername("admin");
                admin.setEmail("admin@apartmentx.com");
                admin.setPassword("admin123");
                admin.setFirstName("System");
                admin.setLastName("Administrator");
                admin.setPhone("+1-555-0123");
                admin.setActive(true);
                admin.setCreatedAt(LocalDateTime.now());
                admin.setUpdatedAt(LocalDateTime.now());
                
                String adminId = adminDAO.createAdmin(admin);
                if (adminId != null) {
                    out.println("<div class='success'>✅ Admin account created successfully</div>");
                    out.println("<p>Admin ID: " + adminId + "</p>");
                    out.println("<p>Username: admin</p>");
                    out.println("<p>Password: admin123</p>");
                    out.println("<p>Email: admin@apartmentx.com</p>");
                } else {
                    out.println("<div class='error'>❌ Failed to create admin account</div>");
                }
            }
        } catch (Exception e) {
            out.println("<div class='error'>❌ Error creating admin account: " + e.getMessage() + "</div>");
            e.printStackTrace();
        }
        
        out.println("<br><a href='adminlogin.jsp'>← Back to Admin Login</a>");
        out.println("</body></html>");
    }
}
