
--User Table Creation
-- Drop existing tables for clean setup
IF OBJECT_ID('dbo.sellers', 'U') IS NOT NULL DROP TABLE dbo.sellers;
IF OBJECT_ID('dbo.buyers', 'U') IS NOT NULL DROP TABLE dbo.buyers;
IF OBJECT_ID('dbo.users', 'U') IS NOT NULL DROP TABLE dbo.users;
GO

-- Drop sequences if they exist
IF OBJECT_ID('dbo.SeqUsers', 'SO') IS NOT NULL DROP SEQUENCE dbo.SeqUsers;
IF OBJECT_ID('dbo.SeqBuyers', 'SO') IS NOT NULL DROP SEQUENCE dbo.SeqBuyers;
IF OBJECT_ID('dbo.SeqSellers', 'SO') IS NOT NULL DROP SEQUENCE dbo.SeqSellers;
GO

-- Sequences to generate numeric parts
CREATE SEQUENCE dbo.SeqUsers AS INT START WITH 1 INCREMENT BY 1;
GO
CREATE SEQUENCE dbo.SeqBuyers AS INT START WITH 1 INCREMENT BY 1;
GO
CREATE SEQUENCE dbo.SeqSellers AS INT START WITH 1 INCREMENT BY 1;
GO

-- users table
CREATE TABLE dbo.users (
    userId VARCHAR(10) NOT NULL DEFAULT ('U' + RIGHT('000' + CAST(NEXT VALUE FOR dbo.SeqUsers AS VARCHAR(10)), 3)),
    firstName NVARCHAR(100) NOT NULL,
    lastName NVARCHAR(100) NOT NULL,
    contactNumber NVARCHAR(20) NULL,
    address NVARCHAR(255) NULL,
    email NVARCHAR(150) NOT NULL,
    password NVARCHAR(255) NOT NULL,
    dateOfBirth DATE NOT NULL,
    role NVARCHAR(20) NOT NULL,
    registrationDate DATETIME2 NOT NULL,
    CONSTRAINT PK_users PRIMARY KEY (userId),
    CONSTRAINT UQ_users_email UNIQUE (email),
    CONSTRAINT CK_users_role CHECK (role IN ('buyer','seller'))
);
GO





--Buyer Table Creation
-- buyers table
CREATE TABLE dbo.buyers (
    buyerId VARCHAR(10) NOT NULL DEFAULT ('B' + RIGHT('000' + CAST(NEXT VALUE FOR dbo.SeqBuyers AS VARCHAR(10)), 3)),
    userId VARCHAR(10) NOT NULL,
    preferredLocation NVARCHAR(100) NULL,
    budgetRange DECIMAL(18,2) NULL,
    purchaseTimeline NVARCHAR(50) NULL,
    CONSTRAINT PK_buyers PRIMARY KEY (buyerId),
    CONSTRAINT UQ_buyers_user UNIQUE (userId),
    CONSTRAINT FK_buyers_users FOREIGN KEY (userId) REFERENCES dbo.users(userId) ON DELETE CASCADE
);
GO






--Seller Table Creation
-- sellers table
CREATE TABLE dbo.sellers (
    sellerId VARCHAR(10) NOT NULL DEFAULT ('S' + RIGHT('000' + CAST(NEXT VALUE FOR dbo.SeqSellers AS VARCHAR(10)), 3)),
    userId VARCHAR(10) NOT NULL,
    businessRegistrationNumber NVARCHAR(100) NULL,
    companyName NVARCHAR(150) NULL,
    licenseNumber NVARCHAR(100) NULL,
    CONSTRAINT PK_sellers PRIMARY KEY (sellerId),
    CONSTRAINT UQ_sellers_user UNIQUE (userId),
    CONSTRAINT FK_sellers_users FOREIGN KEY (userId) REFERENCES dbo.users(userId) ON DELETE CASCADE
);
GO
-- Helpful indexes
CREATE INDEX IX_users_role ON dbo.users(role);
CREATE INDEX IX_buyers_preferredLocation ON dbo.buyers(preferredLocation);
CREATE INDEX IX_sellers_companyName ON dbo.sellers(companyName);
GO





