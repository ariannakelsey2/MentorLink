-- Procedure to add a session to a mentorship
DELIMITER $$
CREATE PROCEDURE schedule_session(
IN p_session_id BINARY(16),
IN p_mentorship_id BINARY(16),
IN p_timestamp TIMESTAMP,
IN p_instruc_type VARCHAR(20),
IN p_location TINYTEXT,
IN p_status VARCHAR(20)
)
BEGIN
DECLARE mentorship_count INT;
SELECT COUNT(*)
INTO mentorship_count
FROM Mentorship
WHERE MentorshipID = p_mentorship_id;

IF mentorship_count = 0 THEN
	SELECT 'Mentorship does not exist.' AS message;
    
ELSE 
INSERT INTO Session(
	SessionID,
	MentorshipID,
	Timestamp,
	InstructionType,
	Location,
	Status
)
Values(
	p_session_id,
    p_mentorship_id,
    p_timestamp,
    p_instruc_type,
    p_location,
    p_status
);
SELECT 'Session successfully added.' AS messsage;
	END IF;
END$$
DELIMITER ;
