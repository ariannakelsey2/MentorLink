CREATE TABLE session (
    session_id BINARY(16) PRIMARY KEY default (UUID_TO_BIN(UUID())),
    timestamp TIMESTAMP NOT NULL,
    instruction_type ENUM('VIRTUAL', 'IN-PERSON') NOT NULL,
    location TINYTEXT NOT NULL,

    FOREIGN KEY (mentorship_id) REFERENCES mentorship(mentorship_id) ON DELETE CASCADE
)