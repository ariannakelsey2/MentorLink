-- Create MentorshipMentor table
CREATE TABLE MentorshipMember(
  MentorshipID BINARY(16) NOT NULL,
  UserID BINARY(16) NOT NULL,
  ROLE ENUM('Mentor', 'Mentee') NOT NULL,

  -- Designate primary key
  --Added: Used constraint style for primary key, and foreign key
  CONSTRAINT pk_mentorshipmember
      PRIMARY KEY(MentorshipID, UserID),

 CONSTRAINT fk_mentorshipmember_mentorship
      FOREIGN KEY (MentorshipID)
      REFERENCES Mentorship(MentorshipID)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

CONSTRAINT fk_mentorshipmember_user
      FOREIGN KEY (UserID)
      REFERENCES User(UserID)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
  
-- Fixed: Added unique constraint on (MentorshipID, Role).  Enforces at most one Mentor and one Mentee per mentorship.
CONSTRAINT uq_mentorshipmember_role
      UNIQUE (MentorshipID, Role)
  );

-- Check that a user has the role of mentor or mentee
ALTER TABLE MentorshipMember
ADD CONSTRAINT check_role CHECK (ROLE IN('Mentor', 'Mentee'));

--Fixed: Added index on UserID. Helps queries that find all mentorships for a user
CREATE INDEX idx_mentorshipmember_user
    ON MentorshipMember(UserID);

CREATE INDEX idx_mentorshipmember_role
    ON MentorshipMember(Role);
