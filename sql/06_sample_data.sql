-- BookstoreDB: Sample Data Population Script
-- Created: April 2025
-- Author: Lina Murithi

-- Use the bookstore database
USE bookstore_db;

-- Sample data for book_language
INSERT INTO book_language (language_name, language_code) VALUES
('English', 'EN'),
('Spanish', 'ES'),
('French', 'FR'),
('German', 'DE'),
('Chinese', 'ZH'),
('Japanese', 'JA'),
('Russian', 'RU'),
('Arabic', 'AR');

-- Sample data for publisher
INSERT INTO publisher (publisher_name, contact_name, contact_email, phone, address, website) VALUES
('Penguin Random House', 'John Smith', 'jsmith@prh.com', '+1-212-555-1000', '1745 Broadway, New York, NY 10019', 'www.penguinrandomhouse.com'),
('HarperCollins', 'Emma Johnson', 'ejohnson@harpercollins.com', '+1-212-555-2000', '195 Broadway, New York, NY 10007', 'www.harpercollins.com'),
('Simon & Schuster', 'David Brown', 'dbrown@simonschuster.com', '+1-212-555-3000', '1230 Avenue of the Americas, New York, NY 10020', 'www.simonandschuster.com'),
('Macmillan Publishers', 'Sarah Davis', 'sdavis@macmillan.com', '+1-212-555-4000', '120 Broadway, New York, NY 10271', 'www.macmillan.com'),
('Oxford University Press', 'Michael Wilson', 'mwilson@oup.com', '+44-1865-556000', 'Great Clarendon Street, Oxford, OX2 6DP, UK', 'www.oup.com');

-- Sample data for book
INSERT INTO book (title, isbn13, publication_date, price, publisher_id, language_id, page_count, description, cover_image_url, in_stock, stock_quantity) VALUES
('The Great Gatsby', '9780743273565', '2004-09-30', 15.99, 3, 1, 180, 'A classic novel about the American Dream set in the Jazz Age', 'https://covers.openlibrary.org/b/id/8410745-L.jpg', TRUE, 47),
('To Kill a Mockingbird', '9780061120084', '2006-05-23', 14.99, 2, 1, 336, 'A novel about racial injustice and moral growth in the American South', 'https://covers.openlibrary.org/b/id/8314135-L.jpg', TRUE, 53),
('One Hundred Years of Solitude', '9780060883287', '2006-02-21', 16.99, 2, 1, 417, 'A landmark novel in the magical realism style', 'https://covers.openlibrary.org/b/id/8701264-L.jpg', TRUE, 28),
('Pride and Prejudice', '9780141439518', '2002-12-31', 9.99, 1, 1, 480, 'A romantic novel of manners by Jane Austen', 'https://covers.openlibrary.org/b/id/8717403-L.jpg', TRUE, 62),
('The Hobbit', '9780547928227', '2012-09-18', 14.95, 4, 1, 300, 'A fantasy novel and children\'s book by J.R.R. Tolkien', 'https://covers.openlibrary.org/b/id/8406786-L.jpg', TRUE, 40),
('The Alchemist', '9780062315007', '2014-04-15', 16.99, 2, 1, 208, 'A philosophical novel by Paulo Coelho', 'https://covers.openlibrary.org/b/id/8703459-L.jpg', TRUE, 35),
('The Little Prince', '9780156012195', '2000-06-01', 10.99, 5, 3, 96, 'A poetic tale about a young prince who visits various planets', 'https://covers.openlibrary.org/b/id/8291538-L.jpg', TRUE, 29),
('The Art of War', '9780143037521', '2006-05-30', 13.00, 1, 5, 273, 'An ancient Chinese military treatise', 'https://covers.openlibrary.org/b/id/8708701-L.jpg', TRUE, 25);

-- Sample data for author
INSERT INTO author (first_name, last_name, biography, birth_date, nationality) VALUES
('F. Scott', 'Fitzgerald', 'American novelist and short story writer', '1896-09-24', 'American'),
('Harper', 'Lee', 'American novelist', '1926-04-28', 'American'),
('Gabriel', 'García Márquez', 'Colombian novelist and Nobel Prize winner', '1927-03-06', 'Colombian'),
('Jane', 'Austen', 'English novelist known for romantic fiction', '1775-12-16', 'British'),
('J.R.R.', 'Tolkien', 'English writer, poet, and academic', '1892-01-03', 'British'),
('Paulo', 'Coelho', 'Brazilian lyricist and novelist', '1947-08-24', 'Brazilian'),
('Antoine de', 'Saint-Exupéry', 'French writer, poet, and aviator', '1900-06-29', 'French'),
('Sun', 'Tzu', 'Ancient Chinese general and military strategist', NULL, 'Chinese');

