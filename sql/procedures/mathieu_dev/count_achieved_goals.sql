DELIMITER //

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
