-- Procedure to update user profile information
DELIMITER $$

CREATE PROCEDURE update_user_profile(
	-- Declare parameters
    IN p_UserID BINARY(16),
    IN p_FirstName VARCHAR(32),
	IN p_LastName VARCHAR(32),
    IN p_Email VARCHAR(255),
    IN p_PhoneNumber VARCHAR(20)
)
BEGIN
    -- Update user information
    UPDATE User
    SET FirstName = p_FirstName,
		LastName = p_LastName,
		Email = p_Email,
        PhoneNumber = p_PhoneNumber
    WHERE UserID = p_UserID;
END $$
DELIMITER ;

