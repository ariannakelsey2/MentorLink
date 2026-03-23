USE MentorLink;

-- =========================================
-- TEST: RescheduleSession
-- =========================================

-- Pick a mentorship
SELECT BIN_TO_UUID(MentorshipID) INTO @mentorship_id
FROM Mentorship
ORDER BY MentorshipID
LIMIT 1;

-- Create a known session first
SET @original_time = '2026-05-21 10:00:00';

DELETE FROM Session
WHERE MentorshipID = UUID_TO_BIN(@mentorship_id)
  AND Timestamp = @original_time;

CALL ScheduleSession(
    @mentorship_id,
    @original_time,
    'Virtual',
    'Zoom'
);

-- Get the session ID we just created
SELECT BIN_TO_UUID(SessionID) INTO @session_id
FROM Session
WHERE MentorshipID = UUID_TO_BIN(@mentorship_id)
  AND Timestamp = @original_time
ORDER BY SessionID DESC
LIMIT 1;

-- Define new time
SET @new_time = '2026-05-22 16:00:00';

-- Ensure no collision
DELETE FROM Session
WHERE MentorshipID = UUID_TO_BIN(@mentorship_id)
  AND Timestamp = @new_time
  AND Status = 'Scheduled';

-- Call procedure
CALL RescheduleSession(
    @session_id,
    @new_time,
    'In-Person',
    'Library Room 204'
);

-- Verify update
SELECT
    'After RescheduleSession' AS TestStep,
    BIN_TO_UUID(SessionID) AS SessionID,
    BIN_TO_UUID(MentorshipID) AS MentorshipID,
    Timestamp,
    InstructionType,
    Location,
    Status
FROM Session
WHERE SessionID = UUID_TO_BIN(@session_id);