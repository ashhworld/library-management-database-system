-- Sample Data
-- ------------------------------------------------------

-- Insert into Books TABLE
-- ------------------------------------------------------
INSERT INTO Books
(Title, Author, Publisher, ISBN, Category,
 Total_Copies, Available_Copies)
VALUES
('Database Systems', 'Korth', 'McGraw Hill',
 '9781234567890', 'Education', 5, 5),

('Java Programming', 'Herbert Schildt',
 'Oracle Press', '9781111111111',
 'Programming', 3, 3),

('Python Basics', 'Mark Lutz',
 'OReilly', '9782222222222',
 'Programming', 4, 4);


-- Insert into Users TABLE
-- ------------------------------------------------------

 INSERT INTO Users
(Full_Name, Email, Phone, Membership_Date)
VALUES
('Rahul Sharma',
 'rahul@gmail.com',
 '9876543210',
 CURDATE()),

('Priya Verma',
 'priya@gmail.com',
 '9876543211',
 CURDATE());

