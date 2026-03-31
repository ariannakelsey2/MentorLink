-- Procedure to update goal description
DELIMITER $$
CREATE PROCEDURE update_goal_description(
	-- Input parameters
IN p_goal_id BINARY(16),
IN p_g_description TEXT
)
BEGIN
	-- Variable to store how many goals match ID
DECLARE goal_count INT;
-- Check if goal exists
SELECT COUNT(*)
INTO goal_count
FROM Goal
WHERE GoalID = p_goal_id;
-- If no goal exists
IF goal_count = 0 THEN
	-- Return failure message
	SELECT 'Goal does not exist' AS message;
ELSE
	-- Update the goals Description
UPDATE Goal
SET Description = p_g_description
WHERE GoalID = p_goal_id;
-- Return success message
SELECT 'Goal description successfully updated.' AS message;

	END IF;
END$$
DELIMITER ;