--Apartment Table Creation
-- Drop existing if any
IF OBJECT_ID('dbo.apartment_images', 'U') IS NOT NULL DROP TABLE dbo.apartment_images;
IF OBJECT_ID('dbo.apartments', 'U') IS NOT NULL DROP TABLE dbo.apartments;
GO
-- Drop sequences if they exist
IF OBJECT_ID('dbo.SeqApartments', 'SO') IS NOT NULL DROP SEQUENCE dbo.SeqApartments;
IF OBJECT_ID('dbo.SeqApartmentImages', 'SO') IS NOT NULL DROP SEQUENCE dbo.SeqApartmentImages;
GO
-- Create sequences
CREATE SEQUENCE dbo.SeqApartments AS INT START WITH 1 INCREMENT BY 1;
GO
CREATE SEQUENCE dbo.SeqApartmentImages AS INT START WITH 1 INCREMENT BY 1;
GO
-- apartments table
CREATE TABLE dbo.apartments (
    apartmentId VARCHAR(10) NOT NULL DEFAULT ('A' + RIGHT('000' + CAST(NEXT VALUE FOR dbo.SeqApartments AS VARCHAR(10)), 3)),
    sellerId VARCHAR(10) NOT NULL, -- FK sellerId
    title NVARCHAR(150) NOT NULL,
    description NVARCHAR(MAX) NULL,
    address NVARCHAR(255) NOT NULL,
    city NVARCHAR(100) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    bedrooms INT NULL,
    bathrooms INT NULL,
    areaSqFt INT NULL,
    createdAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_apartments PRIMARY KEY (apartmentId),
    CONSTRAINT FK_apartments_sellers FOREIGN KEY (sellerId) REFERENCES dbo.sellers(sellerId) ON DELETE CASCADE
);
GO

-- Update apartments table to include missing fields
-- Add state field
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.apartments') AND name = 'state')
    BEGIN
        ALTER TABLE dbo.apartments ADD state NVARCHAR(100) NULL;
        PRINT 'Added state column to apartments table';
    END
ELSE
    BEGIN
        PRINT 'state column already exists in apartments table';
    END
GO

-- Add postalCode field
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.apartments') AND name = 'postalCode')
    BEGIN
        ALTER TABLE dbo.apartments ADD postalCode NVARCHAR(20) NULL;
        PRINT 'Added postalCode column to apartments table';
    END
ELSE
    BEGIN
        PRINT 'postalCode column already exists in apartments table';
    END
GO

-- Add contactNumber field
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.apartments') AND name = 'contactNumber')
    BEGIN
        ALTER TABLE dbo.apartments ADD contactNumber NVARCHAR(20) NULL;
        PRINT 'Added contactNumber column to apartments table';
    END
ELSE
    BEGIN
        PRINT 'contactNumber column already exists in apartments table';
    END
GO

-- Add propertyType field
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.apartments') AND name = 'propertyType')
    BEGIN
        ALTER TABLE dbo.apartments ADD propertyType NVARCHAR(50) NULL;
        PRINT 'Added propertyType column to apartments table';
    END
ELSE
    BEGIN
        PRINT 'propertyType column already exists in apartments table';
    END
GO

-- Add status field
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.apartments') AND name = 'status')
    BEGIN
        ALTER TABLE dbo.apartments ADD status NVARCHAR(20) NULL DEFAULT 'Available';
        PRINT 'Added status column to apartments table';
    END
ELSE
    BEGIN
        PRINT 'status column already exists in apartments table';
    END
GO

PRINT 'All missing apartment fields have been added successfully!';





--Apartment Image Table Creation
-- apartment_images table (multiple images per apartment)
CREATE TABLE dbo.apartment_images (
    imageId VARCHAR(10) NOT NULL DEFAULT ('I' + RIGHT('000' + CAST(NEXT VALUE FOR dbo.SeqApartmentImages AS VARCHAR(10)), 3)),
    apartmentId VARCHAR(10) NOT NULL,
    imageUrl NVARCHAR(500) NOT NULL,
    createdAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_apartment_images PRIMARY KEY (imageId),
    CONSTRAINT FK_apartment_images_apartments FOREIGN KEY (apartmentId) REFERENCES dbo.apartments(apartmentId) ON DELETE CASCADE
);
GO
-- Helpful indexes for apartments
CREATE INDEX IX_apartments_seller ON dbo.apartments(sellerId);
CREATE INDEX IX_apartments_city ON dbo.apartments(city);
CREATE INDEX IX_apartment_images_apartment ON dbo.apartment_images(apartmentId);
GO




