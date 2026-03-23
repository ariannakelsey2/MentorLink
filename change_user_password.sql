	-- Procedure to update user password
DELIMITER $$

CREATE PROCEDURE change_user_password(
	-- Declare parameters
    IN p_UserID BINARY(16),
    IN p_NewPassword VARCHAR(128)
)
BEGIN
    -- Updates the user's password
    UPDATE User
    SET Password = p_NewPassword
    WHERE UserID = p_UserID;
END $$
DELIMITER ;
