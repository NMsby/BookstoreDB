# BookstoreDB: Database Schema Documentation

## Overview

This document provides a detailed description of the BookstoreDB database schema. The database is designed to manage operations for a bookstore, including inventory management, customer data, order processing, and shipping.

## Database Structure

The database consists of 15 tables organized in three main functional areas:

1. **Book Information** - Tables related to books, authors, languages, and publishers
2. **Customer Information** - Tables related to customers, addresses, and countries
3. **Order Information** - Tables related to orders, order lines, shipping, and status tracking

## Tables Detail

### Book Information Group

#### book

Stores information about books available in the bookstore.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| book_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each book |
| title | VARCHAR(255) | NOT NULL | Book title |
| isbn13 | VARCHAR(13) | UNIQUE | International Standard Book Number (13-digit) |
| publication_date | DATE | | Publication date of the book |
| price | DECIMAL(10,2) | | Retail price of the book |
| publisher_id | INT | FOREIGN KEY | Reference to publisher table |
| language_id | INT | FOREIGN KEY | Reference to book_language table |
| page_count | INT | | Number of pages in the book |
| description | TEXT | | Book description/summary |
| cover_image_url | VARCHAR(255) | | URL to book cover image |
| in_stock | BOOLEAN | DEFAULT TRUE | Indicates if book is in stock |
| stock_quantity | INT | DEFAULT 0 | Current inventory quantity |

**Indexes:**
- idx_book_title (title)
- idx_book_isbn (isbn13)
- idx_book_publisher (publisher_id)
- idx_book_language (language_id)
- idx_book_publication_date (publication_date)
- idx_book_price (price)
- idx_book_stock (in_stock, stock_quantity)

#### book_author

Junction table for the many-to-many relationship between books and authors.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| book_id | INT | PRIMARY KEY, FOREIGN KEY | Reference to book table |
| author_id | INT | PRIMARY KEY, FOREIGN KEY | Reference to author table |
| author_order | INT | NOT NULL, DEFAULT 1 | Order of authors for the book |

**Indexes:**
- idx_bookauthor_author (author_id)

#### author

Stores information about book authors.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| author_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each author |
| first_name | VARCHAR(50) | NOT NULL | Author's first name |
| last_name | VARCHAR(50) | NOT NULL | Author's last name |
| biography | TEXT | | Author's biographical information |
| birth_date | DATE | | Author's date of birth |
| nationality | VARCHAR(50) | | Author's nationality |

**Indexes:**
- idx_author_name (last_name, first_name)
- idx_author_nationality (nationality)

#### book_language

Stores languages available for books.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| language_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each language |
| language_name | VARCHAR(50) | NOT NULL, UNIQUE | Name of language |
| language_code | CHAR(2) | NOT NULL, UNIQUE | ISO 639-1 language code |

**Indexes:**
- idx_language_code (language_code)

#### publisher

Stores information about book publishers.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| publisher_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each publisher |
| publisher_name | VARCHAR(100) | NOT NULL | Name of the publishing company |
| contact_name | VARCHAR(100) | | Name of contact person at publisher |
| contact_email | VARCHAR(100) | | Email of contact person |
| phone | VARCHAR(20) | | Publisher's phone number |
| address | VARCHAR(255) | | Publisher's physical address |
| website | VARCHAR(100) | | Publisher's website URL |

**Indexes:**
- idx_publisher_name (publisher_name)

### Customer Information Group

#### customer

Stores information about bookstore customers.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| customer_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each customer |
| first_name | VARCHAR(50) | NOT NULL | Customer's first name |
| last_name | VARCHAR(50) | NOT NULL | Customer's last name |
| email | VARCHAR(100) | NOT NULL, UNIQUE | Customer's email address |
| phone | VARCHAR(20) | | Customer's phone number |
| date_registered | DATE | DEFAULT CURRENT_DATE | Date customer registered |
| password_hash | VARCHAR(255) | | Hashed password for account |
| birth_date | DATE | | Customer's date of birth |

**Indexes:**
- idx_customer_name (last_name, first_name)
- idx_customer_email (email)
- idx_customer_date_registered (date_registered)

#### customer_address

Junction table for the many-to-many relationship between customers and addresses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| customer_id | INT | PRIMARY KEY, FOREIGN KEY | Reference to customer table |
| address_id | INT | PRIMARY KEY, FOREIGN KEY | Reference to address table |
| address_status_id | INT | FOREIGN KEY, NOT NULL | Reference to address_status table |
| is_default | BOOLEAN | DEFAULT FALSE | Indicates if this is the default address |

**Indexes:**
- idx_custaddress_address (address_id)
- idx_custaddress_status (address_status_id)
- idx_custaddress_default (is_default)

#### address_status

