-- Query 1: View the name of a subject AND its ID
-- from a specific department
-- Possible Use: Find a subject in a department 
-- and view its ID to 'Add_User_Subject_Interest'
SELECT 
	BIN_TO_UUID(SubjectID) AS SubjectID,
	SubjectName
FROM Subject
	WHERE Subject.Department = 'History';

-- Query 2: Find Users that are offering subjects 
-- in a specific department
-- Possible Use: Looking for indivituals offering
-- mentorship for a subject
SELECT 
    User.FirstName,
    User.LastName,
    Subject.SubjectName,
    User_Subject.UserType
FROM User_Subject
JOIN Subject 
    ON User_Subject.SubjectID = Subject.SubjectID
JOIN User
    ON User.UserID = User_Subject.UserID
WHERE Subject.Department = 'History'
  AND User_Subject.UserType = 'Offered';
