-- Procedure to update goal description
DELIMITER $$
CREATE PROCEDURE update_goal_description(
IN p_goal_id BINARY(16),
IN p_g_description TEXT
)
BEGIN
DECLARE goal_count INT;
SELECT COUNT(*)
INTO goal_count
FROM Goal
WHERE GoalID = p_goal_id;

IF goal_count = 0 THEN
	SELECT 'Goal does not exist' AS message;
ELSE
UPDATE Goal
SET Description = p_g_description
WHERE GoalID = p_goal_id;
SELECT 'Goal description successfully updated.' AS message;

	END IF;
END$$
DELIMITER ;
