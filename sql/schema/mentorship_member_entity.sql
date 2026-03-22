-- Added: For easy code rebuilds
USE MentorLink;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Mentorship_Member;

SET FOREIGN_KEY_CHECKS = 1;

-- Create MentorshipMentor table
CREATE TABLE MentorshipMember(
  MentorshipID BINARY(16) NOT NULL,
  UserID BINARY(16) NOT NULL,
  -- Renamed to RoleID
  RoleID ENUM('Mentor', 'Mentee') NOT NULL,

  -- Designate primary key
  -- Added: Used constraint style for primary key, and foreign key
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
  
-- Fixed: Added unique constraint on (MentorshipID, RoleID).  Enforces at most one Mentor and one Mentee per mentorship.
CONSTRAINT uq_mentorshipmember_role
      UNIQUE (MentorshipID, RoleID)
  );

-- Check that a user has the role of mentor or mentee
ALTER TABLE MentorshipMember
ADD CONSTRAINT check_role CHECK (RoleID IN('Mentor', 'Mentee'));

-- Fixed: Added index on UserID. Helps queries that find all mentorships for a user
CREATE INDEX idx_mentorshipmember_user
    ON MentorshipMember(UserID);

CREATE INDEX idx_mentorshipmember_role
    ON MentorshipMember(RoleID);

