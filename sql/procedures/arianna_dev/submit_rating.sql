USE MentorLink;

DROP PROCEDURE IF EXISTS SubmitRating;
DELIMITER $$

CREATE PROCEDURE SubmitRating (
    IN p_MentorshipID CHAR(36),
    IN p_RaterUserID CHAR(36),
    IN p_RatedUserID CHAR(36),
    IN p_RatingValue ENUM('Poor','Neutral','Good')
)
BEGIN
    -- Convert UUID strings to BINARY(16)
    DECLARE v_MentorshipID BINARY(16);
    DECLARE v_RaterUserID BINARY(16);
    DECLARE v_RatedUserID BINARY(16);

    SET v_MentorshipID = UUID_TO_BIN(p_MentorshipID);
    SET v_RaterUserID = UUID_TO_BIN(p_RaterUserID);
    SET v_RatedUserID = UUID_TO_BIN(p_RatedUserID);

    -- Prevent self-rating
    IF v_RaterUserID = v_RatedUserID THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User cannot rate themselves';
    END IF;

    -- Enforce mentee -> mentor rule first
    IF NOT EXISTS (
        SELECT 1
        FROM MentorshipMember m1
        JOIN MentorshipMember m2
          ON m1.MentorshipID = m2.MentorshipID
        WHERE m1.MentorshipID = v_MentorshipID
          AND m1.UserID = v_RaterUserID
          AND m1.RoleID = 'Mentee'
          AND m2.UserID = v_RatedUserID
          AND m2.RoleID = 'Mentor'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Only mentees can rate mentors';
    END IF;

    -- Prevent duplicate rating
    IF EXISTS (
        SELECT 1
        FROM Rating
        WHERE MentorshipID = v_MentorshipID
          AND RaterUserID = v_RaterUserID
          AND RatedUserID = v_RatedUserID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rating already exists for this mentorship pair';
    END IF;

    -- Insert rating
    INSERT INTO Rating (
        RatingID,
        MentorshipID,
        RaterUserID,
        RatedUserID,
        RatingValue,
        RatingDate
    )
    VALUES (
        UUID_TO_BIN(UUID()),
        v_MentorshipID,
        v_RaterUserID,
        v_RatedUserID,
        p_RatingValue,
        CURRENT_TIMESTAMP
    );
END $$

DELIMITER ;
