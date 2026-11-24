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
    Category VARCHAR(50),
    Total_Copies INT NOT NULL CHECK (Total_Copies >= 0),
    Available_Copies INT NOT NULL CHECK (
        Available_Copies >= 0
        AND Available_Copies <= Total_Copies
    )
);

-- Users Table
-- ---------------------------------------------

CREATE TABLE Users (
    User_ID INT AUTO_INCREMENT PRIMARY KEY,
    Full_Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15),
    Membership_Date DATE
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
        FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
);
