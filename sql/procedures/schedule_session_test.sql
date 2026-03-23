USE MentorLink;

-- =========================================
-- TEST: ScheduleSession
-- =========================================

-- Pick a mentorship
SELECT BIN_TO_UUID(MentorshipID) INTO @mentorship_id
FROM Mentorship
ORDER BY MentorshipID
LIMIT 1;

-- Define timestamp
SET @schedule_time = '2026-05-20 14:00:00';

-- Ensure clean state
DELETE FROM Session
WHERE MentorshipID = UUID_TO_BIN(@mentorship_id)
  AND Timestamp = @schedule_time
  AND Status = 'Scheduled';

-- Call procedure
CALL ScheduleSession(
    @mentorship_id,
    @schedule_time,
    'Virtual',
    'Zoom'
);

-- Verify insert
SELECT
    'After ScheduleSession' AS TestStep,
    BIN_TO_UUID(SessionID) AS SessionID,
    BIN_TO_UUID(MentorshipID) AS MentorshipID,
    Timestamp,
    InstructionType,
    Location,
    Status
FROM Session
WHERE MentorshipID = UUID_TO_BIN(@mentorship_id)
  AND Timestamp = @schedule_time;