-- Sample data for book_author
INSERT INTO book_author (book_id, author_id, author_order) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1),
(4, 4, 1),
(5, 5, 1),
(6, 6, 1),
(7, 7, 1),
(8, 8, 1);

-- Sample data for country
INSERT INTO country (country_name, country_code) VALUES
('United States', 'US'),
('United Kingdom', 'GB'),
('Canada', 'CA'),
('Australia', 'AU'),
('Germany', 'DE'),
('France', 'FR'),
('Japan', 'JP'),
('Brazil', 'BR'),
('India', 'IN'),
('Kenya', 'KE');

-- Sample data for address
INSERT INTO address (street_address, city, state_province, postal_code, country_id) VALUES
('123 Main St', 'New York', 'NY', '10001', 1),
('456 Park Ave', 'Los Angeles', 'CA', '90001', 1),
('789 Queen St', 'Toronto', 'ON', 'M5V 2A3', 3),
('10 Downing St', 'London', 'England', 'SW1A 2AA', 2),
('50 Rue de Rivoli', 'Paris', 'Île-de-France', '75001', 6),
('222 Exhibition St', 'Melbourne', 'Victoria', '3000', 4),
('1 Kenyatta Ave', 'Nairobi', NULL, '00100', 10),
('7-1 Chome', 'Tokyo', 'Chiyoda', '100-0001', 7);

-- Sample data for address_status
INSERT INTO address_status (status_name) VALUES
('Current'),
('Previous'),
('Billing'),
('Shipping'),
('Business'),
('Vacation');

-- Sample data for customer
INSERT INTO customer (first_name, last_name, email, phone, date_registered, password_hash, birth_date) VALUES
('John', 'Doe', 'john.doe@example.com', '+1-555-123-4567', '2023-01-15', 'hashed_password_1', '1985-06-12'),
('Jane', 'Smith', 'jane.smith@example.com', '+1-555-987-6543', '2023-02-20', 'hashed_password_2', '1990-03-25'),
('Alice', 'Johnson', 'alice.j@example.com', '+1-555-222-3333', '2023-03-10', 'hashed_password_3', '1982-11-30'),
('Robert', 'Brown', 'robert.b@example.com', '+44-7700-900123', '2023-04-05', 'hashed_password_4', '1978-09-15'),
('Emma', 'Wilson', 'emma.w@example.com', '+61-4-1234-5678', '2023-05-12', 'hashed_password_5', '1995-07-22'),
('Carlos', 'Garcia', 'carlos.g@example.com', '+1-555-444-5555', '2023-06-18', 'hashed_password_6', '1988-04-17'),
('Sarah', 'Taylor', 'sarah.t@example.com', '+1-555-777-8888', '2023-07-25', 'hashed_password_7', '1992-12-05'),
('Michael', 'Anderson', 'michael.a@example.com', '+1-555-333-2222', '2023-08-30', 'hashed_password_8', '1975-05-28');

-- Sample data for customer_address
INSERT INTO customer_address (customer_id, address_id, address_status_id, is_default) VALUES
(1, 1, 1, TRUE),
(1, 5, 3, FALSE),
(2, 2, 1, TRUE),
(3, 3, 1, TRUE),
(4, 4, 1, TRUE),
(5, 6, 1, TRUE),
(6, 2, 1, TRUE),
(7, 7, 1, TRUE),
(8, 8, 1, TRUE),
(8, 1, 3, FALSE);

-- Sample data for shipping_method
INSERT INTO shipping_method (method_name, cost, estimated_delivery_days, is_active) VALUES
('Standard Shipping', 4.99, 5, TRUE),
('Express Shipping', 9.99, 2, TRUE),
('Next Day Delivery', 19.99, 1, TRUE),
('International Standard', 14.99, 14, TRUE),
('International Express', 24.99, 7, TRUE),
('Local Pickup', 0.00, 0, TRUE),
('Economy Shipping', 2.99, 10, TRUE),
('Saturday Delivery', 29.99, 1, FALSE);

-- Sample data for order_status
INSERT INTO order_status (status_name, description) VALUES
('Pending', 'Order received, awaiting payment confirmation'),
('Processing', 'Payment confirmed, preparing for shipment'),
('Shipped', 'Order has been shipped'),
('Delivered', 'Order has been delivered'),
('Cancelled', 'Order has been cancelled'),
('Returned', 'Order has been returned by customer'),
('On Hold', 'Order processing paused'),
('Refunded', 'Order payment has been refunded');

