DELIMITER //

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

DELIMITER ;
