-- Procedure to mark goal achieved 
DELIMITER $$ 
CREATE PROCEDURE mark_goal_achieved (
	-- Parameter
IN p_goal_id BINARY(16)
)
BEGIN
	-- Variable to store how many goals match ID
DECLARE goal_count INT;
-- Check if goal exists in Goal table
SELECT COUNT(*)
INTO goal_count 
FROM Goal
WHERE GoalID = p_goal_id;
-- If no goal exists 
IF goal_count = 0 THEN
	-- Return failure message
	SELECT 'Goal does not exist.' AS message;
ELSE
	-- Update the goals status to 'Achieved'
	UPDATE Goal
	SET Status = 'Achieved'
	WHERE GoalID = p_goal_id;
	-- Return success message
	SELECT 'Goal has been achieved.' AS message;

	END IF;
END$$
DELIMITER ;
