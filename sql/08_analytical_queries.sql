-- BookstoreDB: Analytical Queries for Data Retrieval and Analysis
-- Created: April 2025
-- Author: Ivy Anyango

-- Use the bookstore database
USE bookstore_db;

-- 1. Top selling books by quantity
-- Provides insights into which books are most popular
SELECT 
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) AS primary_author,
    SUM(ol.quantity) AS total_sold,
    SUM((ol.price_at_time_of_order - ol.discount_amount) * ol.quantity) AS total_revenue
FROM 
    book b
JOIN 
    order_line ol ON b.book_id = ol.book_id
JOIN 
    book_author ba ON b.book_id = ba.book_id AND ba.author_order = 1
JOIN 
    author a ON ba.author_id = a.author_id
JOIN 
    cust_order co ON ol.order_id = co.order_id
WHERE 
    co.order_status_id NOT IN (SELECT order_status_id FROM order_status WHERE status_name IN ('Cancelled', 'Returned'))
GROUP BY 
    b.book_id, a.author_id
ORDER BY 
    total_sold DESC
LIMIT 10;

-- 2. Sales trend by month
-- Shows monthly sales patterns for business planning
SELECT 
    DATE_FORMAT(co.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT co.order_id) AS number_of_orders,
    SUM(co.total_amount) AS total_sales,
    COUNT(DISTINCT co.customer_id) AS number_of_customers,
    SUM(co.total_amount) / COUNT(DISTINCT co.order_id) AS average_order_value
FROM 
    cust_order co
WHERE 
    co.order_status_id NOT IN (SELECT order_status_id FROM order_status WHERE status_name IN ('Cancelled', 'Returned'))
GROUP BY 
    DATE_FORMAT(co.order_date, '%Y-%m')
ORDER BY 
    month;

-- 3. Publisher performance analysis
-- Helps identify the most profitable publishing partnerships
SELECT 
    p.publisher_name,
    COUNT(DISTINCT b.book_id) AS number_of_books,
    SUM(b.stock_quantity) AS total_stock,
    COUNT(DISTINCT ol.order_id) AS number_of_orders,
    SUM(ol.quantity) AS quantity_sold,
    SUM((ol.price_at_time_of_order - ol.discount_amount) * ol.quantity) AS total_revenue,
    SUM((ol.price_at_time_of_order - ol.discount_amount) * ol.quantity) / SUM(ol.quantity) AS average_selling_price
FROM 
    publisher p
LEFT JOIN 
    book b ON p.publisher_id = b.publisher_id
LEFT JOIN 
    order_line ol ON b.book_id = ol.book_id
LEFT JOIN 
    cust_order co ON ol.order_id = co.order_id AND co.order_status_id NOT IN (SELECT order_status_id FROM order_status WHERE status_name IN ('Cancelled', 'Returned'))
GROUP BY 
    p.publisher_id
ORDER BY 
    total_revenue DESC;

-- 4. Customer lifetime value
-- Critical metric for understanding customer acquisition and retention economics
SELECT 
    cu.customer_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS customer_name,
    MIN(co.order_date) AS first_purchase_date,
    MAX(co.order_date) AS most_recent_purchase,
    DATEDIFF(MAX(co.order_date), MIN(co.order_date)) AS days_as_customer,
    COUNT(DISTINCT co.order_id) AS number_of_orders,
    SUM(co.total_amount) AS lifetime_value,
    SUM(co.total_amount) / COUNT(DISTINCT co.order_id) AS average_order_value
FROM 
    customer cu
JOIN 
    cust_order co ON cu.customer_id = co.customer_id
WHERE 
    co.order_status_id NOT IN (SELECT order_status_id FROM order_status WHERE status_name IN ('Cancelled', 'Returned'))
GROUP BY 
    cu.customer_id
ORDER BY 
    lifetime_value DESC;

-- 5. Book language popularity
-- Shows which languages sell the most books
SELECT 
    bl.language_name,
    COUNT(DISTINCT b.book_id) AS number_of_books,
    SUM(ol.quantity) AS books_sold,
    SUM((ol.price_at_time_of_order - ol.discount_amount) * ol.quantity) AS total_revenue
FROM 
    book_language bl
LEFT JOIN 
    book b ON bl.language_id = b.language_id
LEFT JOIN 
    order_line ol ON b.book_id = ol.book_id
LEFT JOIN 
    cust_order co ON ol.order_id = co.order_id AND co.order_status_id NOT IN (SELECT order_status_id FROM order_status WHERE status_name IN ('Cancelled', 'Returned'))
GROUP BY 
    bl.language_id
ORDER BY 
    books_sold DESC;

