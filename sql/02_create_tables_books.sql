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

-- Output confirmation message
SELECT 'book table created successfully' AS 'Status';