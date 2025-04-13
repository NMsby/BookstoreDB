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