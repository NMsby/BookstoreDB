-- BookstoreDB: Author and Order-related Tables Creation Script
-- Created: April 2025
-- Author: Lina Murithi

-- Use the bookstore database
USE bookstore_db;

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

-- Output confirmation message
SELECT 'author table created successfully' AS 'Status';


-- Create order_status table
CREATE TABLE order_status (
    order_status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE COMMENT 'E.g., pending, shipped, delivered, cancelled',
    description VARCHAR(255)
) COMMENT 'Stores possible statuses for customer orders';

-- Output confirmation message
SELECT 'order_status table created successfully' AS 'Status';