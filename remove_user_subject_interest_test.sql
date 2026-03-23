USE MentorLink;

-- =========================================
-- TEST: RemoveUserSubjectInterest
-- =========================================

-- Pick a user and subject
SELECT BIN_TO_UUID(UserID) INTO @user_id
FROM User
ORDER BY UserID
LIMIT 1;

SELECT BIN_TO_UUID(SubjectID) INTO @subject_id
FROM Subject
ORDER BY SubjectID
LIMIT 1;

-- Ensure row exists first
INSERT IGNORE INTO User_Subject (UserID, SubjectID, UserType)
VALUES (UUID_TO_BIN(@user_id), UUID_TO_BIN(@subject_id), 'Sought');

-- Call procedure
CALL RemoveUserSubjectInterest(@user_id, @subject_id, 'Sought');

-- Verify removal
SELECT
    'After RemoveUserSubjectInterest' AS TestStep,
    BIN_TO_UUID(UserID) AS UserID,
    BIN_TO_UUID(SubjectID) AS SubjectID,
    UserType
FROM User_Subject
WHERE UserID = UUID_TO_BIN(@user_id)
  AND SubjectID = UUID_TO_BIN(@subject_id)
  AND UserType = 'Sought';