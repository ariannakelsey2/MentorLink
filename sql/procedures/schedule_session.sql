-- Arianna Kelsey

USE MentorLink;

DROP PROCEDURE IF EXISTS ScheduleSession;

DELIMITER //

CREATE PROCEDURE ScheduleSession(
    IN p_mentorship_id CHAR(36),
    IN p_timestamp DATETIME,
    IN p_instruction_type VARCHAR(20),
    IN p_location TINYTEXT
)
BEGIN
    DECLARE v_mentorship_count INT DEFAULT 0;
    DECLARE v_conflict_count INT DEFAULT 0;

    -- Check MENTORSHIP exists
    SELECT COUNT(*)
    INTO v_mentorship_count
    FROM Mentorship
    WHERE MentorshipID = UUID_TO_BIN(p_mentorship_id);

    IF v_mentorship_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mentorship does not exist';
    END IF;

    -- Validate InstructionType
    IF p_instruction_type NOT IN ('Virtual', 'In-Person') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'InstructionType must be Virtual or In-Person';
    END IF;

    -- Prevent duplicate scheduled session at same time for same mentorship
    SELECT COUNT(*)
    INTO v_conflict_count
    FROM Session
    WHERE MentorshipID = UUID_TO_BIN(p_mentorship_id)
      AND Timestamp = p_timestamp
      AND Status = 'Scheduled';

    IF v_conflict_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A scheduled session already exists for this mentorship at that time';
    END IF;

    INSERT INTO Session (MentorshipID, Timestamp, InstructionType, Location, Status)
    VALUES (
        UUID_TO_BIN(p_mentorship_id),
        p_timestamp,
        p_instruction_type,
        p_location,
        'Scheduled'
    );
END //

DELIMITER ;
