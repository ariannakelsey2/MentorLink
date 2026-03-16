CREATE TABLE subject (
    subject_id BINARY(16) PRIMARY KEY default (UUID_TO_BIN(UUID())),
    subject_name VARCHAR(64) NOT NULL UNIQUE,

)