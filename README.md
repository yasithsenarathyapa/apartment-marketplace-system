# Apartment Marketplace System

A comprehensive full-stack web application for buying, selling, and managing apartment listings. This platform provides separate interfaces for buyers, sellers, and administrators with complete booking, payment processing, and review management capabilities.

## ✨ Features

### For Buyers
- 🏠 Browse and search apartment listings with advanced filters
- ❤️ Save favorite apartments to wishlist
- 📅 Book apartments with an intuitive booking system
- 💳 Secure payment processing with saved card management
- ⭐ Rate and review apartments
- 📊 Personal dashboard with booking history and favorites

### For Sellers
- 📝 Create and manage apartment listings
- 📸 Upload multiple images for each property
- 📋 View and manage booking requests
- 💰 Track payments and revenue
- 📈 Dashboard with listing analytics
- ✏️ Edit and update property information

### For Administrators
- 👥 User management (buyers and sellers)
- 🏢 Apartment listing moderation and management
- 💬 Review and rating moderation
- 📊 Generate system reports and analytics
- ❓ FAQ management
- ⚙️ System settings and configuration

### Core Features
- 🔐 Multi-role authentication system (Buyer, Seller, Admin)
- 🖼️ Image upload and gallery management
- 🔍 Advanced search with multiple filters
- 📱 Responsive web design
- 🗄️ Complete CRUD operations for all entities
- 🛡️ Secure password handling
- 📧 Email-based user identification

## 🛠️ Technology Stack

### Backend
- **Java:** Version 16
- **Servlets:** 4.0.1
- **JSP:** 2.3.3
- **Build Tool:** Maven
- **Web Server:** Apache Tomcat (or compatible Servlet container)

### Database
- **Database:** Microsoft SQL Server
- **JDBC Driver:** mssql-jdbc 12.6.1

### Frontend
- **HTML5 & CSS3**
- **JavaScript**
- **JSP (JavaServer Pages)**
- **Font Awesome** (for icons)

### Additional Libraries
- **Jackson:** 2.15.2 (JSON processing)
- **JUnit:** 3.8.1 (testing)

## 📦 Prerequisites

Before running this application, ensure you have the following installed:

