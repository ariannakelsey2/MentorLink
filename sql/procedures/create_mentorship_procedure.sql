-- Procedure to create a new mentorship pairing
-- Loops through each mentee in the user_subject table and tries to pair each one with a mentor. Then creates a record in the mentorship table and the mentorshipmember table


DELIMITER $$

CREATE PROCEDURE create_mentorship()
BEGIN
	-- Declare variables 
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_menteeID BINARY(16);
    DECLARE v_subjectID BINARY(16);
    DECLARE v_mentorID BINARY(16);
    DECLARE v_mentorshipID BINARY(16);
    
    -- Create cursor for mentees
    DECLARE cur CURSOR FOR
    SELECT UserID, SubjectID
    FROM User_Subject
    WHERE UserType = 'Sought';
    
    -- Handle the loop ending
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    
    -- Open cusor
    OPEN cur;
    
    -- Loop through all mentees
    read_loop: LOOP
		FETCH cur INTO v_menteeID, v_subjectID;
        
	IF v_done = 1 THEN
		LEAVE read_loop;
	END IF;
    
    -- Find a mentor match 				** how should we handle multiple matches? this just gets the first match
    SELECT UserID INTO v_mentorID
    FROM User_Subject
    WHERE SubjectID = v_subjectID
		AND UserType = 'Offered'
		AND UserID != v_menteeID
    LIMIT 1;
    
    -- Continue if a matched mentor exists
    IF v_mentorID IS NOT NULL THEN
    
    -- Prevent duplicate mentorships
	IF NOT EXISTS (
		SELECT 1
		FROM Mentorship m
		JOIN MentorshipMember mm1 
			ON m.MentorshipID = mm1.MentorshipID
		JOIN MentorshipMember mm2 
			ON m.MentorshipID = mm2.MentorshipID
		WHERE m.SubjectID = v_subjectID
			AND mm1.UserID = v_menteeID
			AND mm1.RoleValue = 'Mentee'
			AND mm2.UserID = v_mentorID
			AND mm2.RoleValue = 'Mentor') 
	THEN

	-- Generate mentorshipID
    SET v_mentorshipID = UUID_TO_BIN(UUID());
    
    -- Create new mentorship record
    INSERT INTO Mentorship(MentorshipID, SubjectID, Status)
    VALUES (v_mentorshipID, v_subjectID, 'Active');
    
    -- Add mentee to MentorshipMember table
	INSERT INTO MentorshipMember (MentorshipID, UserID, RoleValue)
	VALUES (v_mentorshipID, v_menteeID, 'Mentee');
    
    -- Add mentor to MentorshipMember table
	INSERT INTO MentorshipMember (MentorshipID, UserID, RoleValue)
    VALUES (v_mentorshipID, v_mentorID, 'Mentor');
    
	END IF;

END IF;

    -- Reset mentor variable
    SET v_mentorID = NULL;
    
-- End loop and close cursor
END LOOP;
CLOSE cur;

END $$

DELIMITER ;
