-- BookstoreDB: Database Validation and Consistency Checks
-- Created: April 2025
-- Author: Ivy Anyango

-- Use the bookstore database
USE bookstore_db;

-- Section 1: Schema Validation Tests
-- These queries verify the database structure is correct

-- 1.1 Check that all required tables exist
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
    
-- 1.2 Validate primary keys exist on all tables
SELECT 'Verifying primary keys on all tables' AS test_name;
WITH expected_tables AS (
    SELECT 'book' AS table_name UNION ALL
    SELECT 'book_author' UNION ALL
    SELECT 'author' UNION ALL
    SELECT 'book_language' UNION ALL
    SELECT 'publisher' UNION ALL
    SELECT 'customer' UNION ALL
    SELECT 'customer_address' UNION ALL
    SELECT 'address_status' UNION ALL
    SELECT 'address' UNION ALL
    SELECT 'country' UNION ALL
    SELECT 'cust_order' UNION ALL
    SELECT 'order_line' UNION ALL
    SELECT 'shipping_method' UNION ALL
    SELECT 'order_history' UNION ALL
    SELECT 'order_status'
)
SELECT
    CASE
        WHEN COUNT(*) = (SELECT COUNT(*) FROM expected_tables) THEN 'PASS: All tables have primary keys'
        ELSE CONCAT('FAIL: ', (SELECT COUNT(*) FROM expected_tables) - COUNT(*), ' tables missing primary keys')
    END AS result
FROM (
    SELECT DISTINCT table_name
    FROM information_schema.table_constraints
    WHERE constraint_type = 'PRIMARY KEY'
    AND table_schema = 'bookstore_db'
    AND table_name IN (SELECT table_name FROM expected_tables)
) AS tables_with_pk;

-- 1.3 Validate foreign keys exist
SELECT 'Verifying foreign key relationships' AS test_name;
SELECT
    CASE
        WHEN COUNT(*) >= 15 THEN 'PASS: Foreign key relationships are defined'
        ELSE CONCAT('FAIL: Only ', COUNT(*), ' foreign key relationships found, expected at least 15')
    END AS result
FROM
    information_schema.table_constraints
WHERE
    constraint_type = 'FOREIGN KEY'
    AND table_schema = 'bookstore_db';

-- Section 2: Data Integrity Tests
-- These queries verify data consistency across related tables

-- 2.1 Check for orphaned book records (books without language or publisher)
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

-- 2.2 Check for books without authors
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

-- 2.3 Check for orders with invalid customers
SELECT 'Checking for orders with invalid customers' AS test_name;
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS: All orders have valid customers'
        ELSE CONCAT('FAIL: ', COUNT(*), ' orders have invalid customer references')
    END AS result
FROM
    cust_order co
LEFT JOIN
    customer c ON co.customer_id = c.customer_id
WHERE
    c.customer_id IS NULL;

-- 2.4 Check for order lines with invalid orders or books
SELECT 'Checking for order lines with invalid references' AS test_name;
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS: All order lines have valid order and book references'
        ELSE CONCAT('FAIL: ', COUNT(*), ' order lines have invalid references')
    END AS result
FROM
    order_line ol
LEFT JOIN
    cust_order co ON ol.order_id = co.order_id
LEFT JOIN
    book b ON ol.book_id = b.book_id
WHERE
    co.order_id IS NULL OR b.book_id IS NULL;

-- 2.5 Check for order history entries with invalid orders or statuses
SELECT 'Checking for order history with invalid references' AS test_name;
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS: All order history entries have valid references'
        ELSE CONCAT('FAIL: ', COUNT(*), ' order history entries have invalid references')
    END AS result
FROM
    order_history oh
LEFT JOIN
    cust_order co ON oh.order_id = co.order_id
LEFT JOIN
    order_status os ON oh.order_status_id = os.order_status_id
WHERE
    co.order_id IS NULL OR os.order_status_id IS NULL;

-- 2.6 Check for customer addresses with invalid references
SELECT 'Checking for customer addresses with invalid references' AS test_name;
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS: All customer addresses have valid references'
        ELSE CONCAT('FAIL: ', COUNT(*), ' customer addresses have invalid references')
    END AS result
