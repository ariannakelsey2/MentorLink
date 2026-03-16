-- Create MentorshipMentor table
CREATE TABLE MentorshipMember(
  MentorshipID BINARY(16) NOT NULL,
  UserID BINARY(16) NOT NULL,
  ROLE ENUM('Mentor', 'Mentee') NOT NULL,

  -- Designate primary key
  PRIMARY KEY(MentorshipID, UserID),

  -- Designate foreign key
  FOREIGN KEY (MentorshipID) REFERENCES Mentorship(MentorshipID),
  FOREIGN KEY (UserID) REFERENCES User(UserID)

  ON DELETE CASCADE
  ON UPDATE CASCADE
  );

-- Check that a user has the role of mentor or mentee
ALTER TABLE MentorshipMember
ADD CONSTRAINT check_role CHECK (ROLE IN('Mentor', 'Mentee'));
