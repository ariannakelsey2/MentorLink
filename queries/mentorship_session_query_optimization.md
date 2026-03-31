# Mentorship Session Query Optimization

This file shows two mentorship session queries and the changes made to improve them.

## Query 1 — Sessions for a Mentorship Sorted by Time

### Goal
Get all sessions for one mentorship in time order.

### Proposed Query (Baseline)
```sql
SELECT *
FROM Session
WHERE MentorshipID = 1919
ORDER BY Timestamp;
```

### Optimized Query
```sql
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
```

### Optimization Notes
1. Replaced `SELECT *` with explicit columns.
This reads only needed fields, so less data is processed.

2. Added deterministic tie-breaker sort (`SessionID`).
`ORDER BY Timestamp ASC, SessionID ASC` keeps row order consistent when two sessions share the same timestamp.

3. Kept indexed filter and sort pattern.
The query matches the `Session` indexes (especially `(MentorshipID, Timestamp)`), which helps with filtering and sorting.

---

## Query 2 — Scheduled Sessions from a Start Time

### Goal
Get scheduled sessions for one mentorship after a given start time.

### Proposed Query (Baseline)
```sql
SELECT *
FROM Session
WHERE MentorshipID = 1919
  AND DATE(Timestamp) >= DATE('2025-01-01 00:00:00')
  AND Status = 'Scheduled'
ORDER BY Timestamp;
```

### Optimized Query
```sql
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
```

### Optimization Notes
1. Removed function-wrapped filter on indexed column.
`DATE(Timestamp)` was replaced with `Timestamp >= ...` so the index can be used more effectively.

2. Narrowed projection.
Selecting only needed columns reduces how much data is read.

3. Preserved index-compatible predicates.
Filtering by `MentorshipID` and time range matches session indexes and helps avoid full table scans.

4. Added deterministic ordering.
`SessionID` as a second sort key keeps order stable when timestamps are equal.

---

## Proposed Indexes

### Index Context Used
These changes use the `Session` indexes already used in the project:
- `idx_session_mentorship` on `(MentorshipID)`
- `idx_session_timestamp` on `(Timestamp)`
- `idx_session_mentorship_timestamp` on `(MentorshipID, Timestamp)`
- `idx_session_status` on `(Status)`

## Justification for New Indices

If these indexes are newly added in a local or test schema, here is why they help.

### Proposed Index 1
```sql
CREATE INDEX idx_session_timestamp ON Session(Timestamp);
```

### Why This Index Helps
- Supports pure time-based range scans like `Timestamp >= ?`.
- Reduces scan and sort work for queries that mostly filter by time.
- Can also help reporting queries that are based on time.

### Proposed Index 2
```sql
CREATE INDEX idx_session_mentorship_timestamp ON Session(MentorshipID, Timestamp);
```

### Why This Index Helps
- Matches the left-to-right access pattern in both optimized queries:
  `WHERE MentorshipID = ?` and `ORDER BY Timestamp`.
- Helps return a mentorship's sessions already in timestamp order, which reduces extra sort work.
- Improves Query 2 (`MentorshipID = ? AND Timestamp >= ?`) by covering both filters in one index.

### Why No New `(MentorshipID, Status, Timestamp)` Index Was Added
Query 2 also filters on `Status`, but another composite index was not added yet because:
- Current indexes already work well for this workload.
- More indexes increase write cost (`INSERT`/`UPDATE`/`DELETE`) and storage use.
- A 3-column index should be added only if `EXPLAIN ANALYZE` shows Query 2 is still slow at larger scale.

---

## Optional Validation
Use `EXPLAIN` (or `EXPLAIN ANALYZE` if available) on baseline and optimized queries to compare row estimates and access paths.