- **Java Development Kit (JDK):** Version 16 or higher
  - [Download JDK](https://www.oracle.com/java/technologies/downloads/)
- **Apache Maven:** Version 3.6 or higher
  - [Download Maven](https://maven.apache.org/download.cgi)
- **Apache Tomcat:** Version 9.0 or higher
  - [Download Tomcat](https://tomcat.apache.org/download-90.cgi)
- **Microsoft SQL Server:** 2019 or higher (Express Edition is sufficient)
  - [Download SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
- **SQL Server Management Studio (SSMS):** For database management
  - [Download SSMS](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/apartment-marketplace-system.git
cd apartment-marketplace-system
```

### 2. Configure Database Connection

Update the database connection settings in your DAO classes (located in `src/main/java/com/project/DAO/`):

```java
// Example configuration (update with your credentials)
private static final String DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=ApartmentDB;encrypt=true;trustServerCertificate=true";
private static final String DB_USER = "your_username";
private static final String DB_PASSWORD = "your_password";
```

### 3. Build the Project
```bash
mvn clean install
```

This will:
- Download all dependencies
- Compile the Java source code
- Package the application as a WAR file

## 🗄️ Database Setup

### 1. Create Database

Open SQL Server Management Studio and execute:

```sql
CREATE DATABASE ApartmentDB;
GO
USE ApartmentDB;
GO
```

### 2. Run Schema Script

Execute the complete schema script located at `src/main/resources/schema.sql`. This will create:
- All necessary tables (users, buyers, sellers, apartments, bookings, payments, reviews, etc.)
- Required sequences for ID generation
- Foreign key relationships
- Constraints and indexes

You can run the script using:
- **SSMS:** Open the file and execute
- **Command line:** `sqlcmd -S localhost -d ApartmentDB -i src/main/resources/schema.sql`

### 3. Verify Tables

Ensure all tables are created:
```sql
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
```

Expected tables:
- users
- buyers
- sellers
- admins
- apartments
- apartmentimages
- bookings
- payments
- buyercards
- reviews
- favourites
- faqs

## ▶️ Running the Application

### Option 1: Using Maven with Tomcat Plugin (if configured)
```bash
mvn tomcat7:run
```

### Option 2: Deploy to Tomcat Manually

1. **Build the WAR file:**
   ```bash
   mvn clean package
   ```

2. **Copy WAR to Tomcat:**
   - Locate the WAR file: `target/Apartment05.war`
   - Copy to Tomcat's webapps folder: `<TOMCAT_HOME>/webapps/`

3. **Start Tomcat:**
   - Windows: `<TOMCAT_HOME>/bin/startup.bat`
   - Linux/Mac: `<TOMCAT_HOME>/bin/startup.sh`

4. **Access the application:**
   ```
   http://localhost:8080/Apartment05/
   ```

### Default Access

After initial setup, you may need to create an admin account. Access the admin registration page:
```
http://localhost:8080/Apartment05/adminregistration.jsp
```

## 📁 Project Structure

```
ApartmentSales/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── project/
│   │   │           ├── DAO/              # Data Access Objects
│   │   │           │   ├── UserDAO.java
│   │   │           │   ├── ApartmentDAO.java
│   │   │           │   ├── BookingDAO.java
│   │   │           │   ├── PaymentDAO.java
│   │   │           │   └── ...
│   │   │           ├── model/            # Domain Models
│   │   │           │   ├── User.java
│   │   │           │   ├── Apartment.java
│   │   │           │   ├── Booking.java
│   │   │           │   └── ...
│   │   │           ├── service/          # Business Logic
│   │   │           │   ├── UserService.java
│   │   │           │   ├── ApartmentService.java
│   │   │           │   └── ...
│   │   │           ├── servlet/          # Controllers
│   │   │           │   ├── LoginServlet.java
│   │   │           │   ├── RegisterServlet.java
│   │   │           │   ├── AddApartmentServlet.java
│   │   │           │   └── ...
│   │   │           ├── strategy/         # Strategy Pattern Implementations
│   │   │           └── util/             # Utility Classes
│   │   ├── resources/
│   │   │   └── schema.sql               # Database Schema
│   │   └── webapp/
│   │       ├── WEB-INF/
│   │       │   └── web.xml              # Deployment Descriptor
│   │       ├── css/                      # Stylesheets
│   │       ├── js/                       # JavaScript Files
│   │       ├── includes/                 # Reusable JSP Components
│   │       ├── resources/
│   │       │   └── images/              # Static Images
│   │       ├── index.jsp                # Landing Page
│   │       ├── login.jsp                # User Login
│   │       ├── register.jsp             # User Registration
│   │       ├── buyerdashboard.jsp       # Buyer Dashboard
│   │       ├── sellerdashboard.jsp      # Seller Dashboard
│   │       ├── admindashboard.jsp       # Admin Dashboard
│   │       └── ...                      # Other JSP Pages
└── pom.xml                              # Maven Configuration
```

## 👥 User Roles

The system supports three distinct user roles:

### 1. **Buyer**
- Register and create a buyer profile
- Search and browse apartment listings
- Save favorites
- Book apartments
- Make payments
- Write reviews

### 2. **Seller**
- Register and create a seller profile
- List apartments for sale
- Upload property images
- Manage listings
- View booking requests
- Track sales and payments

### 3. **Administrator**
- Full system access
- Manage all users (buyers and sellers)
- Moderate apartment listings
- Moderate reviews
- View system reports
- Manage FAQs
- System configuration

## 👨‍💻 Author

**Yasith Senarath Yapa**
- GitHub: https://github.com/yasithsenarathyapa
  
## 📞 Contact

For any queries regarding this project, please contact:
- Email: yasithsenarathyapa.info@gmail.com