--Favourite Table Creation
-- Favourites module
-- Drop existing if any
IF OBJECT_ID('dbo.favourites', 'U') IS NOT NULL DROP TABLE dbo.favourites;
GO
-- Drop sequences if they exist
IF OBJECT_ID('dbo.SeqFavourites', 'SO') IS NOT NULL DROP SEQUENCE dbo.SeqFavourites;
GO
-- Create sequences
CREATE SEQUENCE dbo.SeqFavourites AS INT START WITH 1 INCREMENT BY 1;
GO
-- favourites table
CREATE TABLE dbo.favourites (
    favouriteId VARCHAR(10) NOT NULL DEFAULT ('F' + RIGHT('000' + CAST(NEXT VALUE FOR dbo.SeqFavourites AS VARCHAR(10)), 3)),
    buyerId VARCHAR(10) NOT NULL, -- FK to buyers.buyerId (Bxxx)
    apartmentId VARCHAR(10) NOT NULL, -- FK to apartments.apartmentId (Axxx)
    createdAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_favourites PRIMARY KEY (favouriteId),
    CONSTRAINT FK_favourites_buyers FOREIGN KEY (buyerId) REFERENCES dbo.buyers(buyerId) ON DELETE CASCADE,
    CONSTRAINT FK_favourites_apartments FOREIGN KEY (apartmentId) REFERENCES dbo.apartments(apartmentId) ON DELETE NO ACTION,
    CONSTRAINT UQ_favourites_buyer_apartment UNIQUE (buyerId, apartmentId) -- Prevent duplicate favourites
);
GO
-- Helpful indexes for favourites
CREATE INDEX IX_favourites_buyer ON dbo.favourites(buyerId);
CREATE INDEX IX_favourites_apartment ON dbo.favourites(apartmentId);





--Booking Table Creation
-- Drop and recreate the bookings table to ensure it has all required columns
IF OBJECT_ID('dbo.bookings', 'U') IS NOT NULL
    BEGIN
        -- Drop foreign key constraints first
        IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_bookings_buyers')
        ALTER TABLE dbo.bookings DROP CONSTRAINT FK_bookings_buyers;
        IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_bookings_sellers')
        ALTER TABLE dbo.bookings DROP CONSTRAINT FK_bookings_sellers;
        IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_bookings_apartments')
        ALTER TABLE dbo.bookings DROP CONSTRAINT FK_bookings_apartments;

        DROP TABLE dbo.bookings;
    END
GO

-- Drop sequence if exists
IF OBJECT_ID('dbo.SeqBookings', 'SO') IS NOT NULL
    DROP SEQUENCE dbo.SeqBookings;
GO

-- Create sequence for booking IDs
CREATE SEQUENCE dbo.SeqBookings AS INT START WITH 1 INCREMENT BY 1;
GO

-- Create bookings table with ALL required columns
CREATE TABLE dbo.bookings (
                              bookingId VARCHAR(10) NOT NULL DEFAULT ('BKNG' + RIGHT('000' + CAST(NEXT VALUE FOR dbo.SeqBookings AS VARCHAR(10)), 3)),
                              buyerId VARCHAR(10) NOT NULL,
                              sellerId VARCHAR(10) NOT NULL,
                              apartmentId VARCHAR(10) NOT NULL,
                              bookingDate DATE NOT NULL,
                              bookingTime TIME NOT NULL,
                              message NVARCHAR(500) NULL,
                              status NVARCHAR(20) NOT NULL DEFAULT 'Pending',
                              createdAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
                              updatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
                              CONSTRAINT PK_bookings PRIMARY KEY (bookingId),
                              CONSTRAINT CK_bookings_date CHECK (bookingDate >= CAST(GETDATE() AS DATE)),
                              CONSTRAINT CK_bookings_status CHECK (status IN ('Pending', 'Confirmed', 'Cancelled', 'Completed')),
                              CONSTRAINT UQ_bookings_apartment_datetime UNIQUE (apartmentId, bookingDate, bookingTime)
);
GO

-- Create indexes for better performance
CREATE INDEX IX_bookings_buyer ON dbo.bookings(buyerId);
CREATE INDEX IX_bookings_seller ON dbo.bookings(sellerId);
CREATE INDEX IX_bookings_apartment ON dbo.bookings(apartmentId);
CREATE INDEX IX_bookings_date_time ON dbo.bookings(bookingDate, bookingTime);
CREATE INDEX IX_bookings_status ON dbo.bookings(status);
CREATE INDEX IX_bookings_created ON dbo.bookings(createdAt);
GO

-- Add foreign key constraints
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'buyers')
    BEGIN
        ALTER TABLE dbo.bookings
            ADD CONSTRAINT FK_bookings_buyers
                FOREIGN KEY (buyerId) REFERENCES dbo.buyers(buyerId) ON DELETE NO ACTION ON UPDATE NO ACTION;
        PRINT 'Added FK_bookings_buyers constraint';
    END
