-- Create MentorshipMentor table
CREATE TABLE MentorshipMember(
MentorshipID BINARY(16) NOT NULL,
UserID BINARY(16) NOT NULL,
ROLE ENUM('Mentor', 'Mentee') NOT NULL,

PRIMARY KEY(MentorshipID, UserID),

FOREIGN KEY (MentorshipID) REFERENCES Mentorship(MentorshipID),
FOREIGN KEY (UserID) REFERENCES User(UserID));

-- Check that a user has the role of mentor or mentee
ALTER TABLE MentorshipMember
ADD CONSTRAINT check_role CHECK (ROLE IN('Mentor', 'Mentee'));