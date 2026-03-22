-- Test Script for User-Defined Functions
-- Tests: CancelSession, EndMentorship, GetMentorshipSummary, CountAchievedGoals

-- Drop database if exists and recreate
DROP DATABASE IF EXISTS MentorLink;
CREATE DATABASE MentorLink;
USE MentorLink;

-- ============================================================================
-- SCHEMA SETUP - Import all schema files
-- ============================================================================

-- Subject Entity
CREATE TABLE Subject (
    SubjectID BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
    SubjectName VARCHAR(64) NOT NULL UNIQUE,
    CONSTRAINT pk_subject
        PRIMARY KEY (SubjectID),
    CONSTRAINT uq_subject_name
        UNIQUE (SubjectName)
);

-- User Tables
CREATE TABLE User(
	UserID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
	FirstName VARCHAR(32) NOT NULL,
    LastName VARCHAR(32) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(20),
	Password VARCHAR(128) NOT NULL,
	CONSTRAINT pk_user PRIMARY KEY (UserID),
    CONSTRAINT uq_user_email UNIQUE (Email)
);

CREATE TABLE User_Subject(
	UserID BINARY(16) NOT NULL,
	SubjectID BINARY(16) NOT NULL,
	UserType ENUM('Sought', 'Offered') NOT NULL,
    PRIMARY KEY(UserID, SubjectID, UserType),
	CONSTRAINT fk_user_ID
		FOREIGN KEY (UserID)
		REFERENCES User(UserID)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT fk_subject_ID
        FOREIGN KEY (SubjectID)
        REFERENCES Subject(SubjectID)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

-- Mentorship Entity
CREATE TABLE Mentorship(
  MentorshipID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
  SubjectID BINARY(16) NOT NULL,
  Status ENUM('Active','Ended') NOT NULL DEFAULT 'Active',
  CONSTRAINT pk_mentorship PRIMARY KEY (MentorshipID),
  CONSTRAINT fk_mentorship_subject
    FOREIGN KEY (SubjectID)
    REFERENCES Subject(SubjectID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE INDEX idx_Mentorship_SubjectID ON Mentorship(SubjectID);
CREATE INDEX idx_Mentorship_Status ON Mentorship(Status);

-- MentorshipMember Entity
CREATE TABLE MentorshipMember(
  MentorshipID BINARY(16) NOT NULL,
  UserID BINARY(16) NOT NULL,
  ROLE ENUM('Mentor', 'Mentee') NOT NULL,
  CONSTRAINT pk_mentorshipmember PRIMARY KEY(MentorshipID, UserID),
  CONSTRAINT fk_mentorshipmember_mentorship
      FOREIGN KEY (MentorshipID)
      REFERENCES Mentorship(MentorshipID)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
  CONSTRAINT fk_mentorshipmember_user
      FOREIGN KEY (UserID)
      REFERENCES User(UserID)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
  CONSTRAINT uq_mentorshipmember_role UNIQUE (MentorshipID, Role)
);

CREATE INDEX idx_mentorshipmember_user ON MentorshipMember(UserID);
CREATE INDEX idx_mentorshipmember_role ON MentorshipMember(Role);

-- Session Entity
CREATE TABLE Session (
    SessionID BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
    MentorshipID BINARY(16) NOT NULL,
    Timestamp TIMESTAMP NOT NULL,
    InstructionType ENUM('Virtual', 'In-Person') NOT NULL,
    Location TINYTEXT NOT NULL,
    Status ENUM('Scheduled', 'Cancelled', 'Completed') NOT NULL DEFAULT 'Scheduled',
    CONSTRAINT pk_session PRIMARY KEY (SessionID),
    CONSTRAINT fk_session_mentorship
        FOREIGN KEY (MentorshipID)
        REFERENCES Mentorship(MentorshipID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE INDEX idx_session_mentorship ON Session(MentorshipID);
CREATE INDEX idx_session_timestamp ON Session(Timestamp);
CREATE INDEX idx_session_mentorship_timestamp ON Session(MentorshipID, Timestamp);
CREATE INDEX idx_session_status ON Session(Status);

-- Goal and Rating Entities
CREATE TABLE Goal (
    GoalID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
    MentorshipID BINARY(16) NOT NULL,
    Description TEXT NOT NULL,
    Status ENUM('Set','Achieved') NOT NULL DEFAULT 'Set',
    CONSTRAINT pk_goal PRIMARY KEY (GoalID),
    CONSTRAINT fk_goal_mentorship
        FOREIGN KEY (MentorshipID)
        REFERENCES Mentorship(MentorshipID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE INDEX idx_goal_mentorship ON Goal(MentorshipID);
CREATE INDEX idx_goal_status ON Goal(Status);
CREATE INDEX idx_goal_mentorship_status ON Goal(MentorshipID, Status);

CREATE TABLE IF NOT EXISTS Rating (
    RatingID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
    MentorshipID BINARY(16) NOT NULL,
    RaterUserID BINARY(16) NOT NULL,
    RatedUserID BINARY(16) NOT NULL,
    RatingValue ENUM('Poor','Neutral','Good') NOT NULL,
    RatingDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_rating PRIMARY KEY (RatingID),
    CONSTRAINT fk_rating_mentorship
        FOREIGN KEY (MentorshipID)
        REFERENCES Mentorship(MentorshipID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_rating_rater
        FOREIGN KEY (RaterUserID)
        REFERENCES User(UserID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_rating_rated
        FOREIGN KEY (RatedUserID)
        REFERENCES User(UserID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_no_self_rating CHECK (RaterUserID <> RatedUserID),
    CONSTRAINT uq_rating_once UNIQUE (MentorshipID, RaterUserID, RatedUserID)
);

CREATE INDEX idx_rating_mentorship ON Rating(MentorshipID);
CREATE INDEX idx_rating_rater ON Rating(RaterUserID);
CREATE INDEX idx_rating_rated ON Rating(RatedUserID);
CREATE INDEX idx_rating_value ON Rating(RatingValue);
CREATE INDEX idx_rating_date ON Rating(RatingDate);

-- ============================================================================
-- USER FUNCTIONS - Import user_functions.sql
-- ============================================================================

DELIMITER //

CREATE PROCEDURE CancelSession(
    IN p_SessionID BINARY(16)
)
BEGIN
    DECLARE v_SessionStatus VARCHAR(20);
    DECLARE v_RowCount INT;

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
    IN p_MentorshipID BINARY(16)
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
    IN p_MentorshipID BINARY(16)
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
        AND mm_mentor.Role = 'Mentor'
    LEFT JOIN User mentor_u ON mm_mentor.UserID = mentor_u.UserID
    LEFT JOIN MentorshipMember mm_mentee ON m.MentorshipID = mm_mentee.MentorshipID
        AND mm_mentee.Role = 'Mentee'
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
    p_MentorshipID BINARY(16)
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
-- TEST DATA SETUP
-- ============================================================================

-- Insert test subjects
INSERT INTO Subject (SubjectName) VALUES ('Mathematics');
INSERT INTO Subject (SubjectName) VALUES ('Physics');
INSERT INTO Subject (SubjectName) VALUES ('Computer Science');

-- Get subject IDs for use in inserts
SET @math_subject = (SELECT SubjectID FROM Subject WHERE SubjectName = 'Mathematics');
SET @physics_subject = (SELECT SubjectID FROM Subject WHERE SubjectName = 'Physics');
SET @cs_subject = (SELECT SubjectID FROM Subject WHERE SubjectName = 'Computer Science');

-- Insert test users
INSERT INTO User (FirstName, LastName, Email, Password) VALUES ('John', 'Smith', 'john.smith@email.com', 'pass123');
INSERT INTO User (FirstName, LastName, Email, Password) VALUES ('Jane', 'Doe', 'jane.doe@email.com', 'pass123');
INSERT INTO User (FirstName, LastName, Email, Password) VALUES ('Bob', 'Johnson', 'bob.johnson@email.com', 'pass123');
INSERT INTO User (FirstName, LastName, Email, Password) VALUES ('Alice', 'Williams', 'alice.williams@email.com', 'pass123');

-- Get user IDs
SET @mentor1 = (SELECT UserID FROM User WHERE Email = 'john.smith@email.com');
SET @mentee1 = (SELECT UserID FROM User WHERE Email = 'jane.doe@email.com');
SET @mentor2 = (SELECT UserID FROM User WHERE Email = 'bob.johnson@email.com');
SET @mentee2 = (SELECT UserID FROM User WHERE Email = 'alice.williams@email.com');

-- Insert mentorships
INSERT INTO Mentorship (SubjectID, Status) VALUES (@math_subject, 'Active');
INSERT INTO Mentorship (SubjectID, Status) VALUES (@physics_subject, 'Active');
INSERT INTO Mentorship (SubjectID, Status) VALUES (@cs_subject, 'Ended');

-- Get mentorship IDs
SET @mentorship1 = (SELECT MentorshipID FROM Mentorship WHERE SubjectID = @math_subject LIMIT 1);
SET @mentorship2 = (SELECT MentorshipID FROM Mentorship WHERE SubjectID = @physics_subject LIMIT 1);
SET @mentorship3 = (SELECT MentorshipID FROM Mentorship WHERE SubjectID = @cs_subject LIMIT 1);

-- Insert mentorship members
INSERT INTO MentorshipMember (MentorshipID, UserID, ROLE) VALUES (@mentorship1, @mentor1, 'Mentor');
INSERT INTO MentorshipMember (MentorshipID, UserID, ROLE) VALUES (@mentorship1, @mentee1, 'Mentee');
INSERT INTO MentorshipMember (MentorshipID, UserID, ROLE) VALUES (@mentorship2, @mentor2, 'Mentor');
INSERT INTO MentorshipMember (MentorshipID, UserID, ROLE) VALUES (@mentorship2, @mentee2, 'Mentee');
INSERT INTO MentorshipMember (MentorshipID, UserID, ROLE) VALUES (@mentorship3, @mentor1, 'Mentor');
INSERT INTO MentorshipMember (MentorshipID, UserID, ROLE) VALUES (@mentorship3, @mentee2, 'Mentee');

-- Insert sessions
INSERT INTO Session (MentorshipID, Timestamp, InstructionType, Location, Status)
VALUES (@mentorship1, '2026-03-25 10:00:00', 'Virtual', 'Zoom', 'Scheduled');

INSERT INTO Session (MentorshipID, Timestamp, InstructionType, Location, Status)
VALUES (@mentorship1, '2026-03-22 14:00:00', 'In-Person', 'Library', 'Completed');

INSERT INTO Session (MentorshipID, Timestamp, InstructionType, Location, Status)
VALUES (@mentorship2, '2026-03-26 15:00:00', 'Virtual', 'Google Meet', 'Scheduled');

SET @session1 = (SELECT SessionID FROM Session WHERE MentorshipID = @mentorship1 AND Status = 'Scheduled' LIMIT 1);
SET @session2 = (SELECT SessionID FROM Session WHERE MentorshipID = @mentorship2 AND Status = 'Scheduled' LIMIT 1);

-- Insert goals
INSERT INTO Goal (MentorshipID, Description, Status) VALUES (@mentorship1, 'Complete Algebra Chapter 1', 'Achieved');
INSERT INTO Goal (MentorshipID, Description, Status) VALUES (@mentorship1, 'Complete Algebra Chapter 2', 'Achieved');
INSERT INTO Goal (MentorshipID, Description, Status) VALUES (@mentorship1, 'Complete Algebra Chapter 3', 'Set');

INSERT INTO Goal (MentorshipID, Description, Status) VALUES (@mentorship2, 'Learn Newton Laws', 'Achieved');
INSERT INTO Goal (MentorshipID, Description, Status) VALUES (@mentorship2, 'Complete homework problems', 'Set');

INSERT INTO Goal (MentorshipID, Description, Status) VALUES (@mentorship3, 'Master Data Structures', 'Achieved');
INSERT INTO Goal (MentorshipID, Description, Status) VALUES (@mentorship3, 'Complete Projects', 'Achieved');

-- ============================================================================
-- TESTS
-- ============================================================================

DELIMITER //
CREATE PROCEDURE RunAllTests()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT;
        SELECT CONCAT('Error occurred: ', @p1, ' - ', @p2) AS TestResult;
    END;

    SELECT '========================================' AS '';
    SELECT 'TEST 1: CancelSession - Valid Session' AS '';
    SELECT '========================================' AS '';
    CALL CancelSession(@session1);
    SELECT 'Session status after cancel:' AS '';
    SELECT Status FROM Session WHERE SessionID = @session1;

    SELECT '' AS '';
    SELECT '========================================' AS '';
    SELECT 'TEST 2: CancelSession - Already Cancelled (Should Error)' AS '';
    SELECT '========================================' AS '';
    CALL CancelSession(@session1);

    SELECT '' AS '';
    SELECT '========================================' AS '';
    SELECT 'TEST 3: CancelSession - Completed Session (Should Error)' AS '';
    SELECT '========================================' AS '';
    SET @completed_session = (SELECT SessionID FROM Session WHERE Status = 'Completed' LIMIT 1);
    CALL CancelSession(@completed_session);

    SELECT '' AS '';
    SELECT '========================================' AS '';
    SELECT 'TEST 4: EndMentorship - Valid Active Mentorship' AS '';
    SELECT '========================================' AS '';
    CALL EndMentorship(@mentorship1);
    SELECT 'Mentorship status after end:' AS '';
    SELECT Status FROM Mentorship WHERE MentorshipID = @mentorship1;

    SELECT '' AS '';
    SELECT '========================================' AS '';
    SELECT 'TEST 5: EndMentorship - Already Ended (Should Error)' AS '';
    SELECT '========================================' AS '';
    CALL EndMentorship(@mentorship3);

    SELECT '' AS '';
    SELECT '========================================' AS '';
    SELECT 'TEST 6: GetMentorshipSummary - Active Mentorship' AS '';
    SELECT '========================================' AS '';
    CALL GetMentorshipSummary(@mentorship2);

    SELECT '' AS '';
    SELECT '========================================' AS '';
    SELECT 'TEST 7: GetMentorshipSummary - Ended Mentorship' AS '';
    SELECT '========================================' AS '';
    CALL GetMentorshipSummary(@mentorship3);

    SELECT '' AS '';
    SELECT '========================================' AS '';
    SELECT 'TEST 8: CountAchievedGoals - Mentorship 1' AS '';
    SELECT '========================================' AS '';
    SELECT CountAchievedGoals(@mentorship1) AS AchievedGoalsCount;

    SELECT '' AS '';
    SELECT '========================================' AS '';
    SELECT 'TEST 9: CountAchievedGoals - Mentorship 2' AS '';
    SELECT '========================================' AS '';
    SELECT CountAchievedGoals(@mentorship2) AS AchievedGoalsCount;

    SELECT '' AS '';
    SELECT '========================================' AS '';
    SELECT 'TEST 10: CountAchievedGoals - Mentorship 3 (Ended)' AS '';
    SELECT '========================================' AS '';
    SELECT CountAchievedGoals(@mentorship3) AS AchievedGoalsCount;

    SELECT '' AS '';
    SELECT '========================================' AS '';
    SELECT 'TEST 11: CountAchievedGoals - Invalid Mentorship (Should Return 0)' AS '';
    SELECT '========================================' AS '';
    SET @invalid_mentorship = (SELECT UUID_TO_BIN(UUID()));
    SELECT CountAchievedGoals(@invalid_mentorship) AS AchievedGoalsCount;

END //

DELIMITER ;

-- Run all tests
CALL RunAllTests();
