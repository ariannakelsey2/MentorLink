CREATE TABLE Subject (
    -- Fixed: PK defined twice
    SubjectID BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
    SubjectName VARCHAR(64) NOT NULL UNIQUE,

    --Fixed: Added constraints to enforce data integrity
    CONSTRAINT pk_subject
        PRIMARY KEY (SubjectID),
    
   -- Jordie: MySQL gives me a warning that this constraint is redundant because we already specified that SubjectName is unique in line 4
    CONSTRAINT uq_subject_name
        UNIQUE (SubjectName)

);
