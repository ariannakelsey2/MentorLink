CREATE TABLE User(
	user_ID BINARY(16) NOT NULL PRIMARY KEY
        DEFAULT (UUID_TO_BIN(UUID())),
	first_name VARCHAR(32) NOT NULL,
    last_name VARCHAR(32) NOT NULL,
    email VARCHAR(255) UNIQUE  NOT NULL,
    phone_number VARCHAR(20)
);

CREATE TABLE User_Subject(
	user_ID BINARY(16),
	subject_ID BINARY(16),
	user_type ENUM('Sought', 'Offered') NOT NULL,
    
PRIMARY KEY(user_ID, subject_ID, user_type),

	CONSTRAINT fk_user_ID
		FOREIGN KEY (user_ID)
		REFERENCES User(user_ID),
	CONSTRAINT fk_subject_ID
        FOREIGN KEY (subject_ID)
        REFERENCES Subject(subject_ID)
);
