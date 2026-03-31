-- Test Script for User-Defined Functions using Sample Data
-- Tests: CancelSession, EndMentorship, GetMentorshipSummary, CountAchievedGoals

-- ============================================================================
-- DATABASE SETUP
-- ============================================================================
DROP DATABASE IF EXISTS MentorLink;
CREATE DATABASE MentorLink;
USE MentorLink;

-- ============================================================================
-- SCHEMA SETUP
-- ============================================================================

-- Subject Entity
CREATE TABLE Subject (
    SubjectID INT PRIMARY KEY,
    SubjectName VARCHAR(64) NOT NULL UNIQUE
);

-- User Table
CREATE TABLE User(
    UserID INT PRIMARY KEY,
    FirstName VARCHAR(32) NOT NULL,
    LastName VARCHAR(32) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Password VARCHAR(128) NOT NULL,
    PhoneNumber VARCHAR(20)
);

-- User_Subject Table
CREATE TABLE User_Subject(
    UserID INT NOT NULL,
    SubjectID INT NOT NULL,
    UserType ENUM('Sought', 'Offered') NOT NULL,
    PRIMARY KEY(UserID, SubjectID, UserType),
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (SubjectID) REFERENCES Subject(SubjectID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Mentorship Entity
CREATE TABLE Mentorship(
    MentorshipID INT PRIMARY KEY,
    SubjectID INT NOT NULL,
    Status ENUM('Active','Ended') NOT NULL DEFAULT 'Active',
    FOREIGN KEY (SubjectID) REFERENCES Subject(SubjectID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_Mentorship_Status ON Mentorship(Status);

-- MentorshipMember Entity
CREATE TABLE MentorshipMember(
    MentorshipID INT NOT NULL,
    UserID INT NOT NULL,
    ROLEVALUE ENUM('Mentor', 'Mentee') NOT NULL,
    PRIMARY KEY(MentorshipID, UserID),
    FOREIGN KEY (MentorshipID) REFERENCES Mentorship(MentorshipID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (MentorshipID, ROLEVALUE)
);

CREATE INDEX idx_mentorshipmember_user ON MentorshipMember(UserID);
CREATE INDEX idx_mentorshipmember_rolevalue ON MentorshipMember(ROLEVALUE);

-- Session Entity
CREATE TABLE Session (
    SessionID INT PRIMARY KEY,
    MentorshipID INT NOT NULL,
    Timestamp TIMESTAMP NOT NULL,
    InstructionType ENUM('Virtual', 'In-Person') NOT NULL,
    Location TINYTEXT NOT NULL,
    Status ENUM('Scheduled', 'Cancelled', 'Completed') NOT NULL DEFAULT 'Scheduled',
    FOREIGN KEY (MentorshipID) REFERENCES Mentorship(MentorshipID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_session_mentorship ON Session(MentorshipID);
CREATE INDEX idx_session_timestamp ON Session(Timestamp);
CREATE INDEX idx_session_mentorship_timestamp ON Session(MentorshipID, Timestamp);
CREATE INDEX idx_session_status ON Session(Status);

-- Goal Entity
CREATE TABLE Goal (
    GoalID INT PRIMARY KEY,
    MentorshipID INT NOT NULL,
    Description TEXT NOT NULL,
    Status ENUM('Set','Achieved') NOT NULL DEFAULT 'Set',
    FOREIGN KEY (MentorshipID) REFERENCES Mentorship(MentorshipID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_goal_mentorship_status ON Goal(MentorshipID, Status);

-- Rating Entity
CREATE TABLE Rating (
    RatingID INT PRIMARY KEY,
    MentorshipID INT NOT NULL,
    RaterUserID INT NOT NULL,
    RatedUserID INT NOT NULL,
    RatingValue ENUM('Poor','Neutral','Good') NOT NULL,
    RatingDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (MentorshipID) REFERENCES Mentorship(MentorshipID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (RaterUserID) REFERENCES User(UserID) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (RatedUserID) REFERENCES User(UserID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (RaterUserID <> RatedUserID),
    UNIQUE (MentorshipID, RaterUserID, RatedUserID)
);

CREATE INDEX idx_rating_mentorship ON Rating(MentorshipID);

-- ============================================================================
-- USER FUNCTIONS
-- ============================================================================

DELIMITER //

CREATE PROCEDURE CancelSession(
    IN p_SessionID INT
)
BEGIN
    DECLARE v_SessionStatus VARCHAR(20);

    IF p_SessionID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: SessionID cannot be NULL';
    END IF;

    SELECT Status INTO v_SessionStatus
    FROM Session
    WHERE SessionID = p_SessionID;

    IF v_SessionStatus IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Session not found';
    END IF;

    IF v_SessionStatus = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Session is already cancelled';
    END IF;

    IF v_SessionStatus = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Cannot cancel a completed session';
    END IF;

    UPDATE Session
    SET Status = 'Cancelled'
    WHERE SessionID = p_SessionID;

    SELECT 'Session cancelled successfully' AS Message;
END //

CREATE PROCEDURE EndMentorship(
    IN p_MentorshipID INT
)
BEGIN
    DECLARE v_MentorshipStatus VARCHAR(20);

    IF p_MentorshipID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: MentorshipID cannot be NULL';
    END IF;

    SELECT Status INTO v_MentorshipStatus
    FROM Mentorship
    WHERE MentorshipID = p_MentorshipID;

    IF v_MentorshipStatus IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Mentorship not found';
    END IF;

    IF v_MentorshipStatus = 'Ended' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Mentorship is already ended';
    END IF;

    UPDATE Mentorship
    SET Status = 'Ended'
    WHERE MentorshipID = p_MentorshipID;

    SELECT 'Mentorship ended successfully' AS Message;
END //

CREATE PROCEDURE GetMentorshipSummary(
    IN p_MentorshipID INT
)
BEGIN
    DECLARE v_Exists INT;

    IF p_MentorshipID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: MentorshipID cannot be NULL';
    END IF;

    SELECT COUNT(*) INTO v_Exists
    FROM Mentorship
    WHERE MentorshipID = p_MentorshipID;

    IF v_Exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Mentorship not found';
    END IF;

    SELECT
        m.MentorshipID,
        m.SubjectID,
        s.SubjectName,
        m.Status AS MentorshipStatus,
        mentor_u.UserID AS MentorID,
        mentor_u.FirstName AS MentorFirstName,
        mentor_u.LastName AS MentorLastName,
        mentor_u.Email AS MentorEmail,
        mentee_u.UserID AS MenteeID,
        mentee_u.FirstName AS MenteeFirstName,
        mentee_u.LastName AS MenteeLastName,
        mentee_u.Email AS MenteeEmail,
        COALESCE(goal_counts.TotalGoals, 0) AS TotalGoals,
        COALESCE(goal_counts.AchievedGoals, 0) AS AchievedGoals,
        COALESCE(session_counts.CompletedSessions, 0) AS CompletedSessions
    FROM Mentorship m
    INNER JOIN Subject s ON m.SubjectID = s.SubjectID
    LEFT JOIN MentorshipMember mm_mentor ON m.MentorshipID = mm_mentor.MentorshipID
        AND mm_mentor.ROLEVALUE = 'Mentor'
    LEFT JOIN User mentor_u ON mm_mentor.UserID = mentor_u.UserID
    LEFT JOIN MentorshipMember mm_mentee ON m.MentorshipID = mm_mentee.MentorshipID
        AND mm_mentee.ROLEVALUE = 'Mentee'
    LEFT JOIN User mentee_u ON mm_mentee.UserID = mentee_u.UserID
    LEFT JOIN (
        SELECT
            MentorshipID,
            COUNT(*) AS TotalGoals,
            SUM(CASE WHEN Status = 'Achieved' THEN 1 ELSE 0 END) AS AchievedGoals
        FROM Goal
        GROUP BY MentorshipID
    ) goal_counts ON m.MentorshipID = goal_counts.MentorshipID
    LEFT JOIN (
        SELECT
            MentorshipID,
            COUNT(*) AS CompletedSessions
        FROM Session
        WHERE Status = 'Completed'
        GROUP BY MentorshipID
    ) session_counts ON m.MentorshipID = session_counts.MentorshipID
    WHERE m.MentorshipID = p_MentorshipID;
END //

CREATE FUNCTION CountAchievedGoals(
    p_MentorshipID INT
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_Count INT DEFAULT 0;
    DECLARE v_Exists INT;

    IF p_MentorshipID IS NULL THEN
        RETURN 0;
    END IF;

    SELECT COUNT(*) INTO v_Exists
    FROM Mentorship
    WHERE MentorshipID = p_MentorshipID;

    IF v_Exists = 0 THEN
        RETURN 0;
    END IF;

    SELECT COUNT(*) INTO v_Count
    FROM Goal
    WHERE MentorshipID = p_MentorshipID
    AND Status = 'Achieved';

    RETURN v_Count;
END //

DELIMITER ;

-- ============================================================================
-- SAMPLE DATA INSERTION
-- ============================================================================

-- Insert Subjects
INSERT INTO Subject VALUES (111, 'Python');
INSERT INTO Subject VALUES (222, 'Algebra');
INSERT INTO Subject VALUES (333, 'Creative Writing');
INSERT INTO Subject VALUES (444, 'Resume Building');
INSERT INTO Subject VALUES (555, 'Chemistry');
INSERT INTO Subject VALUES (666, 'Biology');
INSERT INTO Subject VALUES (777, 'Java');
INSERT INTO Subject VALUES (888, 'Calculus');
INSERT INTO Subject VALUES (999, 'Public Speaking');
INSERT INTO Subject VALUES (101, 'SQL');
INSERT INTO Subject VALUES (202, 'Finance');
INSERT INTO Subject VALUES (303, 'Psychology');

-- Insert Users
INSERT INTO User VALUES (1, 'John', 'Smith', 'johnsmith@gmail.com', '9043543', '207-111-1111');
INSERT INTO User VALUES (2, 'Lola', 'Norrano', 'lolanorrano@gmail.com', '58303', '207-222-2222');
INSERT INTO User VALUES (3, 'Jenny', 'Terria', 'jennyterria@gmail.com', '3i04230', '207-333-3333');
INSERT INTO User VALUES (4, 'Peter', 'Lamm', 'peterlamm@gmail.com', '9t0[reogjwvfod', '207-444-4444');
INSERT INTO User VALUES (5, 'Flynn', 'Lobster', 'flynnlobster@gmail.com', '6yth898h', '207-555-5555');
INSERT INTO User VALUES (6, 'Julius', 'Cesar', 'juliuscesar@gmail.com', 'dh6hd73', '207-666-6666');
INSERT INTO User VALUES (7, 'Ghengis', 'Khan', 'ghengiskhan@gmail.com', 'dh57dh43', '207-777-7777');
INSERT INTO User VALUES (8, 'Tina', 'Turner', 'tinaturner@gmail.com', 'sh47dhcj', '207-888-8888');
INSERT INTO User VALUES (9, 'Serge', 'Ibaka', 'sergeibaka@gmail.com', 'dh5hcbh', '207-999-9999');
INSERT INTO User VALUES (10, 'Susan', 'Collins', 'susancollins@gmail.com', 'dhf7fh58', '207-121-2121');
INSERT INTO User VALUES (11, 'Count', 'Dracula', 'countdracula@gmail.com', 'dh847hsb', '207-313-3131');
INSERT INTO User VALUES (12, 'Naruto', 'Uzumaki', 'narutouzumaki@gmail.com', '7dh3bs8', '207-414-4141');

-- Insert Mentorships
INSERT INTO Mentorship VALUES (1010, 222, 'Active');
INSERT INTO Mentorship VALUES (1111, 111, 'Active');
INSERT INTO Mentorship VALUES (1212, 333, 'Ended');
INSERT INTO Mentorship VALUES (1313, 999, 'Active');
INSERT INTO Mentorship VALUES (1414, 444, 'Ended');
INSERT INTO Mentorship VALUES (1515, 101, 'Active');
INSERT INTO Mentorship VALUES (1616, 555, 'Active');
INSERT INTO Mentorship VALUES (1717, 202, 'Ended');
INSERT INTO Mentorship VALUES (1818, 666, 'Active');
INSERT INTO Mentorship VALUES (1919, 303, 'Active');

-- Insert MentorshipMembers
INSERT INTO MentorshipMember VALUES (1010, 3, 'Mentee');
INSERT INTO MentorshipMember VALUES (1010, 9, 'Mentor');
INSERT INTO MentorshipMember VALUES (1111, 9, 'Mentee');
INSERT INTO MentorshipMember VALUES (1111, 1, 'Mentor');
INSERT INTO MentorshipMember VALUES (1212, 8, 'Mentee');
INSERT INTO MentorshipMember VALUES (1212, 2, 'Mentor');
INSERT INTO MentorshipMember VALUES (1313, 2, 'Mentee');
INSERT INTO MentorshipMember VALUES (1313, 8, 'Mentor');
INSERT INTO MentorshipMember VALUES (1414, 10, 'Mentee');
INSERT INTO MentorshipMember VALUES (1414, 4, 'Mentor');
INSERT INTO MentorshipMember VALUES (1515, 4, 'Mentee');
INSERT INTO MentorshipMember VALUES (1515, 10, 'Mentor');
INSERT INTO MentorshipMember VALUES (1616, 5, 'Mentee');
INSERT INTO MentorshipMember VALUES (1616, 12, 'Mentor');
INSERT INTO MentorshipMember VALUES (1717, 11, 'Mentee');
INSERT INTO MentorshipMember VALUES (1717, 5, 'Mentor');
INSERT INTO MentorshipMember VALUES (1818, 12, 'Mentee');
INSERT INTO MentorshipMember VALUES (1818, 6, 'Mentor');
INSERT INTO MentorshipMember VALUES (1919, 6, 'Mentee');
INSERT INTO MentorshipMember VALUES (1919, 11, 'Mentor');

-- Insert Sessions (with Status column added)
-- Marking some as Scheduled, some as Completed, one will be cancelled in tests
INSERT INTO Session VALUES (0, 1010, '1970-01-01 00:00:01', 'In-Person', 'Gorham', 'Scheduled');
INSERT INTO Session VALUES (1, 1111, '1976-03-09 13:23:07', 'In-Person', 'Portland, Luther Bonney 202', 'Scheduled');
INSERT INTO Session VALUES (2, 1212, '1982-05-17 02:46:13', 'In-Person', '', 'Completed');
INSERT INTO Session VALUES (3, 1313, '1988-07-23 16:09:19', 'In-Person', '.', 'Scheduled');
INSERT INTO Session VALUES (4, 1414, '1994-09-30 05:32:25', 'In-Person', 'Portland, Payson-Smith 301', 'Completed');
INSERT INTO Session VALUES (5, 1515, '2000-12-06 18:55:31', 'In-Person', 'Gorham, Lower Brooks', 'Scheduled');
INSERT INTO Session VALUES (6, 1616, '2007-02-13 08:18:37', 'Virtual', '', 'Completed');
INSERT INTO Session VALUES (7, 1717, '2013-04-21 21:41:43', 'In-Person', 'Portland, Abromson lounge', 'Scheduled');
INSERT INTO Session VALUES (8, 1818, '2019-06-29 11:04:49', 'Virtual', '', 'Scheduled');
INSERT INTO Session VALUES (9, 1919, '2025-09-05 00:27:55', 'In-Person', 'Portland, Science Building C-245', 'Scheduled');
INSERT INTO Session VALUES (10, 1818, '2031-11-12 13:51:01', 'Virtual', '', 'Completed');
INSERT INTO Session VALUES (11, 1919, '2038-01-19 03:14:07', 'Virtual', '', 'Scheduled');

-- Insert Goals
INSERT INTO Goal VALUES (201, 1010, 'Master core algebra concepts', 'Achieved');
INSERT INTO Goal VALUES (202, 1010, 'Complete five algebra practice sets', 'Set');
INSERT INTO Goal VALUES (203, 1111, 'Improve Python programming fundamentals', 'Achieved');
INSERT INTO Goal VALUES (204, 1111, 'Build a small Python project', 'Set');
INSERT INTO Goal VALUES (205, 1212, 'Edit two writing pieces for class', 'Achieved');
INSERT INTO Goal VALUES (206, 1212, 'Write a short story', 'Set');
INSERT INTO Goal VALUES (207, 1313, 'Deliver a short mock presentation', 'Achieved');
INSERT INTO Goal VALUES (208, 1313, 'Practice powerpoint skills', 'Set');
INSERT INTO Goal VALUES (209, 1414, 'Create a polished one-page resume', 'Achieved');
INSERT INTO Goal VALUES (210, 1515, 'Learn introductory SQL queries', 'Set');
INSERT INTO Goal VALUES (211, 1616, 'Review core chemistry principles', 'Achieved');
INSERT INTO Goal VALUES (212, 1717, 'Explore introductory finance concepts', 'Set');
INSERT INTO Goal VALUES (213, 1818, 'Memorize introductory biology concepts for upcoming test', 'Set');
INSERT INTO Goal VALUES (214, 1919, 'Understand foundational psychology topics', 'Achieved');
INSERT INTO Goal VALUES (215, 1919, 'Complete a psychology reflection summary', 'Set');

-- Insert Ratings
INSERT INTO Rating VALUES (123, 1010, 2, 1, 'Good', '2026-03-01 10:15:00');
INSERT INTO Rating VALUES (234, 1010, 1, 2, 'Good', '2026-03-01 11:30:00');
INSERT INTO Rating VALUES (567, 1212, 3, 4, 'Neutral', '2026-03-02 09:45:00');
INSERT INTO Rating VALUES (8910, 1212, 4, 3, 'Good', '2026-03-02 14:20:00');
INSERT INTO Rating VALUES (1112, 1414, 5, 6, 'Poor', '2026-03-03 16:10:00');
INSERT INTO Rating VALUES (1314, 1515, 7, 8, 'Good', '2026-03-04 12:05:00');
INSERT INTO Rating VALUES (1516, 1616, 9, 10, 'Neutral', '2026-03-05 13:50:00');
INSERT INTO Rating VALUES (1718, 1717, 11, 12, 'Poor', '2026-03-06 15:25:00');

-- ============================================================================
-- TEST EXECUTION
-- ============================================================================

SELECT '=====================================================================' AS '';
SELECT 'TEST 1: CancelSession - Valid Scheduled Session' AS '';
SELECT '=====================================================================' AS '';
CALL CancelSession(0);
SELECT 'Session 0 status after cancel:' AS '';
SELECT SessionID, Status FROM Session WHERE SessionID = 0;

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'TEST 2: CancelSession - Try to cancel already scheduled session (error)' AS '';
SELECT '=====================================================================' AS '';
CALL CancelSession(0);

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'TEST 3: CancelSession - Try to cancel completed session (should error)' AS '';
SELECT '=====================================================================' AS '';
CALL CancelSession(2);

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'TEST 4: EndMentorship - Valid Active Mentorship' AS '';
SELECT '=====================================================================' AS '';
CALL EndMentorship(1010);
SELECT 'Mentorship 1010 status after end:' AS '';
SELECT MentorshipID, Status FROM Mentorship WHERE MentorshipID = 1010;

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'TEST 5: EndMentorship - Try to end already ended mentorship (error)' AS '';
SELECT '=====================================================================' AS '';
CALL EndMentorship(1212);

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'TEST 6: GetMentorshipSummary - Active Mentorship (1111 - Python)' AS '';
SELECT '=====================================================================' AS '';
CALL GetMentorshipSummary(1111);

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'TEST 7: GetMentorshipSummary - Ended Mentorship (1212 - Creative Writing)' AS '';
SELECT '=====================================================================' AS '';
CALL GetMentorshipSummary(1212);

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'TEST 8: GetMentorshipSummary - Active Mentorship (1313 - Public Speaking)' AS '';
SELECT '=====================================================================' AS '';
CALL GetMentorshipSummary(1313);

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'TEST 9: CountAchievedGoals - Mentorship 1010 (Algebra)' AS '';
SELECT '=====================================================================' AS '';
SELECT CountAchievedGoals(1010) AS AchievedGoalsCount;
SELECT 'Expected: 1, Reason: 1 goal with Status=Achieved in Mentorship 1010' AS '';

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'TEST 10: CountAchievedGoals - Mentorship 1111 (Python)' AS '';
SELECT '=====================================================================' AS '';
SELECT CountAchievedGoals(1111) AS AchievedGoalsCount;
SELECT 'Expected: 1, Reason: 1 goal with Status=Achieved in Mentorship 1111' AS '';

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'TEST 11: CountAchievedGoals - Mentorship 1212 (Creative Writing - ENDED)' AS '';
SELECT '=====================================================================' AS '';
SELECT CountAchievedGoals(1212) AS AchievedGoalsCount;
SELECT 'Expected: 1, Reason: 1 goal with Status=Achieved in Mentorship 1212' AS '';

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'TEST 12: CountAchievedGoals - Mentorship 1313 (Public Speaking)' AS '';
SELECT '=====================================================================' AS '';
SELECT CountAchievedGoals(1313) AS AchievedGoalsCount;
SELECT 'Expected: 1, Reason: 1 goal with Status=Achieved in Mentorship 1313' AS '';

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'TEST 13: CountAchievedGoals - All Mentorships Summary' AS '';
SELECT '=====================================================================' AS '';
SELECT
    m.MentorshipID,
    s.SubjectName,
    m.Status,
    CountAchievedGoals(m.MentorshipID) AS AchievedGoalsCount
FROM Mentorship m
JOIN Subject s ON m.SubjectID = s.SubjectID
ORDER BY m.MentorshipID;

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'TEST 14: Query Optimization Demo - Sessions By Mentorship (Baseline vs Optimized)' AS '';
SELECT '=====================================================================' AS '';

-- Query 1 baseline (non-sargable and wider row fetch)
EXPLAIN
SELECT *
FROM Session
WHERE MentorshipID = 1919
ORDER BY Timestamp;

SELECT
        SessionID,
        MentorshipID,
        Timestamp,
        InstructionType,
        Location,
        Status
FROM Session
WHERE MentorshipID = 1919
ORDER BY Timestamp;

-- Query 1 optimized (narrow projection, deterministic ordering)
EXPLAIN
SELECT
        SessionID,
        MentorshipID,
        Timestamp,
        InstructionType,
        Location,
        Status
FROM Session
WHERE MentorshipID = 1919
ORDER BY Timestamp ASC, SessionID ASC;

SELECT
        SessionID,
        MentorshipID,
        Timestamp,
        InstructionType,
        Location,
        Status
FROM Session
WHERE MentorshipID = 1919
ORDER BY Timestamp ASC, SessionID ASC;

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'TEST 15: Query Optimization Demo - Upcoming Scheduled Sessions (Baseline vs Optimized)' AS '';
SELECT '=====================================================================' AS '';

-- Query 2 baseline (non-sargable date predicate)
EXPLAIN
SELECT *
FROM Session
WHERE MentorshipID = 1919
    AND DATE(Timestamp) >= DATE('2025-01-01 00:00:00')
    AND Status = 'Scheduled'
ORDER BY Timestamp;

SELECT
        SessionID,
        MentorshipID,
        Timestamp,
        InstructionType,
        Location,
        Status
FROM Session
WHERE MentorshipID = 1919
    AND DATE(Timestamp) >= DATE('2025-01-01 00:00:00')
    AND Status = 'Scheduled'
ORDER BY Timestamp;

-- Query 2 optimized (sargable timestamp filter and narrow projection)
EXPLAIN
SELECT
        SessionID,
        Timestamp,
        InstructionType,
        Location,
        Status
FROM Session
WHERE MentorshipID = 1919
    AND Timestamp >= '2025-01-01 00:00:00'
    AND Status = 'Scheduled'
ORDER BY Timestamp ASC, SessionID ASC;

SELECT
        SessionID,
        Timestamp,
        InstructionType,
        Location,
        Status
FROM Session
WHERE MentorshipID = 1919
    AND Timestamp >= '2025-01-01 00:00:00'
    AND Status = 'Scheduled'
ORDER BY Timestamp ASC, SessionID ASC;

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'TEST 16: Session Status Distribution' AS '';
SELECT '=====================================================================' AS '';
SELECT Status, COUNT(*) as Count FROM Session GROUP BY Status;

SELECT '' AS '';
SELECT '=====================================================================' AS '';
SELECT 'ALL TESTS COMPLETED SUCCESSFULLY' AS '';
SELECT '=====================================================================' AS '';
