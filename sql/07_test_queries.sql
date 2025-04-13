-- BookstoreDB: Sample Queries for Testing Relationships
-- Created: April 2025
-- Author: Lina Murithi

-- Use the bookstore database
USE bookstore_db;

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

-- 3. Customer orders with shipping and billing addresses
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

-- 4. Order details with books
-- Shows the relationship between orders and books via order_line
SELECT 
    co.order_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS customer_name,
    co.order_date,
    b.title AS book_title,
    ol.quantity,
    ol.price_at_time_of_order,
    ol.discount_amount,
    (ol.price_at_time_of_order - ol.discount_amount) * ol.quantity AS line_total
FROM 
    cust_order co
JOIN 
    customer cu ON co.customer_id = cu.customer_id
JOIN 
    order_line ol ON co.order_id = ol.order_id
JOIN 
    book b ON ol.book_id = b.book_id
ORDER BY 
    co.order_id, ol.order_line_id;

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

-- 6. Customer's multiple addresses
-- Shows the many-to-many relationship between customers and addresses
SELECT 
    cu.customer_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS customer_name,
    a.street_address,
    a.city,
    a.state_province,
    co.country_name,
    addr_status.status_name AS address_type,
    ca.is_default
FROM 
    customer cu
JOIN 
    customer_address ca ON cu.customer_id = ca.customer_id
JOIN 
    address a ON ca.address_id = a.address_id
JOIN 
    country co ON a.country_id = co.country_id
JOIN 
    address_status addr_status ON ca.address_status_id = addr_status.address_status_id
ORDER BY 
    cu.last_name, cu.first_name, ca.is_default DESC;

-- 7. Book inventory report
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

-- 8. Sales by book (aggregation query)
-- Shows total sales quantities and amounts by book
SELECT 
    b.book_id,
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) AS primary_author,
    COUNT(DISTINCT ol.order_id) AS number_of_orders,
    SUM(ol.quantity) AS total_quantity_sold,
    SUM((ol.price_at_time_of_order - ol.discount_amount) * ol.quantity) AS total_revenue
FROM 
    book b
JOIN 
    book_author ba ON b.book_id = ba.book_id AND ba.author_order = 1
JOIN 
    author a ON ba.author_id = a.author_id
JOIN 
    order_line ol ON b.book_id = ol.book_id
JOIN 
    cust_order co ON ol.order_id = co.order_id
WHERE 
    co.order_status_id NOT IN (SELECT order_status_id FROM order_status WHERE status_name IN ('Cancelled', 'Returned'))
GROUP BY 
    b.book_id, a.author_id
ORDER BY 
    total_revenue DESC;

-- 9. Customer purchase history
-- Shows all orders and items for a specific customer
SELECT 
    co.order_id,
    co.order_date,
    os.status_name AS order_status,
    b.title,
    ol.quantity,
    ol.price_at_time_of_order,
    ol.discount_amount,
    (ol.price_at_time_of_order - ol.discount_amount) * ol.quantity AS line_total,
    sm.method_name AS shipping_method
FROM 
    customer cu
JOIN 
    cust_order co ON cu.customer_id = co.customer_id
JOIN 
    order_status os ON co.order_status_id = os.order_status_id
JOIN 
    order_line ol ON co.order_id = ol.order_id
JOIN 
    book b ON ol.book_id = b.book_id
JOIN 
    shipping_method sm ON co.shipping_method_id = sm.shipping_method_id
WHERE 
    cu.customer_id = 1  -- Example: Customer with ID 1
ORDER BY 
    co.order_date DESC, ol.order_line_id;

-- 10. Complex query: Sales report by country and month
-- Shows sales aggregated by customer country and month
SELECT 
    c.country_name,
    DATE_FORMAT(co.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT co.order_id) AS number_of_orders,
    COUNT(DISTINCT co.customer_id) AS number_of_customers,
    SUM(co.total_amount) AS total_sales,
    AVG(co.total_amount) AS average_order_value
FROM 
    cust_order co
JOIN 
    address a ON co.shipping_address_id = a.address_id
JOIN 
    country c ON a.country_id = c.country_id
WHERE 
    co.order_status_id NOT IN (SELECT order_status_id FROM order_status WHERE status_name IN ('Cancelled', 'Returned'))
GROUP BY 
    c.country_id, DATE_FORMAT(co.order_date, '%Y-%m')
ORDER BY 
    c.country_name, month;