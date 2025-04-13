-- =============================================================================
-- BookstoreDB: Complete Database Implementation Script
-- Created: April 2025
-- Authors: Nelson Masbayi, Lina Murithi, Ivy Anyango
-- =============================================================================
-- This script contains the complete implementation of the BookstoreDB database
-- including database creation, table creation, user roles, and sample data.
-- All components are consolidated into a single file for easy deployment.

-- =============================================================================
-- SECTION 1: DATABASE CREATION
-- =============================================================================

-- Drop database if it exists (use with caution in production)
DROP DATABASE IF EXISTS bookstore_db;

-- Create the database with proper character set and collation
CREATE DATABASE bookstore_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Select the database for use
USE bookstore_db;

-- =============================================================================
-- SECTION 2: BOOK INFORMATION TABLES
-- Created by: Nelson Masbayi
-- =============================================================================

-- Create book_language table
CREATE TABLE book_language (
    language_id INT AUTO_INCREMENT PRIMARY KEY,
    language_name VARCHAR(50) NOT NULL UNIQUE,
    language_code CHAR(2) NOT NULL UNIQUE COMMENT 'ISO 639-1 language code'
) COMMENT 'Stores languages available for books';

-- Add index for faster language lookups
CREATE INDEX idx_language_code ON book_language(language_code);

-- Create publisher table
CREATE TABLE publisher (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    contact_email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(255),
    website VARCHAR(100)
) COMMENT 'Stores information about book publishers';

-- Add indexes for common search fields
CREATE INDEX idx_publisher_name ON publisher(publisher_name);

