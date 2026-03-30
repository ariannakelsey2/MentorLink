## Opportunity Query Optimization
## Complex Query Description

### Proposed Query
```sql
SELECT OpportunityID, Title, Organization, URL
FROM Opportunity
WHERE Type = 'Internship';
```

### Proposed Index
```sql
CREATE INDEX idx_opportunity_type
ON Opportunity(Type);
```

### Why This Index Helps
This query filters directly on the Type column. Without an index, MySQL performs a full table scan, checking every row to find matching opportunities.

After adding an index on Type, MySQL can quickly locate only the rows that match 'Internship', significantly reducing the number of rows scanned. This improves performance for users searching by opportunity category such as internships or research positions.

### Performance Analysis (Before vs After Index)

To evaluate performance, a sample Opportunity table was created in the sample format as the scraped dataset.

Before Index:

MySQL performs a full table scan
All rows are checked to find matches for Type = 'Internship'
Higher execution cost for large datasets

After Index:

MySQL uses the idx_opportunity_type index
Only relevant rows are accessed
Faster query execution and improved scalability

Conclusion:
Adding an index on the Type column significantly improves performance for filtering queries. This is especially important as the dataset grows and users frequently search by opportunity category.

## Complex Query 1
Purpose: Count the number of opportunities in each category.
Why it is complex: This query goes beyond a simple SELECT by using COUNT(*), GROUP BY, and ORDER BY to summarize the data by opportunity type.

## Complex Query 2
Purpose: Retrieve all opportunities belonging to types that occur more than once in the dataset.
Why it is complex: This query uses a nested subquery with GROUP BY and HAVING, which makes it more advanced than a basic retrieval query.


