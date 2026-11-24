SELECT * FROM Books;


SELECT Book_ID,
       Title,
       Author,
       Total_Copies,
       Available_Copies
FROM Books
WHERE Available_Copies > 0;


SELECT *
FROM Books
WHERE Category = 'Programming';


SELECT
    t.Transaction_ID,
    u.Full_Name,
    b.Title,
    t.Issue_Date,
    t.Due_Date,
    t.Return_Date,
    t.Status
FROM Transactions t
INNER JOIN Users u
ON t.User_ID = u.User_ID
INNER JOIN Books b
ON t.Book_ID = b.Book_ID;


CALL Refresh_Overdue_Status();


SELECT
    u.Full_Name,
    b.Title,
    t.Issue_Date,
    t.Due_Date
FROM Transactions t
JOIN Users u
ON t.User_ID = u.User_ID
JOIN Books b
ON t.Book_ID = b.Book_ID
WHERE t.Status IN ('Issued', 'Overdue')
  AND t.Return_Date IS NULL;


SELECT COUNT(*) AS Total_Books
FROM Books;


SELECT COUNT(*) AS Total_Users
FROM Users;


SELECT
    u.Full_Name,
    b.Title,
    t.Issue_Date,
    t.Due_Date,
    DATEDIFF(CURDATE(), t.Due_Date) AS Days_Overdue
FROM Transactions t
JOIN Users u
ON t.User_ID = u.User_ID
JOIN Books b
ON t.Book_ID = b.Book_ID
WHERE t.Status = 'Overdue'
  AND t.Return_Date IS NULL
  AND t.Due_Date < CURDATE();


SELECT
    b.Category,
    COUNT(*) AS Transaction_Count,
    SUM(t.Status IN ('Issued', 'Overdue')) AS Active_Loans,
    SUM(t.Status = 'Returned') AS Returned_Loans
FROM Transactions t
JOIN Books b
ON b.Book_ID = t.Book_ID
GROUP BY b.Category;


