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


-- Create cust_order table
CREATE TABLE cust_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    shipping_address_id INT,
    billing_address_id INT,
    shipping_method_id INT,
    order_status_id INT NOT NULL,
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    payment_transaction_id VARCHAR(100),
    special_instructions TEXT,
    
    -- Foreign key constraints for tables already created
    CONSTRAINT fk_order_status FOREIGN KEY (order_status_id) 
        REFERENCES order_status(order_status_id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    
    -- Note: These foreign keys reference tables that will be created by Ivy
    -- They will need to be added after those tables are created
    /*
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) 
        REFERENCES customer(customer_id),
    CONSTRAINT fk_order_shipping_address FOREIGN KEY (shipping_address_id) 
        REFERENCES address(address_id),
    CONSTRAINT fk_order_billing_address FOREIGN KEY (billing_address_id) 
        REFERENCES address(address_id),
    CONSTRAINT fk_order_shipping_method FOREIGN KEY (shipping_method_id) 
        REFERENCES shipping_method(shipping_method_id)
    */
    
    -- Adding a check constraint for total_amount
    CONSTRAINT check_total_amount CHECK (total_amount IS NULL OR total_amount >= 0)
) COMMENT 'Stores customer orders';

-- Add indexes for common query patterns
CREATE INDEX idx_order_customer ON cust_order(customer_id);
CREATE INDEX idx_order_date ON cust_order(order_date);
CREATE INDEX idx_order_status ON cust_order(order_status_id);
CREATE INDEX idx_order_shipping_address ON cust_order(shipping_address_id);
CREATE INDEX idx_order_billing_address ON cust_order(billing_address_id);
CREATE INDEX idx_order_shipping_method ON cust_order(shipping_method_id);

-- Output confirmation message
SELECT 'cust_order table created successfully' AS 'Status';


-- Create order_line table
CREATE TABLE order_line (
    order_line_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL,
    price_at_time_of_order DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    
    -- Foreign key constraints
    CONSTRAINT fk_orderline_order FOREIGN KEY (order_id) 
        REFERENCES cust_order(order_id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_orderline_book FOREIGN KEY (book_id) 
        REFERENCES book(book_id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    
    -- Add check constraints
    CONSTRAINT check_quantity CHECK (quantity > 0),
    CONSTRAINT check_price CHECK (price_at_time_of_order >= 0),
    CONSTRAINT check_discount CHECK (discount_amount >= 0)
) COMMENT 'Stores individual line items within customer orders';

-- Add indexes for common query patterns
CREATE INDEX idx_orderline_order ON order_line(order_id);
CREATE INDEX idx_orderline_book ON order_line(book_id);

-- Output confirmation message
SELECT 'order_line table created successfully' AS 'Status';