SELECT * FROM Books;


SELECT Book_ID,
       Title,
       Author,
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
    t.Status
FROM Transactions t
INNER JOIN Users u
ON t.User_ID = u.User_ID
INNER JOIN Books b
ON t.Book_ID = b.Book_ID;


SELECT
    u.Full_Name,
    b.Title,
    t.Issue_Date
FROM Transactions t
JOIN Users u
ON t.User_ID = u.User_ID
JOIN Books b
ON t.Book_ID = b.Book_ID
WHERE t.Status = 'Issued';


SELECT COUNT(*) AS Total_Books
FROM Books;


SELECT COUNT(*) AS Total_Users
FROM Users;


SELECT
    u.Full_Name,
    b.Title,
    t.Issue_Date
FROM Transactions t
JOIN Users u
ON t.User_ID = u.User_ID
JOIN Books b
ON t.Book_ID = b.Book_ID
WHERE t.Status = 'Issued'
AND DATEDIFF(CURDATE(), t.Issue_Date) > 15;


