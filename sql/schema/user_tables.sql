CREATE TABLE User(
	UserID BINARY(16) NOT NULL
        DEFAULT (UUID_TO_BIN(UUID())),
	FirstName VARCHAR(32) NOT NULL,
    LastName VARCHAR(32) NOT NULL,
    Email VARCHAR(255) UNIQUE  NOT NULL,
    PhoneNumber VARCHAR(20),
	-- Fixed: Added Password column
	Password VARCHAR(128) NOT NULL,

	--Added: constraint style for consistency and readability
	CONSTRAINT pk_user
        PRIMARY KEY (UserID),

    CONSTRAINT uq_user_email
        UNIQUE (Email)
);

CREATE TABLE User_Subject(
	UserID BINARY(16) NOT NULL,
	SubjectID BINARY(16) NOT NULL,
	UserType ENUM('Sought', 'Offered') NOT NULL,
    
PRIMARY KEY(UserID, SubjectID, UserType),

	CONSTRAINT fk_user_ID
		FOREIGN KEY (UserID)
		REFERENCES User(UserID)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT fk_subject_ID
        FOREIGN KEY (SubjectID)
        REFERENCES Subject(SubjectID)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

-- Added: Index to help find all users for a subject and type
CREATE INDEX idx_usersubject_subject_type
    ON UserSubject(SubjectID, Type);
