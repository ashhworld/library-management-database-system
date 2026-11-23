# library-management-database-system
A MySQL-based relational database project designed to manage library books, users, and book transactions.

The system enables:
- Book management
- User registration
- Book issuing
- Book returns
- Transaction tracking
- Overdue book monitoring

This project demonstrates the practical implementation of:
- DBMS concepts
- Relational databases
- Primary & Foreign Keys
- SQL Queries
- Joins
- Transactions and ACID properties

## Technologies

- MySQL 8.0
- SQL
- MySQL Workbench

## ER Diagram

![ER Diagram](docs/ER_Diagram.png)

## Tables

### Books
- Book_ID (PK)
- Title
- Author
- Publisher
- ISBN
- Category
- Total_Copies
- Available_Copies

### Users
- User_ID (PK)
- Full_Name
- Email
- Phone
- Membership_Date

### Transactions
- Transaction_ID (PK)
- User_ID (FK)
- Book_ID (FK)
- Issue_Date
- Return_Date
- Status

## Features

✅ Add books

✅ Register users

✅ Issue books

✅ Return books

✅ Track book availability

✅ View transaction history

✅ Monitor overdue books

## SQL Concepts Implemented

- CREATE DATABASE
- CREATE TABLE
- INSERT
- UPDATE
- DELETE
- SELECT
- WHERE
- ORDER BY
- INNER JOIN
- FOREIGN KEY
- PRIMARY KEY
- TRANSACTIONS
- ACID PROPERTIES

## Sample Queries

SELECT * FROM Books;

SELECT * FROM Users;

SELECT *
FROM Transactions;

## Setup

1. Install MySQL.
2. Open MySQL Workbench.
3. Execute schema.sql.
4. Execute sample_data.sql.
5. Run queries.sql.

