-- --------------------------------------------------------------------------------------

-- Queries and Transactions:
-- ---------------------------------------------

START TRANSACTION;

INSERT INTO Transactions (User_ID, Book_ID, Issue_Date) VALUES (1, 1, CURDATE());

UPDATE Books
SET Available_Copies =
    Available_Copies - 1
WHERE Book_ID = 1;

COMMIT;

-- ----------------------------------------------------------------

START TRANSACTION;

UPDATE Transactions
SET Return_Date = CURDATE(),
    Status = 'Returned'
WHERE Transaction_ID = 1;

UPDATE Books
SET Available_Copies =
    Available_Copies + 1
WHERE Book_ID = 1;

COMMIT;
