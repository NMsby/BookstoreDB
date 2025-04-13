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