ELSE
    BEGIN
        PRINT 'Buyers table not found - skipping FK_bookings_buyers constraint';
    END
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'sellers')
    BEGIN
        ALTER TABLE dbo.bookings
            ADD CONSTRAINT FK_bookings_sellers
                FOREIGN KEY (sellerId) REFERENCES dbo.sellers(sellerId) ON DELETE NO ACTION ON UPDATE NO ACTION;
        PRINT 'Added FK_bookings_sellers constraint';
    END
ELSE
    BEGIN
        PRINT 'Sellers table not found - skipping FK_bookings_sellers constraint';
    END
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'apartments')
    BEGIN
        ALTER TABLE dbo.bookings
            ADD CONSTRAINT FK_bookings_apartments
                FOREIGN KEY (apartmentId) REFERENCES dbo.apartments(apartmentId) ON DELETE NO ACTION ON UPDATE NO ACTION;
        PRINT 'Added FK_bookings_apartments constraint';
    END
ELSE
    BEGIN
        PRINT 'Apartments table not found - skipping FK_bookings_apartments constraint';
    END
GO

-- Verify the table structure
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'bookings'
ORDER BY ORDINAL_POSITION;

PRINT 'Bookings table recreated successfully with all required columns!';
GO








--Buyer Card Table Creation
-- Buyer Cards module
-- Drop existing if any
IF OBJECT_ID('dbo.buyerCards', 'U') IS NOT NULL DROP TABLE dbo.buyerCards;
GO
-- Drop sequences if they exist
IF OBJECT_ID('dbo.SeqBuyerCards', 'SO') IS NOT NULL DROP SEQUENCE dbo.SeqBuyerCards;
GO
-- Create sequences
CREATE SEQUENCE dbo.SeqBuyerCards AS INT START WITH 1 INCREMENT BY 1;
GO
-- buyerCards table
CREATE TABLE dbo.buyerCards (
    buyerCardId VARCHAR(10) NOT NULL DEFAULT ('BC' + RIGHT('000' + CAST(NEXT VALUE FOR dbo.SeqBuyerCards AS VARCHAR(10)), 3)),
    buyerId VARCHAR(10) NOT NULL, -- FK to buyers.buyerId (Bxxx)
    cardholderName NVARCHAR(100) NOT NULL,
    cardNumber NVARCHAR(19) NOT NULL,
    cvv NVARCHAR(4) NOT NULL,
    expiryDate DATE NOT NULL,
    amountInCard DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    createdAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_buyerCards PRIMARY KEY (buyerCardId),
    CONSTRAINT FK_buyerCards_buyers FOREIGN KEY (buyerId) REFERENCES dbo.buyers(buyerId) ON DELETE CASCADE,
    CONSTRAINT CK_buyerCards_amount CHECK (amountInCard >= 0)
);
GO
-- Helpful indexes for buyer cards
CREATE INDEX IX_buyerCards_buyer ON dbo.buyerCards(buyerId);
CREATE INDEX IX_buyerCards_expiry ON dbo.buyerCards(expiryDate);
GO