-- 6. Shipping method efficiency
-- Analyzes which shipping methods are most popular and profitable
SELECT 
    sm.method_name,
    COUNT(co.order_id) AS number_of_orders,
    AVG(DATEDIFF(
        (SELECT MIN(status_change_date) FROM order_history oh2 
         WHERE oh2.order_id = co.order_id AND oh2.order_status_id = (SELECT order_status_id FROM order_status WHERE status_name = 'Delivered')),
        (SELECT MIN(status_change_date) FROM order_history oh3 
         WHERE oh3.order_id = co.order_id AND oh3.order_status_id = (SELECT order_status_id FROM order_status WHERE status_name = 'Shipped'))
    )) AS avg_delivery_days,
    SUM(co.total_amount) AS total_order_value,
    SUM(sm.cost) AS shipping_revenue
FROM 
    shipping_method sm
JOIN 
    cust_order co ON sm.shipping_method_id = co.shipping_method_id
WHERE 
    co.order_status_id IN (SELECT order_status_id FROM order_status WHERE status_name IN ('Shipped', 'Delivered'))
GROUP BY 
    sm.shipping_method_id
ORDER BY 
    number_of_orders DESC;

-- 7. Inventory turnover analysis
-- Helps identify slow and fast-moving inventory
SELECT 
    b.book_id,
    b.title,
    b.stock_quantity AS current_stock,
    COALESCE(SUM(ol.quantity), 0) AS total_sold,
    CASE 
        WHEN b.stock_quantity > 0 AND COALESCE(SUM(ol.quantity), 0) > 0 
        THEN COALESCE(SUM(ol.quantity), 0) / b.stock_quantity 
        ELSE 0 
    END AS inventory_turnover_ratio,
    CASE
        WHEN b.stock_quantity < 10 AND COALESCE(SUM(ol.quantity), 0) > 20 THEN 'Restock Soon'
        WHEN b.stock_quantity > 50 AND COALESCE(SUM(ol.quantity), 0) < 5 THEN 'Overstocked'
        WHEN b.stock_quantity = 0 THEN 'Out of Stock'
        ELSE 'Healthy Inventory'
    END AS inventory_status
FROM 
    book b
LEFT JOIN 
    order_line ol ON b.book_id = ol.book_id
LEFT JOIN 
    cust_order co ON ol.order_id = co.order_id AND co.order_status_id NOT IN (SELECT order_status_id FROM order_status WHERE status_name IN ('Cancelled', 'Returned'))
GROUP BY 
    b.book_id
ORDER BY 
    inventory_turnover_ratio DESC;

-- 8. Geographic sales distribution
-- Provides insights for regional marketing and expansion
SELECT 
    c.country_name,
    COUNT(DISTINCT co.order_id) AS number_of_orders,
    COUNT(DISTINCT co.customer_id) AS number_of_customers,
    SUM(co.total_amount) AS total_sales,
    SUM(co.total_amount) / COUNT(DISTINCT co.order_id) AS average_order_value
FROM 
    cust_order co
JOIN 
    address a ON co.shipping_address_id = a.address_id
JOIN 
    country c ON a.country_id = c.country_id
WHERE 
    co.order_status_id NOT IN (SELECT order_status_id FROM order_status WHERE status_name IN ('Cancelled', 'Returned'))
GROUP BY 
    c.country_id
ORDER BY 
    total_sales DESC;

-- 9. Customer acquisition by month
-- Shows when new customers are being added
SELECT 
    DATE_FORMAT(date_registered, '%Y-%m') AS month,
    COUNT(*) AS new_customers,
    (SELECT COUNT(*) FROM customer WHERE date_registered < DATE_FORMAT(CONCAT(month, '-01'), '%Y-%m-%d')) AS cumulative_customers
FROM 
    customer
GROUP BY 
    month
ORDER BY 
    month;

-- 10. Order fulfillment performance
-- Measures operational efficiency in processing orders
SELECT 
    DATE_FORMAT(co.order_date, '%Y-%m') AS month,
    COUNT(co.order_id) AS total_orders,
    AVG(TIMESTAMPDIFF(HOUR, 
        co.order_date, 
        (SELECT MIN(oh.status_change_date) FROM order_history oh 
         WHERE oh.order_id = co.order_id AND oh.order_status_id = (SELECT order_status_id FROM order_status WHERE status_name = 'Processing'))
    )) AS avg_processing_time_hours,
    AVG(TIMESTAMPDIFF(HOUR, 
        (SELECT MIN(oh.status_change_date) FROM order_history oh 
         WHERE oh.order_id = co.order_id AND oh.order_status_id = (SELECT order_status_id FROM order_status WHERE status_name = 'Processing')),
        (SELECT MIN(oh.status_change_date) FROM order_history oh 
         WHERE oh.order_id = co.order_id AND oh.order_status_id = (SELECT order_status_id FROM order_status WHERE status_name = 'Shipped'))
    )) AS avg_shipping_prep_time_hours
FROM 
    cust_order co
WHERE 
    co.order_id IN (
        SELECT DISTINCT order_id FROM order_history 
        WHERE order_status_id IN (SELECT order_status_id FROM order_status WHERE status_name IN ('Processing', 'Shipped'))
    )
GROUP BY 
    month
ORDER BY 
    month;