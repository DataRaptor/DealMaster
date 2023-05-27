# DealMaster
DealMaster is a database schema and SQL script designed for a Coupon Management System to manage coupons, merchants, users, cities, and various related entities. It provides a foundation for developing a coupon management system with features such as coupon creation, user management, likes, product management, and more.

## Features
- User management: Create and manage user accounts.
- City management: Add new cities and associate them with countries.
- Merchant management: Create and manage merchant profiles with associated cities.
- Role-based access control: Assign roles to users for managing merchants.
- Like tracking: Track user likes for merchants.
- Coupon management: Create and manage coupons associated with merchants.
- Product management: Create and manage products associated with merchants.
- Category management: Categorize products and coupons into hierarchical categories.
- Tagging system: Associate tags with products.
- Integration with other entities: Connect cities, countries, merchants, users, coupons, and products for data integrity.

## Database Schma
![](docs/schema.jpg?raw=true)
Diagram created using dbdiagram.io

## Usage
- Set up a database and execute the provided SQL script to create the required tables, triggers, functions, and procedures.
- Use SQL queries and procedures to interact with the database schema and perform operations such as adding cities, creating merchants, managing coupons, and more.
- Customize and extend the schema to meet the specific requirements of your coupon management system.

## Requirements
- Oracle Database (or compatible database system)
- SQL client or interface to interact with the database (e.g., Oracle SQL Developer, SQL*Plus)

## License
- Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
