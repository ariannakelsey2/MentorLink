# Mentor Query Optimization

---

## Query 1 — Find All Mentors Grouped by Department

### Purpose
Retrieve all mentors across all mentorships, sorted and grouped by their subject's department.

### Query
```sql
SELECT DISTINCT
    sub.Department,
    BIN_TO_UUID(u.UserID) AS UserID,
    u.FirstName,
    u.LastName,
    u.Email
FROM User u
JOIN MentorshipMember mm
    ON u.UserID = mm.UserID
   AND mm.RoleValue = 'Mentor'
JOIN Mentorship m
    ON mm.MentorshipID = m.MentorshipID
JOIN Subject sub
    ON m.SubjectID = sub.SubjectID
ORDER BY sub.Department;
```

### Proposed Index
```sql
CREATE INDEX idx_subject_department
    ON Subject(Department);
```

### Why This Index Helps
This query sorts and deduplicates results by the `Department` column in the `Subject` table. Without an index, MySQL performs a full table scan on `Subject`, reading every row before sorting. After adding the index on `Department`, MySQL can traverse rows in sorted order directly from the index, reducing both the rows scanned and the cost of the `ORDER BY` operation.

---

## Query 2 — Find Mentors with Active Mentorships in a Specific Subject

### Purpose
Retrieve all mentors who are in an active mentorship for a specific subject, in this case Python.

### Why it is Complex
This query joins four tables — `User`, `MentorshipMember`, `Mentorship`, and `Subject` — while applying multiple filters across different tables simultaneously: `RoleValue = 'Mentor'` on `MentorshipMember`, `Status = 'Active'` on `Mentorship`, and `SubjectName = 'Python'` on `Subject`. The combination of multi-table joins with layered filtering conditions makes this more advanced than a basic retrieval query.

### Query
```sql
SELECT
    BIN_TO_UUID(u.UserID)       AS UserID,
    u.FirstName,
    u.LastName,
    u.Email,
    BIN_TO_UUID(m.MentorshipID) AS MentorshipID,
    sub.SubjectName,
    sub.Department
FROM User u
JOIN MentorshipMember mm
    ON u.UserID = mm.UserID
   AND mm.RoleValue = 'Mentor'
JOIN Mentorship m
    ON mm.MentorshipID = m.MentorshipID
   AND m.Status = 'Active'
JOIN Subject sub
    ON m.SubjectID = sub.SubjectID
   AND sub.SubjectName = 'Python';
```

### Proposed Index
```sql
CREATE INDEX idx_subject_subjectname
    ON Subject(SubjectName);
```

### Why This Index Helps
This query filters on `SubjectName = 'Python'` as the entry point into the join chain. Without an index, MySQL scans all rows in `Subject` to find the matching subject before traversing into `Mentorship` and `MentorshipMember`. After adding the index on `SubjectName`, MySQL jumps directly to the matching row, significantly reducing the rows scanned and lowering the cost of the entire join chain.

---

## Performance Analysis (Before vs After Index)

### Query 1 — Department Index

| | Before Index | After Index |
|---|---|---|
| `Subject` access method | Full table scan (12 rows) | Covering index lookup (2 rows) |
| Cost | 1.45 | 0.458 |
| Total query time | 0.208ms | 0.158ms |

**Before:** MySQL scanned all 12 rows in `Subject` then filtered down to matches.

**After:** MySQL used `idx_subject_department` to jump directly to matching rows. The lookup was a **covering index**, meaning no access to the base table was needed at all.

### Query 2 — SubjectName Index

Run `EXPLAIN ANALYZE` before and after creating `idx_subject_subjectname` and look for the following changes on the `Subject` row:

| | Before Index | After Index |
|---|---|---|
| `type` | `ALL` | `ref` |
| `key` | `NULL` | `idx_subject_subjectname` |
| `rows` | Full table count | 1 |

---

## Conclusion

Both queries benefit from indexes on the `Subject` table, which acts as the filtering entry point in each join chain. Adding `idx_subject_department` eliminated a full table scan and enabled a covering index lookup, producing a measurable ~24% reduction in query time for Query 1. Adding `idx_subject_subjectname` allows MySQL to locate a specific subject by name in a single lookup rather than scanning the entire table, improving the efficiency of the full four-table join in Query 2. As the `Subject` table grows, both indexes will provide increasing performance gains.