-- Sample data for cust_order
INSERT INTO cust_order (customer_id, order_date, shipping_address_id, billing_address_id, shipping_method_id, order_status_id, total_amount, payment_method, payment_transaction_id, special_instructions) VALUES
(1, '2023-10-15 10:30:00', 1, 1, 1, 3, 35.97, 'Credit Card', 'TXN12345678', 'Please leave at front door'),
(2, '2023-10-20 14:45:00', 2, 2, 2, 3, 46.97, 'PayPal', 'PP87654321', NULL),
(3, '2023-11-05 09:15:00', 3, 3, 1, 4, 14.99, 'Credit Card', 'TXN23456789', NULL),
(4, '2023-11-10 16:20:00', 4, 4, 5, 2, 39.98, 'Bank Transfer', 'BT34567890', 'Gift wrap please'),
(5, '2023-11-15 11:05:00', 6, 6, 1, 1, 15.99, 'Credit Card', 'TXN45678901', NULL),
(1, '2023-12-01 13:30:00', 1, 5, 3, 4, 59.97, 'Credit Card', 'TXN56789012', 'This is a gift'),
(6, '2023-12-10 10:45:00', 2, 2, 1, 5, 29.98, 'PayPal', 'PP67890123', NULL),
(7, '2023-12-15 09:00:00', 7, 7, 4, 2, 44.97, 'Credit Card', 'TXN78901234', 'Call before delivery');

-- Sample data for order_line
INSERT INTO order_line (order_id, book_id, quantity, price_at_time_of_order, discount_amount) VALUES
(1, 1, 1, 15.99, 0.00),
(1, 2, 1, 14.99, 0.00),
(1, 3, 1, 16.99, 12.00),
(2, 4, 1, 9.99, 0.00),
(2, 5, 1, 14.95, 0.00),
(2, 6, 1, 16.99, 0.00),
(2, 7, 1, 10.99, 5.95),
(3, 2, 1, 14.99, 0.00),
(4, 1, 1, 15.99, 0.00),
(4, 4, 1, 9.99, 0.00),
(4, 8, 1, 13.00, 0.00),
(5, 1, 1, 15.99, 0.00),
(6, 5, 1, 14.95, 0.00),
(6, 6, 1, 16.99, 0.00),
(6, 8, 1, 13.00, 0.00),
(7, 2, 2, 14.99, 0.00),
(8, 3, 1, 16.99, 0.00),
(8, 7, 1, 10.99, 0.00),
(8, 8, 1, 13.00, 0.00);

-- Sample data for order_history
INSERT INTO order_history (order_id, order_status_id, status_change_date, notes, updated_by) VALUES
(1, 1, '2023-10-15 10:30:00', 'Order placed', 'system'),
(1, 2, '2023-10-15 10:45:00', 'Payment confirmed', 'system'),
(1, 3, '2023-10-16 09:30:00', 'Order shipped via Standard Shipping', 'staff_id_123'),
(2, 1, '2023-10-20 14:45:00', 'Order placed', 'system'),
(2, 2, '2023-10-20 15:00:00', 'Payment confirmed', 'system'),
(2, 3, '2023-10-21 11:15:00', 'Order shipped via Express Shipping', 'staff_id_456'),
(3, 1, '2023-11-05 09:15:00', 'Order placed', 'system'),
(3, 2, '2023-11-05 09:30:00', 'Payment confirmed', 'system'),
(3, 3, '2023-11-06 10:00:00', 'Order shipped via Standard Shipping', 'staff_id_123'),
(3, 4, '2023-11-10 16:30:00', 'Order delivered', 'system'),
(4, 1, '2023-11-10 16:20:00', 'Order placed', 'system'),
(4, 2, '2023-11-11 09:45:00', 'Payment confirmed', 'system'),
(5, 1, '2023-11-15 11:05:00', 'Order placed', 'system'),
(6, 1, '2023-12-01 13:30:00', 'Order placed', 'system'),
(6, 2, '2023-12-01 13:45:00', 'Payment confirmed', 'system'),
(6, 3, '2023-12-01 15:30:00', 'Order shipped via Next Day Delivery', 'staff_id_789'),
(6, 4, '2023-12-02 14:15:00', 'Order delivered', 'system'),
(7, 1, '2023-12-10 10:45:00', 'Order placed', 'system'),
(7, 2, '2023-12-10 11:00:00', 'Payment confirmed', 'system'),
(7, 5, '2023-12-11 09:30:00', 'Customer requested cancellation', 'staff_id_123'),
(8, 1, '2023-12-15 09:00:00', 'Order placed', 'system'),
(8, 2, '2023-12-15 09:15:00', 'Payment confirmed', 'system');