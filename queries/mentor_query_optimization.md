# Mentor Query Optimization

\---

## Query 1 — Find All Mentors Grouped by Department

### 

### Proposed Query

```sql
SELECT DISTINCT
    sub.Department,
    BIN\\\_TO\\\_UUID(u.UserID) AS UserID,
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
CREATE INDEX idx\\\_subject\\\_department
    ON Subject(Department);
```

### Why This Index Helps

This query sorts results by the `Department` column in the `Subject` table. Before the index, the MySQL performs a full table scan on `Subject`. After adding the index on `Department`, MySQL can look at rows directly from the index, reducing the rows scanned and the cost of the `ORDER BY` operation.





\---

## Query 2 — Find Mentors with Active Mentorships in a Specific Subject



### Query

```sql
SELECT
    BIN\\\_TO\\\_UUID(u.UserID)       AS UserID,
    u.FirstName,
    u.LastName,
    u.Email,
    BIN\\\_TO\\\_UUID(m.MentorshipID) AS MentorshipID,
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
CREATE INDEX idx\\\_subject\\\_subjectname
    ON Subject(SubjectName);
```

### Why This Index Helps

This query filters on `SubjectName = 'Python'`. Without an index, the system scans all rows in `Subject` to find the matching subject and then scans `Mentorship` and `MentorshipMember`. After adding the index on `SubjectName`, MySQL jumps directly to the matching row, significantly reducing the rows scanned.

\---



## 

