-- BookstoreDB: Customer and Shipping-related Tables Creation Script
-- Created: April 2025
-- Author: Ivy Anyango

-- Use the bookstore database
USE bookstore_db;

-- Create country table
CREATE TABLE country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE,
    country_code CHAR(2) NOT NULL UNIQUE COMMENT 'ISO 3166-1 alpha-2 country code'
) COMMENT 'Stores countries for customer addresses';

-- Add index for faster lookups
CREATE INDEX idx_country_code ON country(country_code);

-- Output confirmation message
SELECT 'country table created successfully' AS 'Status';


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

-- Output confirmation message
SELECT 'address table created successfully' AS 'Status';


-- Create address_status table
CREATE TABLE address_status (
    address_status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(20) NOT NULL UNIQUE COMMENT 'E.g., current, old, billing, shipping'
) COMMENT 'Stores possible statuses for customer addresses';

-- Output confirmation message
SELECT 'address_status table created successfully' AS 'Status';


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

-- Output confirmation message
SELECT 'customer table created successfully' AS 'Status';


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

-- Output confirmation message
SELECT 'customer_address junction table created successfully' AS 'Status';


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

-- Output confirmation message
SELECT 'shipping_method table created successfully' AS 'Status';

-- Now that all tables are created, we can add the foreign key constraints to cust_order table that reference tables created here
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

-- Output confirmation message
SELECT 'Foreign key constraints added to cust_order table' AS 'Status';