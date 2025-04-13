-- BookstoreDB: Book-related Tables Creation Script
-- Created: April 2025
-- Author: Nelson Masbayi

-- Use the bookstore database
USE bookstore_db;

-- Create book_language table
CREATE TABLE book_language (
    language_id INT AUTO_INCREMENT PRIMARY KEY,
    language_name VARCHAR(50) NOT NULL UNIQUE,
    language_code CHAR(2) NOT NULL UNIQUE COMMENT 'ISO 639-1 language code'
) COMMENT 'Stores languages available for books';

-- Add index for faster language lookups
CREATE INDEX idx_language_code ON book_language(language_code);

-- Output confirmation message
SELECT 'book_language table created successfully' AS 'Status';

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

-- Output confirmation message
SELECT 'publisher table created successfully' AS 'Status';