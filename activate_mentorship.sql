-- Procedure for a mentee to designate one mentorship as active. Then, deletes all potential mentorships that were not chosen from the Mentorship table.

DELIMITER $$

CREATE PROCEDURE activate_mentorship(p_MentorshipID BINARY(16))
BEGIN
    
    -- Create variable to store the mentee
    DECLARE v_menteeID BINARY(16);

    -- Create variable to store the mentorship subject
    DECLARE v_subjectID BINARY(16);


    -- Get mentee and subject 
    SELECT m.SubjectID, mm.UserID
    INTO v_subjectID, v_menteeID
    FROM Mentorship m
    JOIN MentorshipMember mm
        ON m.MentorshipID = mm.MentorshipID
    WHERE m.MentorshipID = p_MentorshipID
      AND mm.role_value = 'Mentee';

	-- Activate selected mentorship
    UPDATE Mentorship
    SET Status = 'Active'
    WHERE MentorshipID = p_MentorshipID;


	-- Delete potential mentorships that were not selected
    DELETE m
    FROM Mentorship m
    JOIN MentorshipMember mm
        ON m.MentorshipID = mm.MentorshipID
    WHERE m.SubjectID = v_subjectID
      AND m.Status = 'Potential'
      AND mm.role_value = 'Mentee'
      AND mm.UserID = v_menteeID
      -- Do NOT delete the one that was just activated
      AND m.MentorshipID != p_MentorshipID;

END $$

DELIMITER ;