-- MentorLink Database Schema
-- Tables: Goal, Rating
-- Author: Arianna Kelsey
-- Description:
--     Creates Goal and Rating tables with constraints
--     and indexes for MentorLink


-- 1. Create Database

CREATE DATABASE IF NOT EXISTS MentorLink;

-- Select the database so tables are created inside it
USE MentorLink;

-- GOAL TABLE


CREATE TABLE IF NOT EXISTS Goal (

    GoalID BINARY(16) NOT NULL,
    MentorshipID BINARY(16) NOT NULL,
    Description TEXT NOT NULL,
    Status ENUM('Set','Achieved') NOT NULL,

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


-- RATING TABLE

CREATE TABLE IF NOT EXISTS Rating (

    RatingID BINARY(16) NOT NULL,
    MentorshipID BINARY(16) NOT NULL,
    RaterUserID BINARY(16) NOT NULL,
    RatedUserID BINARY(16) NOT NULL,
    RatingValue ENUM('poor','neutral','good') NOT NULL,

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

    -- Prevent user rating themselves
    CONSTRAINT chk_no_self_rating
        CHECK (RaterUserID <> RatedUserID),
        
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
