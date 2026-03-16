-- Create mentorship table
CREATE TABLE Mentorship(
  MentorshipID BINARY(16) PRIMARY KEY,
  SubjectID BINARY(16) NOT NULL,
  FOREIGN KEY (SubjectID) REFERENCES Subject(SubjectID)

  ON DELETE CASCADE
  ON UPDATE CASCADE
);

-- Create index for SubjectID in mentorship table
CREATE INDEX idx_Mentorship_SubjectID
ON Mentorship(SubjectID);
