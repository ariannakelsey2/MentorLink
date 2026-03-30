-- Added: For easy code rebuilds
USE MentorLink;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Mentorship;

SET FOREIGN_KEY_CHECKS = 1;
-- Create mentorship table
CREATE TABLE Mentorship(
  MentorshipID BINARY(16) NOT NULL
    -- Added: To default UUID for Mentorship
    DEFAULT (UUID_TO_BIN(UUID())),
  SubjectID BINARY(16) NOT NULL,
  -- Added: Supports Procedure EndMentorship without an actual deletion, allows for archived setting
  -- However, will need to update ER Diagram and Data Dictionary 
  Status ENUM('Potential','Active','Ended') NOT NULL DEFAULT 'Potential',

  CONSTRAINT pk_mentorship
    PRIMARY KEY (MentorshipID),
  -- Style Fix: Nothing wrong with putting primary key next to the declaration, but
  -- for consistency within the system and readability, I used the constraint style to define the primary and foreign keys
  CONSTRAINT fk_mentorship_subject
    FOREIGN KEY (SubjectID)
    REFERENCES Subject(SubjectID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- Create index for SubjectID in mentorship table
CREATE INDEX idx_Mentorship_SubjectID
ON Mentorship(SubjectID);

-- Added: Created index to help with the procedure function EndMentorship
CREATE INDEX idx_Mentorship_Status
    ON Mentorship(Status);

