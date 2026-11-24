-- --------------------------------------------------------------------------------------

-- Queries and Transactions:
-- ---------------------------------------------

DELIMITER $$

CREATE PROCEDURE Issue_Book(
    IN p_User_ID INT,
    IN p_Book_ID INT,
    IN p_Issue_Date DATE,
    IN p_Loan_Days INT
)
proc_start:
BEGIN
    DECLARE v_available INT;

    IF p_Issue_Date IS NULL THEN
        SET p_Issue_Date = CURDATE();
    END IF;

    IF p_Loan_Days IS NULL OR p_Loan_Days <= 0 THEN
        SET p_Loan_Days = 15;
    END IF;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM Users WHERE User_ID = p_User_ID) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid user ID';
    END IF;

    SELECT Available_Copies
    INTO v_available
    FROM Books
    WHERE Book_ID = p_Book_ID
    FOR UPDATE;

    IF v_available IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid book ID';
    END IF;

    IF v_available <= 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No copies are currently available';
    END IF;

    INSERT INTO Transactions
        (User_ID, Book_ID, Issue_Date, Due_Date, Status)
    VALUES
        (p_User_ID, p_Book_ID, p_Issue_Date,
         DATE_ADD(p_Issue_Date, INTERVAL p_Loan_Days DAY), 'Issued');

    UPDATE Books
    SET Available_Copies = Available_Copies - 1
    WHERE Book_ID = p_Book_ID
      AND Available_Copies > 0;

    IF ROW_COUNT() <> 1 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book availability changed; issue cancelled';
    END IF;

    COMMIT;
END$$

CREATE PROCEDURE Return_Book(
    IN p_Transaction_ID INT,
    IN p_Return_Date DATE
)
BEGIN
    DECLARE v_book_id INT;

    IF p_Return_Date IS NULL THEN
        SET p_Return_Date = CURDATE();
    END IF;

    START TRANSACTION;

    SELECT Book_ID
    INTO v_book_id
    FROM Transactions
    WHERE Transaction_ID = p_Transaction_ID
      AND Status IN ('Issued', 'Overdue')
      AND Return_Date IS NULL
    FOR UPDATE;

    IF v_book_id IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transaction is invalid or already returned';
    END IF;

    UPDATE Transactions
    SET Return_Date = p_Return_Date,
        Status = 'Returned'
    WHERE Transaction_ID = p_Transaction_ID
      AND Status IN ('Issued', 'Overdue')
      AND Return_Date IS NULL
      AND p_Return_Date >= Issue_Date;

    IF ROW_COUNT() <> 1 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid return date or transaction state';
    END IF;

    UPDATE Books
    SET Available_Copies = Available_Copies + 1
    WHERE Book_ID = v_book_id
      AND Available_Copies < Total_Copies;

    IF ROW_COUNT() <> 1 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Inventory inconsistency: available copies exceed total copies';
    END IF;

    COMMIT;
END$$

CREATE PROCEDURE Refresh_Overdue_Status()
BEGIN
    UPDATE Transactions
    SET Status = 'Overdue'
    WHERE Status = 'Issued'
      AND Return_Date IS NULL
      AND Due_Date < CURDATE();

    UPDATE Transactions
    SET Status = 'Issued'
    WHERE Status = 'Overdue'
      AND Return_Date IS NULL
      AND Due_Date >= CURDATE();
END$$

DELIMITER ;

-- Examples:
-- CALL Issue_Book(1, 1, CURDATE(), 15);
-- CALL Return_Book(1, CURDATE());
-- CALL Refresh_Overdue_Status();
