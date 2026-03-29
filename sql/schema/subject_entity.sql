USE MentorLink;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Subject;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Subject (
    -- Fixed: PK defined twice
    SubjectID BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
    SubjectName VARCHAR(64) NOT NULL UNIQUE,
    Department VARCHAR(64),

    -- Fixed: Added constraints to enforce data integrity
    CONSTRAINT pk_subject
        PRIMARY KEY (SubjectID)
    
);