FROM
    customer_address ca
LEFT JOIN
    customer c ON ca.customer_id = c.customer_id
LEFT JOIN
    address a ON ca.address_id = a.address_id
LEFT JOIN
    address_status ast ON ca.address_status_id = ast.address_status_id
WHERE
    c.customer_id IS NULL OR a.address_id IS NULL OR ast.address_status_id IS NULL;

-- 2.7 Check for addresses with invalid country references
SELECT 'Checking for addresses with invalid country references' AS test_name;
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS: All addresses have valid country references'
        ELSE CONCAT('FAIL: ', COUNT(*), ' addresses have invalid country references')
    END AS result
FROM
    address a
LEFT JOIN
    country c ON a.country_id = c.country_id
WHERE
    c.country_id IS NULL;

-- 2.8 Check for negative prices or quantities
SELECT 'Checking for negative prices or quantities' AS test_name;
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS: No negative prices or quantities found'
        ELSE CONCAT('FAIL: ', COUNT(*), ' records have negative prices or quantities')
    END AS result
FROM (
    SELECT book_id FROM book WHERE price < 0 OR stock_quantity < 0
    UNION ALL
    SELECT order_line_id FROM order_line WHERE quantity < 0 OR price_at_time_of_order < 0 OR discount_amount < 0
    UNION ALL
    SELECT shipping_method_id FROM shipping_method WHERE cost < 0
) AS negative_values;

-- 2.9 Check for duplicate ISBN values
SELECT 'Checking for duplicate ISBN values' AS test_name;
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS: No duplicate ISBN values found'
        ELSE CONCAT('FAIL: ', COUNT(*), ' duplicate ISBN values found')
    END AS result
FROM (
    SELECT isbn13, COUNT(*) AS dupes
    FROM book
    WHERE isbn13 IS NOT NULL
    GROUP BY isbn13
    HAVING COUNT(*) > 1
) AS duplicate_isbns;

-- 2.10 Validate current order statuses against order history
SELECT 'Validating order statuses against history' AS test_name;
WITH latest_status AS (
    SELECT 
        oh.order_id,
        oh.order_status_id,
        ROW_NUMBER() OVER (PARTITION BY oh.order_id ORDER BY oh.status_change_date DESC) AS rn
    FROM order_history oh
)
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS: All order statuses match their latest history entry'
        ELSE CONCAT('FAIL: ', COUNT(*), ' orders have status inconsistent with history')
    END AS result
FROM
    cust_order co
JOIN
    latest_status ls ON co.order_id = ls.order_id AND ls.rn = 1
WHERE
    co.order_status_id != ls.order_status_id;

-- Section 3: Data Completeness Tests
-- These queries verify required data is present

-- 3.1 Check for books missing critical information
SELECT 'Checking for books missing critical information' AS test_name;
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS: All books have complete critical information'
        ELSE CONCAT('FAIL: ', COUNT(*), ' books missing critical information')
    END AS result
FROM
    book
WHERE
    title IS NULL OR 
    publication_date IS NULL OR 
    price IS NULL OR
    publisher_id IS NULL OR
    language_id IS NULL;

-- 3.2 Check for customers missing contact information
SELECT 'Checking for customers missing contact information' AS test_name;
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS: All customers have contact information'
        ELSE CONCAT('FAIL: ', COUNT(*), ' customers missing email or phone')
    END AS result
FROM
    customer
WHERE
    email IS NULL OR 
    (phone IS NULL AND email IS NULL);

-- 3.3 Check for orders missing essential information
SELECT 'Checking for orders missing essential information' AS test_name;
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS: All orders have complete essential information'
        ELSE CONCAT('FAIL: ', COUNT(*), ' orders missing essential information')
    END AS result
FROM
    cust_order
WHERE
    customer_id IS NULL OR 
    order_date IS NULL OR
    order_status_id IS NULL;

-- Summary of all validation checks
SELECT 'Database Validation Complete' AS message;