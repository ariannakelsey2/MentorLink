-- The following is LLM-generated content 

-- MentorLink User-Defined Functions
-- Functions: CancelSession, EndMentorship, GetMentorshipSummary, CountAchievedGoals
-- Description: Provides utility functions for managing mentorship sessions, goals, and mentorship status

DELIMITER //

-- ============================================================================
-- 1. CancelSession
-- Description: Cancels a scheduled session by updating its status to 'Cancelled'
-- Parameters:
--   - p_SessionID: The UUID of the session to cancel (BINARY(16))
-- Returns:
--   - 0 if successful
--   - Error if session not found or already cancelled/completed
-- ============================================================================
CREATE PROCEDURE CancelSession(
    IN p_SessionID BINARY(16)
)
BEGIN
    DECLARE v_SessionStatus VARCHAR(20);
    DECLARE v_RowCount INT;

    -- Check if session ID is NULL
    IF p_SessionID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: SessionID cannot be NULL';
    END IF;

    -- Check if session exists and get its current status
    SELECT Status INTO v_SessionStatus
    FROM Session
    WHERE SessionID = p_SessionID;

    IF v_SessionStatus IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Session not found';
    END IF;

    -- Check if session is already cancelled or completed
    IF v_SessionStatus = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Session is already cancelled';
    END IF;

    IF v_SessionStatus = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Cannot cancel a completed session';
    END IF;

    -- Update session status to Cancelled
    UPDATE Session
    SET Status = 'Cancelled'
    WHERE SessionID = p_SessionID;

    SELECT 'Session cancelled successfully' AS Message;
END //


-- ============================================================================
-- 2. EndMentorship
-- Description: Ends an active mentorship by updating its status to 'Ended'
-- Parameters:
--   - p_MentorshipID: The UUID of the mentorship to end (BINARY(16))
-- Returns:
--   - 0 if successful
--   - Error if mentorship not found or already ended
-- ============================================================================
CREATE PROCEDURE EndMentorship(
    IN p_MentorshipID BINARY(16)
)
BEGIN
    DECLARE v_MentorshipStatus VARCHAR(20);

    -- Check if mentorship ID is NULL
    IF p_MentorshipID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: MentorshipID cannot be NULL';
    END IF;

    -- Check if mentorship exists and get its current status
    SELECT Status INTO v_MentorshipStatus
    FROM Mentorship
    WHERE MentorshipID = p_MentorshipID;

    IF v_MentorshipStatus IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Mentorship not found';
    END IF;

    -- Check if mentorship is already ended
    IF v_MentorshipStatus = 'Ended' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Mentorship is already ended';
    END IF;

    -- Update mentorship status to Ended
    UPDATE Mentorship
    SET Status = 'Ended'
    WHERE MentorshipID = p_MentorshipID;

    SELECT 'Mentorship ended successfully' AS Message;
END //


-- ============================================================================
-- 3. GetMentorshipSummary
-- Description: Retrieves comprehensive summary information about a mentorship
-- Parameters:
--   - p_MentorshipID: The UUID of the mentorship (BINARY(16))
-- Returns:
--   - Result set with mentorship details including:
--     * MentorshipID, SubjectID, SubjectName, Status
--     * Mentor user info (FirstName, LastName, Email)
--     * Mentee user info (FirstName, LastName, Email)
--     * Total goals count and achieved goals count
--     * Completed sessions count
-- ============================================================================
CREATE PROCEDURE GetMentorshipSummary(
    IN p_MentorshipID BINARY(16)
)
BEGIN
    DECLARE v_Exists INT;

    -- Check if mentorship ID is NULL
    IF p_MentorshipID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: MentorshipID cannot be NULL';
    END IF;

    -- Check if mentorship exists
    SELECT COUNT(*) INTO v_Exists
    FROM Mentorship
    WHERE MentorshipID = p_MentorshipID;

    IF v_Exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Mentorship not found';
    END IF;

    -- Return comprehensive mentorship summary
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
        AND mm_mentor.RoleValue = 'Mentor'
    LEFT JOIN User mentor_u ON mm_mentor.UserID = mentor_u.UserID
    LEFT JOIN MentorshipMember mm_mentee ON m.MentorshipID = mm_mentee.MentorshipID
        AND mm_mentee.RoleValue = 'Mentee'
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


-- ============================================================================
-- 4. CountAchievedGoals
-- Description: Counts the number of achieved goals in a mentorship
-- Parameters:
--   - p_MentorshipID: The UUID of the mentorship (BINARY(16))
-- Returns:
--   - Integer count of goals with Status = 'Achieved'
-- ============================================================================
CREATE FUNCTION CountAchievedGoals(
    p_MentorshipID BINARY(16)
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_Count INT DEFAULT 0;
    DECLARE v_Exists INT;

    -- Check if mentorship ID is NULL
    IF p_MentorshipID IS NULL THEN
        RETURN 0;
    END IF;

    -- Check if mentorship exists
    SELECT COUNT(*) INTO v_Exists
    FROM Mentorship
    WHERE MentorshipID = p_MentorshipID;

    IF v_Exists = 0 THEN
        RETURN 0;
    END IF;

    -- Count achieved goals
    SELECT COUNT(*) INTO v_Count
    FROM Goal
    WHERE MentorshipID = p_MentorshipID
    AND Status = 'Achieved';

    RETURN v_Count;
END //

DELIMITER ;
