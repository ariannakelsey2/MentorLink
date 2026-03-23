-- Procedure to create a new user
Delimiter $$


CREATE PROCEDURE create_user(
	-- Declare parameters
    IN p_FirstName VARCHAR(32),
	IN p_LastName VARCHAR(32),
    IN p_Email VARCHAR(255),
    IN p_PhoneNumber VARCHAR(20),
    IN p_Password VARCHAR(128)
)
BEGIN
	-- Create new user
    INSERT INTO User(UserID, FirstName, LastName, Email, PhoneNumber, Password)
    VALUES(UUID_TO_BIN(UUID()),p_FirstName, p_LastName, p_Email, p_PhoneNumber, p_Password);
    
END $$

DELIMITER ;