-- Payments Table Creation
-- Payments module
-- Drop existing if any
IF OBJECT_ID('dbo.payments', 'U') IS NOT NULL DROP TABLE dbo.payments;
GO
-- Drop sequences if they exist
IF OBJECT_ID('dbo.SeqPayments', 'SO') IS NOT NULL DROP SEQUENCE dbo.SeqPayments;
GO
-- Create sequences
CREATE SEQUENCE dbo.SeqPayments AS INT START WITH 1 INCREMENT BY 1;
GO
-- payments table
CREATE TABLE dbo.payments (
    paymentId VARCHAR(10) NOT NULL DEFAULT ('PAY' + RIGHT('000' + CAST(NEXT VALUE FOR dbo.SeqPayments AS VARCHAR(10)), 3)),
    buyerId VARCHAR(10) NOT NULL, -- FK to buyers.buyerId (Bxxx)
    sellerId VARCHAR(10) NOT NULL, -- FK to sellers.sellerId (Sxxx)
    apartmentId VARCHAR(10) NOT NULL, -- FK to apartments.apartmentId (Axxx)
    buyerCardId VARCHAR(10) NOT NULL, -- FK to buyerCards.buyerCardId (BCxxx)
    paymentType NVARCHAR(20) NOT NULL, -- Advance, Installment, Half
    amount DECIMAL(10,2) NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT 'Pending', -- Pending, Completed, Failed, Refunded
    paymentDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    description NVARCHAR(500) NULL,
    createdAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_payments PRIMARY KEY (paymentId),
    CONSTRAINT FK_payments_buyers FOREIGN KEY (buyerId) REFERENCES dbo.buyers(buyerId) ON DELETE NO ACTION,
    CONSTRAINT FK_payments_sellers FOREIGN KEY (sellerId) REFERENCES dbo.sellers(sellerId) ON DELETE NO ACTION,
    CONSTRAINT FK_payments_apartments FOREIGN KEY (apartmentId) REFERENCES dbo.apartments(apartmentId) ON DELETE NO ACTION,
    CONSTRAINT FK_payments_buyerCards FOREIGN KEY (buyerCardId) REFERENCES dbo.buyerCards(buyerCardId) ON DELETE NO ACTION,
    CONSTRAINT CK_payments_type CHECK (paymentType IN ('Advance', 'Installment', 'Half')),
    CONSTRAINT CK_payments_status CHECK (status IN ('Pending', 'Completed', 'Failed', 'Refunded')),
    CONSTRAINT CK_payments_amount CHECK (amount > 0)
);
GO
-- Helpful indexes for payments
CREATE INDEX IX_payments_buyer ON dbo.payments(buyerId);
CREATE INDEX IX_payments_seller ON dbo.payments(sellerId);
CREATE INDEX IX_payments_apartment ON dbo.payments(apartmentId);
CREATE INDEX IX_payments_card ON dbo.payments(buyerCardId);
CREATE INDEX IX_payments_status ON dbo.payments(status);
CREATE INDEX IX_payments_date ON dbo.payments(paymentDate);
GO




-- Review Table Creation
-- Create sequence
CREATE SEQUENCE dbo.SeqReviews AS INT START WITH 1 INCREMENT BY 1;
GO
-- Create reviews table
CREATE TABLE dbo.reviews (
    reviewId VARCHAR(10) NOT NULL DEFAULT ('R' + RIGHT('000' + CAST(NEXT VALUE FOR dbo.SeqReviews AS VARCHAR(10)), 3)),
    buyerId VARCHAR(10) NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title NVARCHAR(200) NOT NULL,
    reviewText NVARCHAR(1000) NOT NULL,
    isVisible BIT NOT NULL DEFAULT 1,
    createdAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_reviews PRIMARY KEY (reviewId),
    CONSTRAINT FK_reviews_buyers FOREIGN KEY (buyerId) REFERENCES dbo.buyers(buyerId) ON DELETE CASCADE,
    CONSTRAINT UQ_reviews_buyer UNIQUE (buyerId)
);
GO
-- Create indexes
CREATE INDEX IX_reviews_buyer ON dbo.reviews(buyerId);
CREATE INDEX IX_reviews_rating ON dbo.reviews(rating);
CREATE INDEX IX_reviews_visible ON dbo.reviews(isVisible);
CREATE INDEX IX_reviews_created ON dbo.reviews(createdAt);
GO




-- Admin Table Creation
-- Drop table if exists (for clean setup)
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[admins]') AND type in (N'U'))
    DROP TABLE [dbo].[admins];
GO
-- Drop sequence if exists
IF EXISTS (SELECT * FROM sys.sequences WHERE name = 'SeqAdmins')
    DROP SEQUENCE [dbo].[SeqAdmins];
GO
-- Create sequence for admin IDs
CREATE SEQUENCE dbo.SeqAdmins AS INT START WITH 1 INCREMENT BY 1;
GO

-- Create admin table
CREATE TABLE admins (
                        adminId VARCHAR(10) NOT NULL DEFAULT ('ADM' + RIGHT('000' + CAST(NEXT VALUE FOR dbo.SeqAdmins AS VARCHAR(10)), 3)),
                        username NVARCHAR(50) NOT NULL UNIQUE,
                        email NVARCHAR(100) NOT NULL UNIQUE,
                        password NVARCHAR(255) NOT NULL,
                        firstName NVARCHAR(50) NOT NULL,
                        lastName NVARCHAR(50) NOT NULL,
                        phone NVARCHAR(20),
                        isActive BIT NOT NULL DEFAULT 1,
                        createdAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
                        updatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
                        lastLogin DATETIME2 NULL,
                        CONSTRAINT PK_admins PRIMARY KEY (adminId)
);
GO
-- Create indexes for better performance
CREATE INDEX IX_admins_username ON admins(username);
CREATE INDEX IX_admins_email ON admins(email);
CREATE INDEX IX_admins_active ON admins(isActive);
GO
-- Insert the first admin (password is plain text 'admin123' for simplicity)
-- You can change the password later through the application
INSERT INTO admins (username, email, password, firstName, lastName, phone)
VALUES ('admin', 'admin@apartmentx.com', 'admin123', 'System', 'Administrator', '+1-555-0123');
GO

