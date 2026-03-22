USE MentorLink;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Session;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Session (
    SessionID BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
    -- Added Mentorship ID
    MentorshipID BINARY(16) NOT NULL,
    Timestamp TIMESTAMP NOT NULL,
    InstructionType ENUM('Virtual', 'In-Person') NOT NULL,
    Location TINYTEXT NOT NULL,
    -- Fixed: Added session status column. Supports CancelSession and RescheduleSession 
    -- However, will need to update ER Diagram and Data Dictionary 
    Status ENUM('Scheduled', 'Cancelled', 'Completed') NOT NULL DEFAULT 'Scheduled',

    -- Added constraint style to keep with consistency and readability
    CONSTRAINT pk_session
        PRIMARY KEY (SessionID),

    CONSTRAINT fk_session_mentorship
        FOREIGN KEY (MentorshipID)
        REFERENCES Mentorship(MentorshipID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Added: To help with procedures
CREATE INDEX idx_session_mentorship
    ON Session(MentorshipID);

CREATE INDEX idx_session_timestamp
    ON Session(Timestamp);

CREATE INDEX idx_session_mentorship_timestamp
    ON Session(MentorshipID, Timestamp);

CREATE INDEX idx_session_status
    ON Session(Status);
