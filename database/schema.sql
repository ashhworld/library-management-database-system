-- Create Database
CREATE DATABASE LibraryManagement;

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
    Total_Copies INT NOT NULL,
    Available_Copies INT NOT NULL
);

-- User TABLE
-- ---------------------------------------------

CREATE TABLE Users (
    User_ID INT AUTO_INCREMENT PRIMARY KEY,
    Full_Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15),
    Membership_Date DATE
);

-- Transactions TABLE
-- ---------------------------------------------------

CREATE TABLE Transactions (
    Transaction_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT,
    Book_ID INT,
    Issue_Date DATE NOT NULL,
    Return_Date DATE,
    Status ENUM('Issued','Returned') DEFAULT 'Issued',

    FOREIGN KEY (User_ID)
        REFERENCES Users(User_ID),

    FOREIGN KEY (Book_ID)
        REFERENCES Books(Book_ID)
);