-- Verify the table was created successfully
SELECT 'Admin table created successfully!' as Status;
SELECT COUNT(*) as AdminCount FROM admins;
SELECT * FROM admins;
GO







-- Create the faqs table
CREATE TABLE faqs (
    faq_id INT IDENTITY(1,1) PRIMARY KEY,
    question NVARCHAR(500) NOT NULL,
    answer NVARCHAR(MAX) NOT NULL,
    category NVARCHAR(100) DEFAULT 'General',
    display_order INT DEFAULT 0,
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- Insert sample FAQ data
INSERT INTO faqs (question, answer, category, display_order) VALUES
      ('How do I register as a seller?', 'Click on "Sign Up" and choose "Seller". After registering with your email and password, you can log in and access the seller dashboard.', 'Registration', 1),
      ('Can I book an apartment before making a payment?', 'No, payment is required to confirm your apartment booking. Once payment is processed successfully, your booking will be confirmed and you''ll receive a confirmation email.', 'Booking', 2),
      ('How do payments work?', 'We accept various payment methods including credit cards, debit cards, and online banking. All payments are processed securely through our encrypted payment gateway. You''ll receive a payment confirmation immediately after successful transaction.', 'Payment', 3),
      ('Can I delete my account?', 'Yes, you can delete your account by going to your profile settings and selecting "Delete Account". Please note that this action is permanent and cannot be undone. All your data will be removed from our system.', 'Account', 4),
      ('Is Apartment X free to use?', 'Yes, Apartment X is free for buyers to browse and book apartments. Sellers pay a small commission fee only when they successfully rent out their property through our platform.', 'General', 5),
      ('How do I contact customer support?', 'You can reach our customer support team through the "Contact Us" page, or email us at support@apartmentx.com. We typically respond within 24 hours.', 'Support', 6),
      ('What is your cancellation policy?', 'Cancellation policies vary by apartment and seller. Please check the specific cancellation policy listed on the apartment details page before booking. Generally, cancellations made 48 hours before check-in receive full refund.', 'Booking', 7),
      ('How do I reset my password?', 'Click on "Forgot Password" on the login page, enter your email address, and we''ll send you a password reset link. The link will expire in 24 hours for security reasons.', 'Account', 8);

INSERT INTO faqs (question, answer, category, display_order) VALUES
-- Registration
('Do I need to provide verification documents during registration?',
 'Yes, sellers are required to upload valid identification and property documents during registration for account verification and approval.',
 'Registration', 1),

-- Booking
('Can I view the apartment before booking?',
 'Yes, you can schedule a visit by contacting the seller through the chat feature. Some sellers also offer virtual tours of their properties.',
 'Booking', 2),

-- Payment
('What should I do if my payment is deducted but booking is not confirmed?',
 'If your payment is deducted but you did not receive a booking confirmation, please contact support with your transaction ID for verification and refund.',
 'Payment', 3),

-- Account
('How can I change my account password?',
 'Go to Account Settings, click on "Change Password", and follow the instructions. Make sure your new password is strong and unique.',
 'Account', 4),

-- General
('Does Apartment X verify property listings?',
 'Yes, all listed properties are reviewed and verified by our team before being published to ensure authenticity and accuracy.',
 'General', 5),

-- Support
('How can I track the status of my complaint?',
 'After submitting a complaint, you can track its progress through the "My Support Tickets" section under your profile.',
 'Support', 6),

-- Booking
('Can I transfer my booking to another person?',
 'No, bookings are non-transferable. Only the person who made the booking can check in or request changes through support.',
 'Booking', 7),

-- Account
('Why is my account temporarily suspended?',
 'Your account may be suspended due to policy violations or incomplete verification. Contact support to resolve the issue and regain access.',
 'Account', 8);


-- Create indexes for better performance
CREATE INDEX IX_faqs_category ON faqs(category);
CREATE INDEX IX_faqs_active ON faqs(is_active);
CREATE INDEX IX_faqs_order ON faqs(display_order);