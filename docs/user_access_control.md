# BookstoreDB: User Access Control Documentation

## Overview

This document outlines the security model implemented for the BookstoreDB, including user roles, permissions, and access control mechanisms. The security design follows the principle of least privilege, providing each user role with only the permissions necessary to perform their specific functions.

## User Roles

The database implements the following user roles to segment access based on job function:

### 1. Administrator (`bookstore_admin`)

**Purpose:** Complete database administration and management.

**Access Level:** Full access to all database objects and data.

**Permissions:**
- Full privileges on all tables, views, and stored procedures
- Ability to create, alter, and drop database objects
- User management capabilities
- Backup and restore operations

**Typical Users:** Database administrators, System administrators

### 2. Manager (`bookstore_manager`)

**Purpose:** Oversee bookstore operations and inventory management.

**Access Level:** Read access to all data, write access to key operational tables.

**Permissions:**
- SELECT on all tables
- INSERT, UPDATE, DELETE on `book` table (inventory management)
- INSERT, UPDATE, DELETE on `order_status` table
- UPDATE on `cust_order` table (order management)
- INSERT on `order_history` table (status updates)

**Typical Users:** Store managers, Inventory managers

### 3. Sales Staff (`bookstore_sales`)

**Purpose:** Process customer orders and handle sales operations.

**Access Level:** Limited read access, focused on orders and product information.

**Permissions:**
- SELECT on product-related tables (`book`, `author`, `publisher`)
- SELECT on customer data (`customer`)
- SELECT, INSERT on order tables (`cust_order`, `order_line`)
- SELECT on supporting tables (`order_status`, `shipping_method`)

**Typical Users:** Sales associates, Cashiers

### 4. Customer Service (`bookstore_customer_service`)

**Purpose:** Manage customer relationships and address issues.

**Access Level:** Focus on customer data and order information.

**Permissions:**
- SELECT, INSERT, UPDATE on customer-related tables (`customer`, `address`, `customer_address`)
- SELECT on order-related tables (`cust_order`, `order_line`, `order_history`)

**Typical Users:** Customer service representatives

### 5. Reports (`bookstore_reports`)

**Purpose:** Generate business reports and analytics.

**Access Level:** Read-only access to all data.

**Permissions:**
- SELECT on all tables

**Typical Users:** Business analysts, Executives

### 6. API Application (`bookstore_api`)

**Purpose:** Interface with external applications and services.

**Access Level:** Limited access for programmatic integration.

**Permissions:**
- SELECT on product tables (`book`, `author`, `publisher`, `book_language`)
- SELECT, INSERT on `customer` table
- SELECT, INSERT on order tables (`cust_order`, `order_line`)

**Typical Users:** Web applications, Mobile applications, Integration services

## Implementation Details

### Connection Requirements

- All internal administrative access must be from `localhost` only
- API access is allowed from any host (`%`) for integration purposes
- All connections use encrypted passwords and SSL/TLS

### Password Policy

- Passwords must be changed every 90 days
- Minimum password length: 12 characters
- Must include: uppercase, lowercase, numbers, and special characters
- Failed login attempts are logged and monitored

### Audit and Monitoring

- Login attempts (both successful and failed) are logged
- Critical operations (e.g., changing order status, updating prices) are tracked
- Regular permission review is conducted quarterly

## Security Best Practices

1. **Application Layer Authentication:** User authentication should be handled at the application layer with appropriate encryption.

2. **Environment-Specific Credentials:** Different credentials should be used for development, testing, and production environments.

3. **Regular Privilege Review:** User permissions should be reviewed quarterly to ensure appropriate access levels.

4. **Secure Connection:** All database connections should use SSL/TLS encryption.

5. **Parameterized Queries:** All application access should use parameterized queries to prevent SQL injection.

## Setting Up User Roles

The user roles are created using the `03_create_users.sql` script. In production environments, replace the placeholder passwords with secure, randomly generated passwords.

## Revoking Access

When an employee leaves or changes roles:

1. Immediately revoke their database user account
2. Document the access removal in the security log
3. Review and adjust shared account credentials if necessary

## Example Usage Scenarios

### Inventory Update

```sql
-- Manager role updating book inventory
UPDATE book
SET stock_quantity = 25, in_stock = TRUE
WHERE book_id = 101;
```

### Processing New Order

```sql
-- Sales staff processing a new order
INSERT INTO cust_order (customer_id, order_date, shipping_address_id, billing_address_id, 
                       shipping_method_id, order_status_id, total_amount, payment_method)
VALUES (1001, NOW(), 5002, 5002, 3, 1, 29.98, 'Credit Card');
```

### Customer Information Update

```sql
-- Customer service updating customer information
UPDATE customer
SET phone = '+1-555-987-6543'
WHERE customer_id = 1001;
```
