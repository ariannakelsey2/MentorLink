USE MentorLink;

-- =============================
-- CLEAN START
-- =============================
DROP TABLE IF EXISTS Opportunity;

-- =============================
-- CREATE HYPOTHETICAL TABLE
-- =============================
CREATE TABLE Opportunity (
    OpportunityID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
    Title VARCHAR(255) NOT NULL,
    Type ENUM('Internship', 'Research', 'Scholarship', 'Other') NOT NULL,
    Organization VARCHAR(255),
    URL VARCHAR(500),
    Description TEXT,
    CONSTRAINT pk_opportunity PRIMARY KEY (OpportunityID)
);

-- =============================
-- INSERT SAMPLE DATA (simulate scraped CSV)
-- =============================
INSERT INTO Opportunity (Title, Type, Organization, URL, Description) VALUES
('Software Engineering Intern', 'Internship', 'Google', 'https://careers.google.com', 'Work on backend systems'),
('AI Research Assistant', 'Research', 'MIT', 'https://mit.edu', 'Assist in AI lab'),
('Data Science Internship', 'Internship', 'Amazon', 'https://amazon.jobs', 'Analyze large datasets'),
('Cybersecurity Research', 'Research', 'Stanford', 'https://stanford.edu', 'Security research project'),
('Summer Internship Program', 'Internship', 'Microsoft', 'https://microsoft.com', 'General internship program'),
('Scholarship Opportunity', 'Scholarship', 'NSF', 'https://nsf.gov', 'Funding for students'),
('Machine Learning Intern', 'Internship', 'Meta', 'https://meta.com', 'ML projects'),
('Research Fellowship', 'Research', 'Harvard', 'https://harvard.edu', 'Academic research'),
('Backend Developer Intern', 'Internship', 'Netflix', 'https://jobs.netflix.com', 'API development'),
('Cloud Internship', 'Internship', 'AWS', 'https://aws.amazon.com', 'Cloud engineering');

-- =============================
-- BEFORE INDEX (FULL TABLE SCAN)
-- =============================
EXPLAIN ANALYZE
SELECT OpportunityID, Title, Organization, URL
FROM Opportunity
WHERE Type = 'Internship';

-- =============================
-- CREATE INDEX
-- =============================
CREATE INDEX idx_opportunity_type
ON Opportunity(Type);

-- =============================
-- AFTER INDEX (INDEX USED)
-- =============================
EXPLAIN ANALYZE
SELECT OpportunityID, Title, Organization, URL
FROM Opportunity
WHERE Type = 'Internship';

-- =============================
-- COMPLEX QUERY 1
-- Count opportunities by type
-- Uses GROUP BY, COUNT, ORDER BY
-- =============================
SELECT
    Type,
    COUNT(*) AS OpportunityCount
FROM Opportunity
GROUP BY Type
ORDER BY OpportunityCount DESC, Type ASC;

-- =============================
-- COMPLEX QUERY 2
-- Find opportunities whose type appears more than once
-- Uses nested subquery + GROUP BY + HAVING
-- =============================
SELECT
    Title,
    Type,
    Organization,
    URL
FROM Opportunity
WHERE Type IN (
    SELECT Type
    FROM Opportunity
    GROUP BY Type
    HAVING COUNT(*) > 1
)
ORDER BY Type ASC, Title ASC;
