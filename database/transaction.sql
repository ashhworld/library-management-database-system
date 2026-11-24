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

CREATE TRIGGER trg_transactions_prevent_duplicate_issue
BEFORE INSERT ON Transactions
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Transactions
        WHERE User_ID = NEW.User_ID
          AND Book_ID = NEW.Book_ID
          AND Status IN ('Issued', 'Overdue')
          AND Return_Date IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Duplicate issue: this user has already borrowed this book';
    END IF;
END$$

CREATE TRIGGER trg_transactions_return_fine
AFTER UPDATE ON Transactions
FOR EACH ROW
BEGIN
    DECLARE v_days_late INT DEFAULT 0;
    DECLARE v_effective_return DATE;

    IF NEW.Status = 'Returned' AND OLD.Status <> 'Returned' THEN
        SET v_effective_return = NEW.Return_Date;

        IF v_effective_return > NEW.Due_Date THEN
            SET v_days_late = DATEDIFF(v_effective_return, NEW.Due_Date);

            INSERT INTO Fines
                (Transaction_ID, Fine_Amount, Daily_Rate, Payment_Status)
            VALUES
                (NEW.Transaction_ID,
                 v_days_late * 1.00,
                 1.00,
                 'Unpaid')
            ON DUPLICATE KEY UPDATE
                Fine_Amount = VALUES(Fine_Amount),
                Updated_At = CURRENT_TIMESTAMP;
        END IF;
    END IF;
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

    INSERT INTO Fines
        (Transaction_ID, Fine_Amount, Daily_Rate, Payment_Status)
    SELECT
        Transaction_ID,
        DATEDIFF(CURDATE(), Due_Date) * 1.00,
        1.00,
        'Unpaid'
    FROM Transactions
    WHERE Status = 'Overdue'
      AND Return_Date IS NULL
      AND Due_Date < CURDATE()
    ON DUPLICATE KEY UPDATE
        Fine_Amount = VALUES(Fine_Amount),
        Updated_At = CURRENT_TIMESTAMP;
END$$

CREATE PROCEDURE Mark_Fine_Paid(IN p_Transaction_ID INT)
BEGIN
    UPDATE Fines
    SET Payment_Status = 'Paid',
        Paid_At = CURRENT_TIMESTAMP
    WHERE Transaction_ID = p_Transaction_ID;

    IF ROW_COUNT() <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No fine exists for this transaction';
    END IF;
END$$

DELIMITER ;

SET GLOBAL event_scheduler = ON;

CREATE EVENT IF NOT EXISTS ev_refresh_library_status
ON SCHEDULE EVERY 1 DAY
DO CALL Refresh_Overdue_Status();

-- Run once when procedures are loaded.
CALL Refresh_Overdue_Status();

-- Examples:
-- CALL Issue_Book(1, 1, CURDATE(), 15);
-- CALL Return_Book(1, CURDATE());
-- CALL Refresh_Overdue_Status();
-- CALL Mark_Fine_Paid(1);
