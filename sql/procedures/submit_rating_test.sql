USE MentorLink;

DROP PROCEDURE IF EXISTS RunSubmitRatingTests;
DELIMITER $$

CREATE PROCEDURE RunSubmitRatingTests()
BEGIN
    DECLARE v_test_name VARCHAR(100);
    DECLARE v_error_message TEXT;
    DECLARE v_row_count INT DEFAULT 0;

    -- =========================================
    -- STEP 1: Pick one mentorship with exactly
    -- one mentee and one mentor
    -- =========================================
    SELECT 
        BIN_TO_UUID(mm.MentorshipID),
        BIN_TO_UUID(MAX(CASE WHEN mm.RoleID = 'Mentee' THEN mm.UserID END)),
        BIN_TO_UUID(MAX(CASE WHEN mm.RoleID = 'Mentor' THEN mm.UserID END))
    INTO
        @mentorship_id,
        @mentee_user_id,
        @mentor_user_id
    FROM MentorshipMember mm
    GROUP BY mm.MentorshipID
    HAVING COUNT(CASE WHEN mm.RoleID = 'Mentee' THEN 1 END) = 1
       AND COUNT(CASE WHEN mm.RoleID = 'Mentor' THEN 1 END) = 1
    LIMIT 1;

    SELECT 'SETUP VALUES' AS Section,
           @mentorship_id AS MentorshipID,
           @mentee_user_id AS MenteeUserID,
           @mentor_user_id AS MentorUserID;

    -- If no valid mentorship found, stop
    IF @mentorship_id IS NULL OR @mentee_user_id IS NULL OR @mentor_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No valid mentorship with exactly one mentor and one mentee was found.';
    END IF;

    -- =========================================
    -- STEP 2: Clean up old test data
    -- =========================================
    DELETE FROM Rating
    WHERE MentorshipID = UUID_TO_BIN(@mentorship_id)
      AND (
            (RaterUserID = UUID_TO_BIN(@mentee_user_id) AND RatedUserID = UUID_TO_BIN(@mentor_user_id))
         OR (RaterUserID = UUID_TO_BIN(@mentor_user_id) AND RatedUserID = UUID_TO_BIN(@mentee_user_id))
         OR (RaterUserID = UUID_TO_BIN(@mentee_user_id) AND RatedUserID = UUID_TO_BIN(@mentee_user_id))
      );

    SELECT 'CLEANUP COMPLETE' AS Section;

    -- =========================================
    -- TEST 1: SUCCESS CASE
    -- mentee -> mentor
    -- Expected: insert succeeds
    -- =========================================
    SET v_test_name = 'TEST 1: Valid rating (mentee -> mentor)';
    SET v_error_message = NULL;

    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        END;

        CALL SubmitRating(
            @mentorship_id,
            @mentee_user_id,
            @mentor_user_id,
            'Good'
        );
    END;

    IF v_error_message IS NULL THEN
        SELECT v_test_name AS TestName,
               'PASS' AS Result,
               'Valid rating inserted successfully' AS Details;
    ELSE
        SELECT v_test_name AS TestName,
               'FAIL' AS Result,
               v_error_message AS Details;
    END IF;

    -- Verify inserted row exists
    SELECT COUNT(*) INTO v_row_count
    FROM Rating
    WHERE MentorshipID = UUID_TO_BIN(@mentorship_id)
      AND RaterUserID = UUID_TO_BIN(@mentee_user_id)
      AND RatedUserID = UUID_TO_BIN(@mentor_user_id);

    SELECT 'VERIFY TEST 1 INSERT' AS TestName,
           CASE WHEN v_row_count = 1 THEN 'PASS' ELSE 'FAIL' END AS Result,
           CONCAT('Matching rows found: ', v_row_count) AS Details;

    -- =========================================
    -- TEST 2: WRONG ROLE CASE
    -- mentor -> mentee
    -- Expected: fail with role error
    -- =========================================
    SET v_test_name = 'TEST 2: Wrong role (mentor -> mentee)';
    SET v_error_message = NULL;

    -- Clean reversed pair first just in case
    DELETE FROM Rating
    WHERE MentorshipID = UUID_TO_BIN(@mentorship_id)
      AND RaterUserID = UUID_TO_BIN(@mentor_user_id)
      AND RatedUserID = UUID_TO_BIN(@mentee_user_id);

    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        END;

        CALL SubmitRating(
            @mentorship_id,
            @mentor_user_id,
            @mentee_user_id,
            'Poor'
        );
    END;

    IF v_error_message = 'Only mentees can rate mentors' THEN
        SELECT v_test_name AS TestName,
               'PASS' AS Result,
               v_error_message AS Details;
    ELSEIF v_error_message IS NULL THEN
        SELECT v_test_name AS TestName,
               'FAIL' AS Result,
               'Procedure incorrectly allowed mentor to rate mentee' AS Details;
    ELSE
        SELECT v_test_name AS TestName,
               'FAIL' AS Result,
               v_error_message AS Details;
    END IF;

    -- =========================================
    -- TEST 3: SELF-RATING CASE
    -- Expected: fail with self-rating error
    -- =========================================
    SET v_test_name = 'TEST 3: Self-rating';
    SET v_error_message = NULL;

    DELETE FROM Rating
    WHERE MentorshipID = UUID_TO_BIN(@mentorship_id)
      AND RaterUserID = UUID_TO_BIN(@mentee_user_id)
      AND RatedUserID = UUID_TO_BIN(@mentee_user_id);

    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        END;

        CALL SubmitRating(
            @mentorship_id,
            @mentee_user_id,
            @mentee_user_id,
            'Neutral'
        );
    END;

    IF v_error_message = 'User cannot rate themselves' THEN
        SELECT v_test_name AS TestName,
               'PASS' AS Result,
               v_error_message AS Details;
    ELSEIF v_error_message IS NULL THEN
        SELECT v_test_name AS TestName,
               'FAIL' AS Result,
               'Procedure incorrectly allowed self-rating' AS Details;
    ELSE
        SELECT v_test_name AS TestName,
               'FAIL' AS Result,
               v_error_message AS Details;
    END IF;

    -- =========================================
    -- TEST 4: DUPLICATE CASE
    -- Expected: fail with duplicate error
    -- =========================================
    SET v_test_name = 'TEST 4: Duplicate rating';
    SET v_error_message = NULL;

    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        END;

        CALL SubmitRating(
            @mentorship_id,
            @mentee_user_id,
            @mentor_user_id,
            'Good'
        );
    END;

    IF v_error_message = 'Rating already exists for this mentorship pair' THEN
        SELECT v_test_name AS TestName,
               'PASS' AS Result,
               v_error_message AS Details;
    ELSEIF v_error_message IS NULL THEN
        SELECT v_test_name AS TestName,
               'FAIL' AS Result,
               'Procedure incorrectly allowed duplicate rating' AS Details;
    ELSE
        SELECT v_test_name AS TestName,
               'FAIL' AS Result,
               v_error_message AS Details;
    END IF;

    -- =========================================
    -- FINAL DATA SNAPSHOT
    -- =========================================
    SELECT 'FINAL RATING SNAPSHOT' AS Section,
           BIN_TO_UUID(RatingID) AS RatingID,
           BIN_TO_UUID(MentorshipID) AS MentorshipID,
           BIN_TO_UUID(RaterUserID) AS RaterUserID,
           BIN_TO_UUID(RatedUserID) AS RatedUserID,
           RatingValue,
           RatingDate
    FROM Rating
    WHERE MentorshipID = UUID_TO_BIN(@mentorship_id)
    ORDER BY RatingDate DESC;

END $$

DELIMITER ;

CALL RunSubmitRatingTests();
