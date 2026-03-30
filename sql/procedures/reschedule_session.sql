-- Arianna Kelsey

USE MentorLink;

DROP PROCEDURE IF EXISTS RescheduleSession;

DELIMITER //

CREATE PROCEDURE RescheduleSession(
    IN p_session_id CHAR(36),
    IN p_new_timestamp DATETIME,
    IN p_new_instruction_type VARCHAR(20),
    IN p_new_location TINYTEXT
)
BEGIN
    DECLARE v_session_count INT DEFAULT 0;
    DECLARE v_current_status VARCHAR(20);
    DECLARE v_mentorship_id BINARY(16);
    DECLARE v_conflict_count INT DEFAULT 0;

    -- Check SESSION exists and get current values
    SELECT COUNT(*), MAX(Status), MAX(MentorshipID)
    INTO v_session_count, v_current_status, v_mentorship_id
    FROM Session
    WHERE SessionID = UUID_TO_BIN(p_session_id);

    IF v_session_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Session does not exist';
    END IF;

    -- Only Scheduled sessions can be rescheduled
    IF v_current_status <> 'Scheduled' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Only sessions with Status = Scheduled can be rescheduled';
    END IF;

    -- Validate InstructionType
    IF p_new_instruction_type NOT IN ('Virtual', 'In-Person') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'InstructionType must be Virtual or In-Person';
    END IF;

    -- Prevent collision with another scheduled session for same mentorship
    SELECT COUNT(*)
    INTO v_conflict_count
    FROM Session
    WHERE MentorshipID = v_mentorship_id
      AND Timestamp = p_new_timestamp
      AND Status = 'Scheduled'
      AND SessionID <> UUID_TO_BIN(p_session_id);

    IF v_conflict_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Another scheduled session already exists for this mentorship at that time';
    END IF;

    UPDATE Session
    SET Timestamp = p_new_timestamp,
        InstructionType = p_new_instruction_type,
        Location = p_new_location,
        Status = 'Scheduled'
    WHERE SessionID = UUID_TO_BIN(p_session_id);
END //

DELIMITER ;
