-- Procedure add goal to Mentorship 
DELIMITER $$ 
CREATE PROCEDURE Add_Goal_To_Mentorship (
IN p_goal_id BINARY(16),
IN p_mentorship_id BINARY(16),
IN p_description TEXT,
IN p_status VARCHAR(20)
)
BEGIN 
DECLARE Mentorship_count INT;
SELECT COUNT(*)
INTO Mentorship_count
FROM Mentorship
WHERE MentorshipID = p_mentorship_id;
IF Mentorship_count = 0 THEN
	SELECT 'Mentorship does not exist. Goal not added.' AS message;
ELSE
INSERT INTO Goal(
	GoalID,
	MentorshipID,
	Description,
	Status
)
VALUES (
	p_goal_id,
	p_mentorship_id,
	p_description,
	p_status
);
	SELECT 'Goal added to Mentorship.' AS message;
	END IF;
END$$
DELIMITER ;
