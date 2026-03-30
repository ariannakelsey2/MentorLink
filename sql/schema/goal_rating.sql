-- MentorLink Database Schema
-- Tables: Goal, Rating
-- Author: Arianna Kelsey
-- Description:
--     Creates Goal and Rating tables with constraints
--     and indexes for MentorLink
-- Added: For easy code rebuilds
Use MentorLink;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Goal;
DROP TABLE IF EXISTS Rating;

SET FOREIGN_KEY_CHECKS = 1;


-- GOAL TABLE

CREATE TABLE Goal (

    GoalID BINARY(16) NOT NULL
		-- Added: Forgot UUID 
		DEFAULT (UUID_TO_BIN(UUID())),
    MentorshipID BINARY(16) NOT NULL,
    Description TEXT NOT NULL,
	-- Added: Set default to 'Set'
    Status ENUM('Set','Achieved') NOT NULL DEFAULT 'Set',

    -- Primary Key
    CONSTRAINT pk_goal
        PRIMARY KEY (GoalID),

    -- Foreign Key: Goal belongs to a mentorship
    CONSTRAINT fk_goal_mentorship
        FOREIGN KEY (MentorshipID)
        REFERENCES Mentorship(MentorshipID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Index to quickly find all goals in a mentorship
CREATE INDEX idx_goal_mentorship
    ON Goal(MentorshipID);

-- Index to quickly filter goals by status
CREATE INDEX idx_goal_status
    ON Goal(Status);

-- Added: To help with procedure 'CountAchievedGoals'
CREATE INDEX idx_goal_mentorship_status
    ON Goal(MentorshipID, Status);

-- RATING TABLE

CREATE TABLE Rating (

    RatingID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
    MentorshipID BINARY(16) NOT NULL,
    RaterUserID BINARY(16) NOT NULL,
    RatedUserID BINARY(16) NOT NULL,
    RatingValue ENUM('Poor','Neutral','Good') NOT NULL,
	-- Fixed: Added Date
	-- However, will need to update Data Dictionary and ER diagram
	RatingDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Primary Key
    CONSTRAINT pk_rating
        PRIMARY KEY (RatingID),

    -- Foreign Key: Rating belongs to mentorship
    CONSTRAINT fk_rating_mentorship
        FOREIGN KEY (MentorshipID)
        REFERENCES Mentorship(MentorshipID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Foreign Key: who gave the rating
    CONSTRAINT fk_rating_rater
        FOREIGN KEY (RaterUserID)
        REFERENCES User(UserID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    -- Foreign Key: who received the rating
    CONSTRAINT fk_rating_rated
        FOREIGN KEY (RatedUserID)
        REFERENCES User(UserID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
        
	-- Prevent duplicate ratings in the same mentorship
    CONSTRAINT uq_rating_once
        UNIQUE (MentorshipID, RaterUserID, RatedUserID)
);

-- Index to find ratings for a mentorship
CREATE INDEX idx_rating_mentorship
    ON Rating(MentorshipID);

-- Index to find ratings given by a user
CREATE INDEX idx_rating_rater
    ON Rating(RaterUserID);

-- Index to find ratings received by a user
CREATE INDEX idx_rating_rated
    ON Rating(RatedUserID);

-- Index to filter by rating value
CREATE INDEX idx_rating_value
    ON Rating(RatingValue);

-- Index by rating date
CREATE INDEX idx_rating_date
    ON Rating(RatingDate);
