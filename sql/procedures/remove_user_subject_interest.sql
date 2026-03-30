-- Arianna Kelsey

USE MentorLink;

DROP PROCEDURE IF EXISTS RemoveUserSubjectInterest;

DELIMITER //

CREATE PROCEDURE RemoveUserSubjectInterest(
    IN p_user_id CHAR(36),
    IN p_subject_id CHAR(36),
    IN p_type VARCHAR(20)
)
BEGIN
    -- Validate Type
    IF p_type NOT IN ('Sought', 'Offered') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Type must be Sought or Offered';
    END IF;

    DELETE FROM User_Subject
    WHERE UserID = UUID_TO_BIN(p_user_id)
      AND SubjectID = UUID_TO_BIN(p_subject_id)
      AND UserType = p_type;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No matching user-subject interest was found';
    END IF;
END //

DELIMITER ;
