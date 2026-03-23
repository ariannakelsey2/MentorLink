USE MentorLink;

-- =========================================
-- TEST: AddUserSubjectInterest
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

-- Ensure clean state (remove existing row if present)
DELETE FROM User_Subject
WHERE UserID = UUID_TO_BIN(@user_id)
  AND SubjectID = UUID_TO_BIN(@subject_id)
  AND UserType = 'Sought';

-- Call procedure
CALL AddUserSubjectInterest(@user_id, @subject_id, 'Sought');

-- Verify result
SELECT
    'After AddUserSubjectInterest' AS TestStep,
    BIN_TO_UUID(UserID) AS UserID,
    BIN_TO_UUID(SubjectID) AS SubjectID,
    UserType
FROM User_Subject
WHERE UserID = UUID_TO_BIN(@user_id)
  AND SubjectID = UUID_TO_BIN(@subject_id)
  AND UserType = 'Sought';