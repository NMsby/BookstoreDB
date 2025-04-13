-- BookstoreDB: Master Setup Script
-- Created: April 2025
-- Author: Nelson Masbayi

-- This script executes all the database setup scripts in the correct order

-- Step 1: Create the database
SOURCE sql/01_create_database.sql;

-- Step 2: Create book-related tables
SOURCE sql/02_create_tables_books.sql;

-- Step 3: Create author and order-related tables
SOURCE sql/03_create_tables_authors_orders.sql;

-- Step 4: Create customer and shipping-related tables
SOURCE sql/04_create_tables_customers_shipping.sql;

-- Step 5: Set up user roles and permissions
SOURCE sql/03_create_users.sql;

-- Output completion message
SELECT 'Complete database setup finished successfully' AS 'Status';