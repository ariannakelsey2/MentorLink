-- Procedure to create a new mentorship pairing
-- Self joins the User_Subject table on SubjectID, then inserts mentorships into the Mentorship table and inserts users into the MentorshipMember table

DELIMITER $$

CREATE PROCEDURE create_mentorship()
BEGIN
	-- Create table with all valid matches
    CREATE TEMPORARY TABLE tmp_matches AS
    SELECT
		UUID_TO_BIN(UUID()) AS MentorshipID,
		mnte.UserID AS MenteeID,
		mntr.UserID AS MentorID,
		mnte.SubjectID
	FROM User_Subject mnte
    JOIN User_Subject mntr
		ON mnte.SubjectID = mntr.SubjectID
        AND mnte.UserType = 'Sought'
        AND mntr.UserType = 'Offered'
        AND mnte.UserID != mntr.UserID
        
       -- Prevent duplicates
    WHERE NOT EXISTS (
        SELECT 1
        FROM Mentorship m
        JOIN MentorshipMember mm1 
            ON m.MentorshipID = mm1.MentorshipID
        JOIN MentorshipMember mm2 
            ON m.MentorshipID = mm2.MentorshipID
        WHERE m.SubjectID = mnte.SubjectID
          AND mm1.UserID = mnte.UserID
          AND mm1.role_value = 'Mentee'
          AND mm2.UserID = mntr.UserID
          AND mm2.role_value = 'Mentor'
    );
    
    
  -- Insert into Mentorship table
  INSERT INTO mentorship(MentorshipID, SubjectID, Status)
  SELECT MentorshipID, SubjectID, 'Potential'
  FROM tmp_matches;
  
  -- Insert mentee records into MentorshipMember 
  INSERT INTO MentorshipMember(MentorshipID, UserID, role_value)
  SELECT MentorshipID, MenteeID, 'Mentee'
  FROM tmp_matches;
  

  -- Insert mentor records into MentorshipMember 
  INSERT INTO MentorshipMember(MentorshipID, UserID, role_value)
  SELECT MentorshipID, MentorID, 'Mentor'
  FROM tmp_matches;
  
  -- Drop temporary table
  DROP TEMPORARY TABLE tmp_matches;
  
  END $$
  
  DELIMITER ;
  
