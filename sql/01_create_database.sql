-- BookstoreDB: Database Creation Script
-- Created: April 2025
-- Author: Nelson Masbayi

-- Drop database if it exists (use with caution in production)
DROP DATABASE IF EXISTS bookstore_db;

-- Create the database with proper character set and collation
CREATE DATABASE bookstore_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Select the database for use
USE bookstore_db;

-- Output confirmation message
SELECT 'BookstoreDB created successfully' AS 'Status';

-- Note: Additional database configuration goes here if needed
-- For example: setting global variables, etc.