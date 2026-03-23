-- Arianna Kelsey

USE MentorLink;

DROP PROCEDURE IF EXISTS AddUserSubjectInterest;

DELIMITER //

CREATE PROCEDURE AddUserSubjectInterest(
    IN p_user_id CHAR(36),
    IN p_subject_id CHAR(36),
    IN p_type VARCHAR(20)
)
BEGIN
    DECLARE v_user_count INT DEFAULT 0;
    DECLARE v_subject_count INT DEFAULT 0;
    DECLARE v_existing_count INT DEFAULT 0;

    -- Validate Type
    IF p_type NOT IN ('Sought', 'Offered') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Type must be Sought or Offered';
    END IF;

    -- Check USER exists
    SELECT COUNT(*)
    INTO v_user_count
    FROM User
    WHERE UserID = UUID_TO_BIN(p_user_id);

    IF v_user_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User does not exist';
    END IF;

    -- Check SUBJECT exists
    SELECT COUNT(*)
    INTO v_subject_count
    FROM Subject
    WHERE SubjectID = UUID_TO_BIN(p_subject_id);

    IF v_subject_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Subject does not exist';
    END IF;

    -- Prevent duplicate USER-SUBJECT row
    SELECT COUNT(*)
    INTO v_existing_count
    FROM User_Subject
    WHERE UserID = UUID_TO_BIN(p_user_id)
      AND SubjectID = UUID_TO_BIN(p_subject_id)
      AND UserType = p_type;

    IF v_existing_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'That user-subject interest already exists';
    END IF;

    INSERT INTO User_Subject (UserID, SubjectID, UserType)
    VALUES (UUID_TO_BIN(p_user_id), UUID_TO_BIN(p_subject_id), p_type);
END //

DELIMITER ;
