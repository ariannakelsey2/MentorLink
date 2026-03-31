DELIMITER //

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

DELIMITER ;