Stores possible statuses for customer addresses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| address_status_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each status |
| status_name | VARCHAR(20) | NOT NULL, UNIQUE | Name of status (e.g., current, old, billing, shipping) |

#### address

Stores addresses for customers and orders.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| address_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each address |
| street_address | VARCHAR(255) | NOT NULL | Street address |
| city | VARCHAR(100) | NOT NULL | City |
| state_province | VARCHAR(100) | | State or province |
| postal_code | VARCHAR(20) | | Postal/zip code |
| country_id | INT | FOREIGN KEY, NOT NULL | Reference to country table |

**Indexes:**
- idx_address_country (country_id)
- idx_address_city (city)
- idx_address_postal_code (postal_code)

#### country

Stores countries for addresses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| country_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each country |
| country_name | VARCHAR(100) | NOT NULL, UNIQUE | Name of country |
| country_code | CHAR(2) | NOT NULL, UNIQUE | ISO 3166-1 alpha-2 country code |

**Indexes:**
- idx_country_code (country_code)

### Order Information Group

#### cust_order

Stores customer orders.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| order_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each order |
| customer_id | INT | FOREIGN KEY, NOT NULL | Reference to customer table |
| order_date | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date and time order was placed |
| shipping_address_id | INT | FOREIGN KEY | Reference to address table for shipping |
| billing_address_id | INT | FOREIGN KEY | Reference to address table for billing |
| shipping_method_id | INT | FOREIGN KEY | Reference to shipping_method table |
| order_status_id | INT | FOREIGN KEY, NOT NULL | Reference to order_status table |
| total_amount | DECIMAL(10,2) | | Total order amount |
| payment_method | VARCHAR(50) | | Method of payment |
| payment_transaction_id | VARCHAR(100) | | Transaction identifier from payment system |
| special_instructions | TEXT | | Customer's special instructions |

**Indexes:**
- idx_order_customer (customer_id)
- idx_order_date (order_date)
- idx_order_status (order_status_id)
- idx_order_shipping_address (shipping_address_id)
- idx_order_billing_address (billing_address_id)
- idx_order_shipping_method (shipping_method_id)

#### order_line

Stores individual line items within customer orders.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| order_line_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each order line |
| order_id | INT | FOREIGN KEY, NOT NULL | Reference to cust_order table |
| book_id | INT | FOREIGN KEY, NOT NULL | Reference to book table |
| quantity | INT | NOT NULL, CHECK (quantity > 0) | Quantity of books ordered |
| price_at_time_of_order | DECIMAL(10,2) | NOT NULL, CHECK (price_at_time_of_order >= 0) | Price at time of order |
| discount_amount | DECIMAL(10,2) | DEFAULT 0, CHECK (discount_amount >= 0) | Discount amount applied |

**Indexes:**
- idx_orderline_order (order_id)
- idx_orderline_book (book_id)

#### shipping_method

Stores available shipping methods for orders.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| shipping_method_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each shipping method |
| method_name | VARCHAR(50) | NOT NULL, UNIQUE | Name of shipping method |
| cost | DECIMAL(10,2) | NOT NULL | Cost of shipping method |
| estimated_delivery_days | INT | | Estimated delivery time in days |
| is_active | BOOLEAN | DEFAULT TRUE | Indicates if method is currently available |

**Indexes:**
- idx_shipping_active (is_active)

#### order_history

Tracks the history of status changes for orders.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| history_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each history entry |
| order_id | INT | FOREIGN KEY, NOT NULL | Reference to cust_order table |
| order_status_id | INT | FOREIGN KEY, NOT NULL | Reference to order_status table |
| status_change_date | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Date and time of status change |
| notes | TEXT | | Additional notes about the status change |
| updated_by | VARCHAR(50) | | User who made the update |

**Indexes:**
- idx_history_order (order_id)
- idx_history_status (order_status_id)
- idx_history_date (status_change_date)

#### order_status

Stores possible statuses for customer orders.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| order_status_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each status |
| status_name | VARCHAR(50) | NOT NULL, UNIQUE | Name of status (e.g., pending, shipped, delivered) |
| description | VARCHAR(255) | | Description of the status |

## Key Relationships

1. A book can have multiple authors (many-to-many via book_author)
2. A book belongs to one publisher (many-to-one)
3. A book is in one language (many-to-one)
4. A customer can have multiple addresses (many-to-many via customer_address)
5. An address belongs to one country (many-to-one)
6. A customer can place multiple orders (one-to-many)
7. An order contains multiple books (many-to-many via order_line)
8. An order has one shipping method (many-to-one)
9. An order has one status (many-to-one)
10. An order has a history of status changes (one-to-many)

## Database Diagram

Please refer to the ER_Diagram.png file in the docs folder for a visual representation of the database schema.