-- Create book table
CREATE TABLE book (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn13 VARCHAR(13) UNIQUE COMMENT 'International Standard Book Number (13-digit)',
    publication_date DATE,
    price DECIMAL(10,2),
    publisher_id INT,
    language_id INT,
    page_count INT,
    description TEXT,
    cover_image_url VARCHAR(255),
    in_stock BOOLEAN DEFAULT TRUE,
    stock_quantity INT DEFAULT 0,
    
    -- Foreign key constraints
    CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id) 
        REFERENCES publisher(publisher_id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_book_language FOREIGN KEY (language_id) 
        REFERENCES book_language(language_id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT
) COMMENT 'Stores information about books available in the bookstore';

-- Add indexes for common search and filter operations
CREATE INDEX idx_book_title ON book(title);
CREATE INDEX idx_book_isbn ON book(isbn13);
CREATE INDEX idx_book_publisher ON book(publisher_id);
CREATE INDEX idx_book_language ON book(language_id);
CREATE INDEX idx_book_publication_date ON book(publication_date);
CREATE INDEX idx_book_price ON book(price);
CREATE INDEX idx_book_stock ON book(in_stock, stock_quantity);

-- =============================================================================
-- SECTION 3: AUTHOR AND ORDER-RELATED TABLES
-- Created by: Lina Murithi
-- =============================================================================

-- Create author table
CREATE TABLE author (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    biography TEXT,
    birth_date DATE,
    nationality VARCHAR(50)
) COMMENT 'Stores information about book authors';

-- Add indexes for common search patterns
CREATE INDEX idx_author_name ON author(last_name, first_name);
CREATE INDEX idx_author_nationality ON author(nationality);

-- Create book_author junction table for many-to-many relationship
CREATE TABLE book_author (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT NOT NULL DEFAULT 1 COMMENT 'Order of authors for the book',
    
    -- Define composite primary key
    PRIMARY KEY (book_id, author_id),
    
    -- Foreign key constraints
    CONSTRAINT fk_bookauthor_book FOREIGN KEY (book_id) 
        REFERENCES book(book_id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_bookauthor_author FOREIGN KEY (author_id) 
        REFERENCES author(author_id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT
) COMMENT 'Junction table connecting books and authors (many-to-many)';

-- Add index for author_id to improve lookup performance
CREATE INDEX idx_bookauthor_author ON book_author(author_id);

-- Create order_status table
CREATE TABLE order_status (
    order_status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE COMMENT 'E.g., pending, shipped, delivered, cancelled',
    description VARCHAR(255)
) COMMENT 'Stores possible statuses for customer orders';

-- Create cust_order table
-- Note: Foreign keys to customer and address tables will be added later
CREATE TABLE cust_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    shipping_address_id INT,
    billing_address_id INT,
    shipping_method_id INT,
    order_status_id INT NOT NULL,
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    payment_transaction_id VARCHAR(100),
    special_instructions TEXT,
    
    -- Foreign key constraints for tables already created
    CONSTRAINT fk_order_status FOREIGN KEY (order_status_id) 
        REFERENCES order_status(order_status_id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    
    -- Adding a check constraint for total_amount
    CONSTRAINT check_total_amount CHECK (total_amount IS NULL OR total_amount >= 0)
) COMMENT 'Stores customer orders';

-- Add indexes for common query patterns
CREATE INDEX idx_order_customer ON cust_order(customer_id);
CREATE INDEX idx_order_date ON cust_order(order_date);
CREATE INDEX idx_order_status ON cust_order(order_status_id);
CREATE INDEX idx_order_shipping_address ON cust_order(shipping_address_id);
CREATE INDEX idx_order_billing_address ON cust_order(billing_address_id);
CREATE INDEX idx_order_shipping_method ON cust_order(shipping_method_id);

-- Create order_line table
CREATE TABLE order_line (
    order_line_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL,
    price_at_time_of_order DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    
    -- Foreign key constraints
    CONSTRAINT fk_orderline_order FOREIGN KEY (order_id) 
        REFERENCES cust_order(order_id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_orderline_book FOREIGN KEY (book_id) 
        REFERENCES book(book_id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    
    -- Add check constraints
    CONSTRAINT check_quantity CHECK (quantity > 0),
    CONSTRAINT check_price CHECK (price_at_time_of_order >= 0),
    CONSTRAINT check_discount CHECK (discount_amount >= 0)
) COMMENT 'Stores individual line items within customer orders';

-- Add indexes for common query patterns
CREATE INDEX idx_orderline_order ON order_line(order_id);
CREATE INDEX idx_orderline_book ON order_line(book_id);

-- Create order_history table
CREATE TABLE order_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    order_status_id INT NOT NULL,
    status_change_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    updated_by VARCHAR(50) COMMENT 'User who made the update',
    
    -- Foreign key constraints
    CONSTRAINT fk_history_order FOREIGN KEY (order_id) 
        REFERENCES cust_order(order_id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_history_status FOREIGN KEY (order_status_id) 
        REFERENCES order_status(order_status_id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT
) COMMENT 'Tracks the history of status changes for orders';

-- Add indexes for common query patterns
CREATE INDEX idx_history_order ON order_history(order_id);
CREATE INDEX idx_history_status ON order_history(order_status_id);
CREATE INDEX idx_history_date ON order_history(status_change_date);

-- =============================================================================
-- SECTION 4: CUSTOMER AND SHIPPING-RELATED TABLES
-- Created by: Ivy Anyango
-- =============================================================================

-- Create country table
CREATE TABLE country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE,
    country_code CHAR(2) NOT NULL UNIQUE COMMENT 'ISO 3166-1 alpha-2 country code'
) COMMENT 'Stores countries for customer addresses';

-- Add index for faster lookups
CREATE INDEX idx_country_code ON country(country_code);

-- Create address table
CREATE TABLE address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country_id INT NOT NULL,
    
    -- Foreign key constraint
    CONSTRAINT fk_address_country FOREIGN KEY (country_id) 
        REFERENCES country(country_id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT
) COMMENT 'Stores addresses for customers and orders';

-- Add indexes for common search patterns
CREATE INDEX idx_address_country ON address(country_id);
CREATE INDEX idx_address_city ON address(city);
CREATE INDEX idx_address_postal_code ON address(postal_code);

-- Create address_status table
CREATE TABLE address_status (
    address_status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(20) NOT NULL UNIQUE COMMENT 'E.g., current, old, billing, shipping'
) COMMENT 'Stores possible statuses for customer addresses';

-- Create customer table
CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    date_registered DATE DEFAULT CURRENT_DATE,
    password_hash VARCHAR(255) COMMENT 'For login credentials',
    birth_date DATE
) COMMENT 'Stores information about bookstore customers';

-- Add indexes for common search patterns
CREATE INDEX idx_customer_name ON customer(last_name, first_name);
CREATE INDEX idx_customer_email ON customer(email);
CREATE INDEX idx_customer_date_registered ON customer(date_registered);

-- Create customer_address junction table
CREATE TABLE customer_address (
    customer_id INT NOT NULL,
    address_id INT NOT NULL,
    address_status_id INT NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    
    -- Define composite primary key
    PRIMARY KEY (customer_id, address_id),
    
    -- Foreign key constraints
    CONSTRAINT fk_custaddress_customer FOREIGN KEY (customer_id) 
        REFERENCES customer(customer_id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_custaddress_address FOREIGN KEY (address_id) 
        REFERENCES address(address_id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_custaddress_status FOREIGN KEY (address_status_id) 
        REFERENCES address_status(address_status_id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT
) COMMENT 'Junction table connecting customers and addresses with status';

-- Add indexes for faster lookups
CREATE INDEX idx_custaddress_address ON customer_address(address_id);
CREATE INDEX idx_custaddress_status ON customer_address(address_status_id);
CREATE INDEX idx_custaddress_default ON customer_address(is_default);

-- Create shipping_method table
CREATE TABLE shipping_method (
    shipping_method_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(50) NOT NULL UNIQUE,
    cost DECIMAL(10,2) NOT NULL,
    estimated_delivery_days INT,
    is_active BOOLEAN DEFAULT TRUE
) COMMENT 'Stores available shipping methods for orders';

-- Add index for active shipping methods
CREATE INDEX idx_shipping_active ON shipping_method(is_active);

-- Now that all tables are created, we can add the foreign key constraints to cust_order table
ALTER TABLE cust_order 
ADD CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) 
    REFERENCES customer(customer_id)
    ON UPDATE CASCADE 
    ON DELETE RESTRICT,
ADD CONSTRAINT fk_order_shipping_address FOREIGN KEY (shipping_address_id) 
    REFERENCES address(address_id)
    ON UPDATE CASCADE 
    ON DELETE RESTRICT,
ADD CONSTRAINT fk_order_billing_address FOREIGN KEY (billing_address_id) 
    REFERENCES address(address_id)
    ON UPDATE CASCADE 
    ON DELETE RESTRICT,
ADD CONSTRAINT fk_order_shipping_method FOREIGN KEY (shipping_method_id) 
    REFERENCES shipping_method(shipping_method_id)
    ON UPDATE CASCADE 
    ON DELETE RESTRICT;

-- =============================================================================
-- SECTION 5: USER ROLES AND ACCESS CONTROL
-- Created by: Nelson Masbayi
-- =============================================================================

-- Create user roles for different access levels
-- Note: In production, use secure passwords

-- Admin user with full privileges
CREATE USER IF NOT EXISTS 'bookstore_admin'@'localhost' IDENTIFIED BY 'admin_secure_password';
GRANT ALL PRIVILEGES ON bookstore_db.* TO 'bookstore_admin'@'localhost';

-- Manager role can view all data and modify inventory and orders
CREATE USER IF NOT EXISTS 'bookstore_manager'@'localhost' IDENTIFIED BY 'manager_secure_password';
GRANT SELECT ON bookstore_db.* TO 'bookstore_manager'@'localhost';
GRANT INSERT, UPDATE, DELETE ON bookstore_db.book TO 'bookstore_manager'@'localhost';
GRANT INSERT, UPDATE, DELETE ON bookstore_db.order_status TO 'bookstore_manager'@'localhost';
GRANT UPDATE ON bookstore_db.cust_order TO 'bookstore_manager'@'localhost';
GRANT INSERT ON bookstore_db.order_history TO 'bookstore_manager'@'localhost';

-- Sales staff can view products and manage orders
CREATE USER IF NOT EXISTS 'bookstore_sales'@'localhost' IDENTIFIED BY 'sales_secure_password';
GRANT SELECT ON bookstore_db.book TO 'bookstore_sales'@'localhost';
GRANT SELECT ON bookstore_db.author TO 'bookstore_sales'@'localhost';
GRANT SELECT ON bookstore_db.publisher TO 'bookstore_sales'@'localhost';
GRANT SELECT ON bookstore_db.customer TO 'bookstore_sales'@'localhost';
GRANT SELECT, INSERT ON bookstore_db.cust_order TO 'bookstore_sales'@'localhost';
GRANT SELECT, INSERT ON bookstore_db.order_line TO 'bookstore_sales'@'localhost';
GRANT SELECT ON bookstore_db.order_status TO 'bookstore_sales'@'localhost';
GRANT SELECT ON bookstore_db.shipping_method TO 'bookstore_sales'@'localhost';

-- Customer service role for managing customer data
CREATE USER IF NOT EXISTS 'bookstore_customer_service'@'localhost' IDENTIFIED BY 'cs_secure_password';
GRANT SELECT, INSERT, UPDATE ON bookstore_db.customer TO 'bookstore_customer_service'@'localhost';
GRANT SELECT, INSERT, UPDATE ON bookstore_db.address TO 'bookstore_customer_service'@'localhost';
GRANT SELECT, INSERT, UPDATE ON bookstore_db.customer_address TO 'bookstore_customer_service'@'localhost';
GRANT SELECT ON bookstore_db.cust_order TO 'bookstore_customer_service'@'localhost';
GRANT SELECT ON bookstore_db.order_line TO 'bookstore_customer_service'@'localhost';
GRANT SELECT ON bookstore_db.order_history TO 'bookstore_customer_service'@'localhost';

-- Read-only role for reporting
CREATE USER IF NOT EXISTS 'bookstore_reports'@'localhost' IDENTIFIED BY 'reports_secure_password';
GRANT SELECT ON bookstore_db.* TO 'bookstore_reports'@'localhost';

-- API application user with limited access
CREATE USER IF NOT EXISTS 'bookstore_api'@'%' IDENTIFIED BY 'api_secure_password';
GRANT SELECT ON bookstore_db.book TO 'bookstore_api'@'%';
GRANT SELECT ON bookstore_db.author TO 'bookstore_api'@'%';
GRANT SELECT ON bookstore_db.publisher TO 'bookstore_api'@'%';
GRANT SELECT ON bookstore_db.book_language TO 'bookstore_api'@'%';
GRANT SELECT, INSERT ON bookstore_db.customer TO 'bookstore_api'@'%';
GRANT SELECT, INSERT ON bookstore_db.cust_order TO 'bookstore_api'@'%';
GRANT SELECT, INSERT ON bookstore_db.order_line TO 'bookstore_api'@'%';

-- Apply the privileges
FLUSH PRIVILEGES;

-- =============================================================================
-- SECTION 6: SAMPLE DATA
-- Created by: Lina Murithi
-- =============================================================================

-- Sample data for book_language
INSERT INTO book_language (language_name, language_code) VALUES
('English', 'EN'),
('Spanish', 'ES'),
('French', 'FR'),
('German', 'DE'),
('Chinese', 'ZH'),
('Japanese', 'JA'),
('Russian', 'RU'),
('Arabic', 'AR');

-- Sample data for publisher
INSERT INTO publisher (publisher_name, contact_name, contact_email, phone, address, website) VALUES
('Penguin Random House', 'John Smith', 'jsmith@prh.com', '+1-212-555-1000', '1745 Broadway, New York, NY 10019', 'www.penguinrandomhouse.com'),
('HarperCollins', 'Emma Johnson', 'ejohnson@harpercollins.com', '+1-212-555-2000', '195 Broadway, New York, NY 10007', 'www.harpercollins.com'),
('Simon & Schuster', 'David Brown', 'dbrown@simonschuster.com', '+1-212-555-3000', '1230 Avenue of the Americas, New York, NY 10020', 'www.simonandschuster.com'),
('Macmillan Publishers', 'Sarah Davis', 'sdavis@macmillan.com', '+1-212-555-4000', '120 Broadway, New York, NY 10271', 'www.macmillan.com'),
('Oxford University Press', 'Michael Wilson', 'mwilson@oup.com', '+44-1865-556000', 'Great Clarendon Street, Oxford, OX2 6DP, UK', 'www.oup.com');

-- Sample data for book
INSERT INTO book (title, isbn13, publication_date, price, publisher_id, language_id, page_count, description, cover_image_url, in_stock, stock_quantity) VALUES
('The Great Gatsby', '9780743273565', '2004-09-30', 15.99, 3, 1, 180, 'A classic novel about the American Dream set in the Jazz Age', 'https://covers.openlibrary.org/b/id/8410745-L.jpg', TRUE, 47),
('To Kill a Mockingbird', '9780061120084', '2006-05-23', 14.99, 2, 1, 336, 'A novel about racial injustice and moral growth in the American South', 'https://covers.openlibrary.org/b/id/8314135-L.jpg', TRUE, 53),
('One Hundred Years of Solitude', '9780060883287', '2006-02-21', 16.99, 2, 1, 417, 'A landmark novel in the magical realism style', 'https://covers.openlibrary.org/b/id/8701264-L.jpg', TRUE, 28),
('Pride and Prejudice', '9780141439518', '2002-12-31', 9.99, 1, 1, 480, 'A romantic novel of manners by Jane Austen', 'https://covers.openlibrary.org/b/id/8717403-L.jpg', TRUE, 62),
('The Hobbit', '9780547928227', '2012-09-18', 14.95, 4, 1, 300, 'A fantasy novel and children\'s book by J.R.R. Tolkien', 'https://covers.openlibrary.org/b/id/8406786-L.jpg', TRUE, 40),
('The Alchemist', '9780062315007', '2014-04-15', 16.99, 2, 1, 208, 'A philosophical novel by Paulo Coelho', 'https://covers.openlibrary.org/b/id/8703459-L.jpg', TRUE, 35),
('The Little Prince', '9780156012195', '2000-06-01', 10.99, 5, 3, 96, 'A poetic tale about a young prince who visits various planets', 'https://covers.openlibrary.org/b/id/8291538-L.jpg', TRUE, 29),
('The Art of War', '9780143037521', '2006-05-30', 13.00, 1, 5, 273, 'An ancient Chinese military treatise', 'https://covers.openlibrary.org/b/id/8708701-L.jpg', TRUE, 25);

-- Sample data for author
INSERT INTO author (first_name, last_name, biography, birth_date, nationality) VALUES
('F. Scott', 'Fitzgerald', 'American novelist and short story writer', '1896-09-24', 'American'),
('Harper', 'Lee', 'American novelist', '1926-04-28', 'American'),
('Gabriel', 'García Márquez', 'Colombian novelist and Nobel Prize winner', '1927-03-06', 'Colombian'),
('Jane', 'Austen', 'English novelist known for romantic fiction', '1775-12-16', 'British'),
('J.R.R.', 'Tolkien', 'English writer, poet, and academic', '1892-01-03', 'British'),
('Paulo', 'Coelho', 'Brazilian lyricist and novelist', '1947-08-24', 'Brazilian'),
('Antoine de', 'Saint-Exupéry', 'French writer, poet, and aviator', '1900-06-29', 'French'),
('Sun', 'Tzu', 'Ancient Chinese general and military strategist', NULL, 'Chinese');

-- Sample data for book_author
INSERT INTO book_author (book_id, author_id, author_order) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1),
(4, 4, 1),
(5, 5, 1),
(6, 6, 1),
(7, 7, 1),
(8, 8, 1);

-- Sample data for country
INSERT INTO country (country_name, country_code) VALUES
('United States', 'US'),
('United Kingdom', 'GB'),
('Canada', 'CA'),
('Australia', 'AU'),
('Germany', 'DE'),
('France', 'FR'),
('Japan', 'JP'),
('Brazil', 'BR'),
('India', 'IN'),
('Kenya', 'KE');

-- Sample data for address
INSERT INTO address (street_address, city, state_province, postal_code, country_id) VALUES
('123 Main St', 'New York', 'NY', '10001', 1),
('456 Park Ave', 'Los Angeles', 'CA', '90001', 1),
('789 Queen St', 'Toronto', 'ON', 'M5V 2A3', 3),
('10 Downing St', 'London', 'England', 'SW1A 2AA', 2),
('50 Rue de Rivoli', 'Paris', 'Île-de-France', '75001', 6),
('222 Exhibition St', 'Melbourne', 'Victoria', '3000', 4),
('1 Kenyatta Ave', 'Nairobi', NULL, '00100', 10),
('7-1 Chome', 'Tokyo', 'Chiyoda', '100-0001', 7);

-- Sample data for address_status
INSERT INTO address_status (status_name) VALUES
('Current'),
('Previous'),
('Billing'),
('Shipping'),
('Business'),
('Vacation');

-- Sample data for customer
INSERT INTO customer (first_name, last_name, email, phone, date_registered, password_hash, birth_date) VALUES
('John', 'Doe', 'john.doe@example.com', '+1-555-123-4567', '2023-01-15', 'hashed_password_1', '1985-06-12'),
('Jane', 'Smith', 'jane.smith@example.com', '+1-555-987-6543', '2023-02-20', 'hashed_password_2', '1990-03-25'),
('Alice', 'Johnson', 'alice.j@example.com', '+1-555-222-3333', '2023-03-10', 'hashed_password_3', '1982-11-30'),
('Robert', 'Brown', 'robert.b@example.com', '+44-7700-900123', '2023-04-05', 'hashed_password_4', '1978-09-15'),
('Emma', 'Wilson', 'emma.w@example.com', '+61-4-1234-5678', '2023-05-12', 'hashed_password_5', '1995-07-22'),
('Carlos', 'Garcia', 'carlos.g@example.com', '+1-555-444-5555', '2023-06-18', 'hashed_password_6', '1988-04-17'),
('Sarah', 'Taylor', 'sarah.t@example.com', '+1-555-777-8888', '2023-07-25', 'hashed_password_7', '1992-12-05'),
('Michael', 'Anderson', 'michael.a@example.com', '+1-555-333-2222', '2023-08-30', 'hashed_password_8', '1975-05-28');

-- Sample data for customer_address
INSERT INTO customer_address (customer_id, address_id, address_status_id, is_default) VALUES
(1, 1, 1, TRUE),
(1, 5, 3, FALSE),
(2, 2, 1, TRUE),
(3, 3, 1, TRUE),
(4, 4, 1, TRUE),
(5, 6, 1, TRUE),
(6, 2, 1, TRUE),
(7, 7, 1, TRUE),
(8, 8, 1, TRUE),
(8, 1, 3, FALSE);

-- Sample data for shipping_method
INSERT INTO shipping_method (method_name, cost, estimated_delivery_days, is_active) VALUES
('Standard Shipping', 4.99, 5, TRUE),
('Express Shipping', 9.99, 2, TRUE),
('Next Day Delivery', 19.99, 1, TRUE),
('International Standard', 14.99, 14, TRUE),
('International Express', 24.99, 7, TRUE),
('Local Pickup', 0.00, 0, TRUE),
('Economy Shipping', 2.99, 10, TRUE),
('Saturday Delivery', 29.99, 1, FALSE);

-- Sample data for order_status
INSERT INTO order_status (status_name, description) VALUES
('Pending', 'Order received, awaiting payment confirmation'),
('Processing', 'Payment confirmed, preparing for shipment'),
('Shipped', 'Order has been shipped'),
('Delivered', 'Order has been delivered'),
('Cancelled', 'Order has been cancelled'),
('Returned', 'Order has been returned by customer'),
('On Hold', 'Order processing paused'),
('Refunded', 'Order payment has been refunded');

-- Sample data for cust_order
INSERT INTO cust_order (customer_id, order_date, shipping_address_id, billing_address_id, shipping_method_id, order_status_id, total_amount, payment_method, payment_transaction_id, special_instructions) VALUES
(1, '2023-10-15 10:30:00', 1, 1, 1, 3, 35.97, 'Credit Card', 'TXN12345678', 'Please leave at front door'),
(2, '2023-10-20 14:45:00', 2, 2, 2, 3, 46.97, 'PayPal', 'PP87654321', NULL),
(3, '2023-11-05 09:15:00', 3, 3, 1, 4, 14.99, 'Credit Card', 'TXN23456789', NULL),
(4, '2023-11-10 16:20:00', 4, 4, 5, 2, 39.98, 'Bank Transfer', 'BT34567890', 'Gift wrap please'),
(5, '2023-11-15 11:05:00', 6, 6, 1, 1, 15.99, 'Credit Card', 'TXN45678901', NULL),
(1, '2023-12-01 13:30:00', 1, 5, 3, 4, 59.97, 'Credit Card', 'TXN56789012', 'This is a gift'),
(6, '2023-12-10 10:45:00', 2, 2, 1, 5, 29.98, 'PayPal', 'PP67890123', NULL),
(7, '2023-12-15 09:00:00', 7, 7, 4, 2, 44.97, 'Credit Card', 'TXN78901234', 'Call before delivery');

-- Sample data for order_line
INSERT INTO order_line (order_id, book_id, quantity, price_at_time_of_order, discount_amount) VALUES
(1, 1, 1, 15.99, 0.00),
(1, 2, 1, 14.99, 0.00),
(1, 3, 1, 16.99, 12.00),
(2, 4, 1, 9.99, 0.00),
(2, 5, 1, 14.95, 0.00),
(2, 6, 1, 16.99, 0.00),
(2, 7, 1, 10.99, 5.95),
(3, 2, 1, 14.99, 0.00),
(4, 1, 1, 15.99, 0.00),
(4, 4, 1, 9.99, 0.00),
(4, 8, 1, 13.00, 0.00),
(5, 1, 1, 15.99, 0.00),
(6, 5, 1, 14.95, 0.00),
(6, 6, 1, 16.99, 0.00),
(6, 8, 1, 13.00, 0.00),
(7, 2, 2, 14.99, 0.00),
(8, 3, 1, 16.99, 0.00),
(8, 7, 1, 10.99, 0.00),
(8, 8, 1, 13.00, 0.00);

-- Sample data for order_history
INSERT INTO order_history (order_id, order_status_id, status_change_date, notes, updated_by) VALUES
(1, 1, '2023-10-15 10:30:00', 'Order placed', 'system'),
(1, 2, '2023-10-15 10:45:00', 'Payment confirmed', 'system'),
(1, 3, '2023-10-16 09:30:00', 'Order shipped via Standard Shipping', 'staff_id_123'),
(2, 1, '2023-10-20 14:45:00', 'Order placed', 'system'),
(2, 2, '2023-10-20 15:00:00', 'Payment confirmed', 'system'),
(2, 3, '2023-10-21 11:15:00', 'Order shipped via Express Shipping', 'staff_id_456'),
(3, 1, '2023-11-05 09:15:00', 'Order placed', 'system'),
(3, 2, '2023-11-05 09:30:00', 'Payment confirmed', 'system'),
(3, 3, '2023-11-06 10:00:00', 'Order shipped via Standard Shipping', 'staff_id_123'),
(3, 4, '2023-11-10 16:30:00', 'Order delivered', 'system'),
(4, 1, '2023-11-10 16:20:00', 'Order placed', 'system'),
(4, 2, '2023-11-11 09:45:00', 'Payment confirmed', 'system'),
(5, 1, '2023-11-15 11:05:00', 'Order placed', 'system'),
(6, 1, '2023-12-01 13:30:00', 'Order placed', 'system'),
(6, 2, '2023-12-01 13:45:00', 'Payment confirmed', 'system'),
(6, 3, '2023-12-01 15:30:00', 'Order shipped via Next Day Delivery', 'staff_id_789'),
(6, 4, '2023-12-02 14:15:00', 'Order delivered', 'system'),
(7, 1, '2023-12-10 10:45:00', 'Order placed', 'system'),
(7, 2, '2023-12-10 11:00:00', 'Payment confirmed', 'system'),
(7, 5, '2023-12-11 09:30:00', 'Customer requested cancellation', 'staff_id_123'),
(8, 1, '2023-12-15 09:00:00', 'Order placed', 'system'),
(8, 2, '2023-12-15 09:15:00', 'Payment confirmed', 'system');

-- =============================================================================
-- SECTION 7: DATABASE VALIDATION
-- Created by: Ivy Anyango
-- =============================================================================

-- Verify all tables exist
SELECT 'Verifying all tables exist' AS test_name;
SELECT
    CASE
        WHEN COUNT(*) = 15 THEN 'PASS: All 15 tables exist'
        ELSE CONCAT('FAIL: Expected 15 tables, found ', COUNT(*), ' tables')
    END AS result
FROM
    information_schema.tables
WHERE
    table_schema = 'bookstore_db'
    AND table_type = 'BASE TABLE';

-- Validate data integrity (sample validation query)
SELECT 'Checking for orphaned book records' AS test_name;
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS: No orphaned book records found'
        ELSE CONCAT('FAIL: ', COUNT(*), ' books have missing publisher or language references')
    END AS result
FROM
    book b
LEFT JOIN
    publisher p ON b.publisher_id = p.publisher_id
LEFT JOIN
    book_language l ON b.language_id = l.language_id
WHERE
    p.publisher_id IS NULL OR l.language_id IS NULL;

-- Check for books without authors
SELECT 'Checking for books without authors' AS test_name;
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS: All books have at least one author'
        ELSE CONCAT('FAIL: ', COUNT(*), ' books have no authors assigned')
    END AS result
FROM
    book b
LEFT JOIN
    book_author ba ON b.book_id = ba.book_id
WHERE
    ba.author_id IS NULL;

-- =============================================================================
-- SECTION 8: EXAMPLE QUERIES
-- =============================================================================

-- 1. Books with their authors
-- Shows the many-to-many relationship between books and authors
SELECT 
    b.book_id,
    b.title,
    b.isbn13,
    CONCAT(a.first_name, ' ', a.last_name) AS author_name,
    ba.author_order
FROM 
    book b
JOIN 
    book_author ba ON b.book_id = ba.book_id
JOIN 
    author a ON ba.author_id = a.author_id
ORDER BY 
    b.title, ba.author_order;

-- 2. Books with publisher and language information
-- Shows the many-to-one relationships between books, publishers, and languages
SELECT 
    b.book_id,
    b.title,
    p.publisher_name,
    l.language_name,
    b.publication_date,
    b.price
FROM 
    book b
JOIN 
    publisher p ON b.publisher_id = p.publisher_id
JOIN 
    book_language l ON b.language_id = l.language_id
ORDER BY 
    p.publisher_name, b.title;

-- 3. Book inventory report
-- Shows book inventory with publisher and author information
SELECT 
    b.book_id,
    b.title,
    b.isbn13,
    GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) ORDER BY ba.author_order SEPARATOR ', ') AS authors,
    p.publisher_name,
    b.price,
    b.stock_quantity,
    CASE WHEN b.in_stock THEN 'Yes' ELSE 'No' END AS available
FROM 
    book b
JOIN 
    publisher p ON b.publisher_id = p.publisher_id
LEFT JOIN 
    book_author ba ON b.book_id = ba.book_id
LEFT JOIN 
    author a ON ba.author_id = a.author_id
GROUP BY 
    b.book_id
ORDER BY 
    b.stock_quantity DESC;

-- 4. Customer orders with shipping and billing addresses
-- Shows the relationships between customers, orders, and addresses
SELECT 
    co.order_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS customer_name,
    co.order_date,
    sa.street_address AS shipping_street,
    sa.city AS shipping_city,
    sc.country_name AS shipping_country,
    ba.street_address AS billing_street,
    ba.city AS billing_city,
    bc.country_name AS billing_country,
    sm.method_name AS shipping_method,
    os.status_name AS order_status,
    co.total_amount
FROM 
    cust_order co
JOIN 
    customer cu ON co.customer_id = cu.customer_id
JOIN 
    address sa ON co.shipping_address_id = sa.address_id
JOIN 
    country sc ON sa.country_id = sc.country_id
JOIN 
    address ba ON co.billing_address_id = ba.address_id
JOIN 
    country bc ON ba.country_id = bc.country_id
JOIN 
    shipping_method sm ON co.shipping_method_id = sm.shipping_method_id
JOIN 
    order_status os ON co.order_status_id = os.order_status_id
ORDER BY 
    co.order_date DESC;

-- 5. Order history tracking
-- Shows the one-to-many relationship between orders and their status history
SELECT 
    co.order_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS customer_name,
    oh.status_change_date,
    os.status_name,
    oh.notes,
    oh.updated_by
FROM 
    order_history oh
JOIN 
    cust_order co ON oh.order_id = co.order_id
JOIN 
    customer cu ON co.customer_id = cu.customer_id
JOIN 
    order_status os ON oh.order_status_id = os.order_status_id
ORDER BY 
    co.order_id, oh.status_change_date;

-- Database setup complete
SELECT 'BookstoreDB setup completed successfully' AS 'Status';