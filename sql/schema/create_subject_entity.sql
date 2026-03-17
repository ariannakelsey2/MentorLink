CREATE TABLE Subject (
    SubjectID BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    SubjectName VARCHAR(64) NOT NULL UNIQUE,

    --Fixed: Added constraints to enforce data integrity
    CONSTRAINT pk_subject
        PRIMARY KEY (SubjectID),
    
    CONSTRAINT uq_subject_name
        UNIQUE (SubjectName)

);
