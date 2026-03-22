-- Procedure to mark goal achieved 
DELIMITER $$ 
CREATE PROCEDURE mark_goal_achieved (
IN p_goal_id BINARY(16)
)
BEGIN
DECLARE goal_count INT;
SELECT COUNT(*)
INTO goal_count 
FROM Goal
WHERE GoalID = p_goal_id;
-- note: talk to team about goal alr achieved?
IF goal_count = 0 THEN
	SELECT 'Goal does not exist.' AS message;
ELSE
	UPDATE Goal
	SET Status = 'Achieved'
	WHERE GoalID = p_goal_id;
	SELECT 'Goal has been achieved.' AS message;

	END IF;
END$$
DELIMITER ;