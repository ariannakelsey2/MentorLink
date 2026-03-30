-- Query #1 Find mentors by department

-- Before index

EXPLAIN ANALYZE 

-- Specify which variables to output
SELECT DISTINCT
    sub.Department, 
    BIN_TO_UUID(u.UserID)  AS UserID,
    u.FirstName,
    u.LastName,
    u.Email
    
    
-- Joining the User, MentorshipMember, Mentorship, and Subject tables
FROM User u
JOIN MentorshipMember mm
    ON u.UserID = mm.UserID
   AND mm.RoleValue = 'Mentor'
JOIN Mentorship m
    ON mm.MentorshipID = m.MentorshipID
JOIN Subject sub
    ON m.SubjectID = sub.SubjectID
-- Sort the list of all mentors by department
ORDER BY sub.Department;


-- Create index on Department column in Subject table
CREATE INDEX idx_subject_department
    ON Subject(Department);

-- Rerun the query after creating the index
EXPLAIN ANALYZE 

-- Specify which variables to output
SELECT DISTINCT
    sub.Department, 
    BIN_TO_UUID(u.UserID)  AS UserID,
    u.FirstName,
    u.LastName,
    u.Email
    
    
-- Joining the User, MentorshipMember, Mentorship, and Subject tables
FROM User u
JOIN MentorshipMember mm
    ON u.UserID = mm.UserID
   AND mm.RoleValue = 'Mentor'
JOIN Mentorship m
    ON mm.MentorshipID = m.MentorshipID
JOIN Subject sub
    ON m.SubjectID = sub.SubjectID
-- Sort the list of all mentors by department
ORDER BY sub.Department;


-- Query #2: Find mentors with active mentorships in the subject Python
EXPLAIN ANALYZE 

-- Specify variables to select
SELECT
    BIN_TO_UUID(u.UserID) AS UserID,
    u.FirstName,
    u.LastName,
    u.Email,
    BIN_TO_UUID(m.MentorshipID) AS MentorshipID,
    sub.SubjectName,
    sub.Department

-- Join User, MentorshipMember, Mentorship, and Subject tables
FROM User u
JOIN MentorshipMember mm
    ON u.UserID = mm.UserID
   AND mm.RoleValue = 'Mentor'
JOIN Mentorship m
    ON mm.MentorshipID = m.MentorshipID
   AND m.Status = 'Active'
JOIN Subject sub
	ON m.SubjectID = sub.SubjectID
    AND sub.SubjectName = 'Python';

-- Create index    
CREATE INDEX idx_subject_subjectname
ON Subject(SubjectName);

-- Rerun query with index

EXPLAIN ANALYZE SELECT
    BIN_TO_UUID(u.UserID) AS UserID,
    u.FirstName,
    u.LastName,
    u.Email,
    BIN_TO_UUID(m.MentorshipID) AS MentorshipID,
    sub.SubjectName,
    sub.Department
FROM User u
JOIN MentorshipMember mm
    ON u.UserID = mm.UserID
   AND mm.RoleValue = 'Mentor'
JOIN Mentorship m
    ON mm.MentorshipID = m.MentorshipID
   AND m.Status = 'Active'
JOIN Subject sub
	ON m.SubjectID = sub.SubjectID
    AND sub.SubjectName = 'Python';