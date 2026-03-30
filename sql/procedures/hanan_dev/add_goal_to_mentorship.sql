-- Procedure add goal to Mentorship 
DELIMITER $$ 
CREATE PROCEDURE Add_Goal_To_Mentorship (
	-- Parameters 
IN p_goal_id BINARY(16),
IN p_mentorship_id BINARY(16),
IN p_description TEXT,
IN p_status VARCHAR(20)
)
BEGIN 
	-- variable to store how many mentorships match the ID
DECLARE Mentorship_count INT;
-- Check if mentorship exists
SELECT COUNT(*)
INTO Mentorship_count
FROM Mentorship
WHERE MentorshipID = p_mentorship_id;
-- If no mentorship exists
IF Mentorship_count = 0 THEN
	-- Return this message
	SELECT 'Mentorship does not exist. Goal not added.' AS message;
ELSE
	-- Insert new goal into Goal table
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
	-- Return message for success
	SELECT 'Goal added to Mentorship.' AS message;
	END IF;
END$$
DELIMITER ;
