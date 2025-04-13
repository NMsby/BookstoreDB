-- BookstoreDB: User and Role Management Script
-- Created: April 2025
-- Author: Nelson Masbayi

-- Use the bookstore database
USE bookstore_db;

-- Create user roles for different access levels
-- Note: In production, use secure passwords

-- Admin user with full privileges
CREATE USER IF NOT EXISTS 'bookstore_admin'@'localhost' IDENTIFIED BY 'admin_secure_password';
GRANT ALL PRIVILEGES ON bookstore_db.* TO 'bookstore_admin'@'localhost';

-- Manager role can view all data and modify inventory and orders
CREATE USER IF NOT EXISTS 'bookstore_manager'@'localhost' IDENTIFIED BY 'manager_secure_password';
GRANT SELECT ON bookstore_db.* TO 'bookstore_manager'@'localhost';
GRANT INSERT, UPDATE, DELETE ON bookstore_db.book TO 'bookstore_manager'@'localhost';
GRANT INSERT, UPDATE, DELETE ON bookstore_db.order_status TO 'bookstore_manager'@'localhost';
GRANT UPDATE ON bookstore_db.cust_order TO 'bookstore_manager'@'localhost';
GRANT INSERT ON bookstore_db.order_history TO 'bookstore_manager'@'localhost';

-- Sales staff can view products and manage orders
CREATE USER IF NOT EXISTS 'bookstore_sales'@'localhost' IDENTIFIED BY 'sales_secure_password';
GRANT SELECT ON bookstore_db.book TO 'bookstore_sales'@'localhost';
GRANT SELECT ON bookstore_db.author TO 'bookstore_sales'@'localhost';
GRANT SELECT ON bookstore_db.publisher TO 'bookstore_sales'@'localhost';
GRANT SELECT ON bookstore_db.customer TO 'bookstore_sales'@'localhost';
GRANT SELECT, INSERT ON bookstore_db.cust_order TO 'bookstore_sales'@'localhost';
GRANT SELECT, INSERT ON bookstore_db.order_line TO 'bookstore_sales'@'localhost';
GRANT SELECT ON bookstore_db.order_status TO 'bookstore_sales'@'localhost';
GRANT SELECT ON bookstore_db.shipping_method TO 'bookstore_sales'@'localhost';

-- Customer service role for managing customer data
CREATE USER IF NOT EXISTS 'bookstore_customer_service'@'localhost' IDENTIFIED BY 'cs_secure_password';
GRANT SELECT, INSERT, UPDATE ON bookstore_db.customer TO 'bookstore_customer_service'@'localhost';
GRANT SELECT, INSERT, UPDATE ON bookstore_db.address TO 'bookstore_customer_service'@'localhost';
GRANT SELECT, INSERT, UPDATE ON bookstore_db.customer_address TO 'bookstore_customer_service'@'localhost';
GRANT SELECT ON bookstore_db.cust_order TO 'bookstore_customer_service'@'localhost';
GRANT SELECT ON bookstore_db.order_line TO 'bookstore_customer_service'@'localhost';
GRANT SELECT ON bookstore_db.order_history TO 'bookstore_customer_service'@'localhost';

-- Read-only role for reporting
CREATE USER IF NOT EXISTS 'bookstore_reports'@'localhost' IDENTIFIED BY 'reports_secure_password';
GRANT SELECT ON bookstore_db.* TO 'bookstore_reports'@'localhost';

-- API application user with limited access
CREATE USER IF NOT EXISTS 'bookstore_api'@'%' IDENTIFIED BY 'api_secure_password';
GRANT SELECT ON bookstore_db.book TO 'bookstore_api'@'%';
GRANT SELECT ON bookstore_db.author TO 'bookstore_api'@'%';
GRANT SELECT ON bookstore_db.publisher TO 'bookstore_api'@'%';
GRANT SELECT ON bookstore_db.book_language TO 'bookstore_api'@'%';
GRANT SELECT, INSERT ON bookstore_db.customer TO 'bookstore_api'@'%';
GRANT SELECT, INSERT ON bookstore_db.cust_order TO 'bookstore_api'@'%';
GRANT SELECT, INSERT ON bookstore_db.order_line TO 'bookstore_api'@'%';

-- Apply the privileges
FLUSH PRIVILEGES;

-- Output confirmation message
SELECT 'Database users and roles created successfully' AS 'Status';