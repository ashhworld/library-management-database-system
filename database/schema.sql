-- Create Database
CREATE DATABASE IF NOT EXISTS LibraryManagement;

USE LibraryManagement;

-- Books Table
-- ------------------------

CREATE TABLE Books (
    Book_ID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    Author VARCHAR(100) NOT NULL,
    Publisher VARCHAR(100),
    ISBN VARCHAR(20) UNIQUE,

    CONSTRAINT chk_isbn_format CHECK (
        ISBN IS NULL OR
        (LENGTH(ISBN) = 13 AND ISBN REGEXP '^[0-9]{13}$') OR
        (LENGTH(ISBN) = 10 AND ISBN REGEXP '^[0-9]{9}[0-9Xx]$')
    ),

    Category VARCHAR(50),
    Total_Copies INT NOT NULL CHECK (Total_Copies >= 0),
    Available_Copies INT NOT NULL CHECK (
        Available_Copies >= 0 AND Available_Copies <= Total_Copies
    ),
    Created_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_books_category (Category),
    INDEX idx_books_isbn (ISBN)
);

-- Users Table
-- ---------------------------------------------

CREATE TABLE Users (
    User_ID INT AUTO_INCREMENT PRIMARY KEY,
    Full_Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,

    CONSTRAINT chk_email_format CHECK (
        Email IS NULL OR Email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    ),

    Phone VARCHAR(15),
    Membership_Date DATE,
    Created_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_users_email (Email)
);

-- Transactions Table
-- ---------------------------------------------------

CREATE TABLE Transactions (
    Transaction_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT NOT NULL,
    Book_ID INT NOT NULL,
    Issue_Date DATE NOT NULL,
    Due_Date DATE NOT NULL,
    Return_Date DATE,
    Status ENUM('Issued', 'Returned', 'Overdue') NOT NULL DEFAULT 'Issued',

    CONSTRAINT chk_due_date
        CHECK (Due_Date >= Issue_Date),
    CONSTRAINT chk_return_date
        CHECK (Return_Date IS NULL OR Return_Date >= Issue_Date),

    CONSTRAINT fk_transaction_user
        FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    CONSTRAINT fk_transaction_book
        FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID),

    Created_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_transactions_user (User_ID),
    INDEX idx_transactions_book (Book_ID),
    INDEX idx_transactions_status_due (Status, Due_Date),
    INDEX idx_transactions_active (User_ID, Book_ID, Status)
);

-- Fine Management Table
-- ---------------------------------------------------

CREATE TABLE Fines (
    Fine_ID INT AUTO_INCREMENT PRIMARY KEY,
    Transaction_ID INT NOT NULL UNIQUE,
    Fine_Amount DECIMAL(10,2) NOT NULL DEFAULT 0.00
        CHECK (Fine_Amount >= 0),
    Daily_Rate DECIMAL(10,2) NOT NULL DEFAULT 1.00
        CHECK (Daily_Rate >= 0),
    Payment_Status ENUM('Unpaid', 'Paid') NOT NULL DEFAULT 'Unpaid',
    Paid_At TIMESTAMP NULL,
    Created_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_fine_transaction
        FOREIGN KEY (Transaction_ID) REFERENCES Transactions(Transaction_ID),

    INDEX idx_fines_status (Payment_Status)
);
