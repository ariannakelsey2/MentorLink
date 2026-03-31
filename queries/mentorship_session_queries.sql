-- Mentorship Session Query Optimization
-- Contains baseline and optimized versions for two queries.

-- ============================================================================
-- Query 1: Return all sessions for a mentorship sorted by time
-- ============================================================================

-- Baseline
EXPLAIN
SELECT *
FROM Session
WHERE MentorshipID = 1919
ORDER BY Timestamp;

SELECT
    SessionID,
    MentorshipID,
    Timestamp,
    InstructionType,
    Location,
    Status
FROM Session
WHERE MentorshipID = 1919
ORDER BY Timestamp;

-- Optimized
EXPLAIN
SELECT
    SessionID,
    MentorshipID,
    Timestamp,
    InstructionType,
    Location,
    Status
FROM Session
WHERE MentorshipID = 1919
ORDER BY Timestamp ASC, SessionID ASC;

SELECT
    SessionID,
    MentorshipID,
    Timestamp,
    InstructionType,
    Location,
    Status
FROM Session
WHERE MentorshipID = 1919
ORDER BY Timestamp ASC, SessionID ASC;

-- Parameterized form (for procedures/apps)
-- WHERE MentorshipID = ?


-- ============================================================================
-- Query 2: Return scheduled sessions for a mentorship from a start time
-- ============================================================================

-- Baseline
EXPLAIN
SELECT *
FROM Session
WHERE MentorshipID = 1919
  AND DATE(Timestamp) >= DATE('2025-01-01 00:00:00')
  AND Status = 'Scheduled'
ORDER BY Timestamp;

SELECT
    SessionID,
    MentorshipID,
    Timestamp,
    InstructionType,
    Location,
    Status
FROM Session
WHERE MentorshipID = 1919
  AND DATE(Timestamp) >= DATE('2025-01-01 00:00:00')
  AND Status = 'Scheduled'
ORDER BY Timestamp;

-- Optimized
EXPLAIN
SELECT
    SessionID,
    Timestamp,
    InstructionType,
    Location,
    Status
FROM Session
WHERE MentorshipID = 1919
  AND Timestamp >= '2025-01-01 00:00:00'
  AND Status = 'Scheduled'
ORDER BY Timestamp ASC, SessionID ASC;

SELECT
    SessionID,
    Timestamp,
    InstructionType,
    Location,
    Status
FROM Session
WHERE MentorshipID = 1919
  AND Timestamp >= '2025-01-01 00:00:00'
  AND Status = 'Scheduled'
ORDER BY Timestamp ASC, SessionID ASC;

-- Parameterized form (for procedures/apps)
-- WHERE MentorshipID = ? AND Timestamp >= ? AND Status = 'Scheduled'
