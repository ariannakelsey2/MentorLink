# MentorLink Database System
## Full Setup & Execution Guide

## Overview
This guide explains how to fully recreate the MentorLink database system from scratch using the current repository structure.

This project includes:
- SQL schema (tables)
- Stored procedures
- Sample CSV data
- Query optimizations
- Web scraping scripts

---

# 1. Project Structure 
```
MentorLink/
│
├── data/
│   ├── User.csv
│   ├── Subject.csv
│   ├── User-Subject.csv
│   ├── Mentorship.csv
│   ├── Mentorship-Member.csv
│   ├── Session.csv
│   ├── Goal.csv
│   └── Rating.csv
│
├── sql/
│   ├── schema/
│   │   ├── user_entity.sql
│   │   ├── subject_entity.sql
│   │   ├── mentorship_entity.sql
│   │   ├── mentorship_member_entity.sql
│   │   ├── session_entity.sql
│   │   └── goal_rating.sql
│   │
│   └── procedures/
│
├── queries/
│
├── scraping/
│   ├── faculty/
│   ├── research/
│   ├── opportunities/
│   └── courses/
│
├── documents/
│
└── README.md
```

---

# 2. Requirements

Install:

- MySQL Server 8+
- MySQL Workbench
- Python 3

Install Python packages:
```
pip install requests beautifulsoup4 lxml
```

---

# 3. Recreating the Database

## Step 1: Open MySQL Workbench

Open a new SQL tab.

---

## Step 2: Reset Database

```sql
DROP DATABASE IF EXISTS MentorLink;
CREATE DATABASE MentorLink;
USE MentorLink;
```

---

## Step 3: Run Schema Files

Run these in order:

1. user_entity.sql  
2. subject_entity.sql  
3. mentorship_entity.sql  
4. mentorship_member_entity.sql  
5. session_entity.sql  
6. goal_rating.sql  

---

# 4. Import CSV Data

Import using **Table Data Import Wizard**

## Import Order (IMPORTANT)

1. User.csv  
2. Subject.csv  
3. Mentorship.csv  
4. User-Subject.csv  
5. Mentorship-Member.csv  
6. Session.csv  
7. Goal.csv  
8. Rating.csv  

---

# 5. Create Stored Procedures

Go to:
```
sql/procedures/
```

Run all procedure files.

---

# 6. Run Queries / Optimizations

Go to:
```
queries/
```

Run:
- mentorship_session_queries.sql
- mentor_queries.sql
- opportunities_query.sql
- research_queries.sql

Use:
```sql
EXPLAIN
```
to show performance.

---

# 7. Run Scrapers

From terminal:

## Faculty
```
python scraping/faculty/scrape_faculty.py
```

## Research
```
python scraping/research/scrape_research.py
```

## Opportunities
```
python scraping/opportunities/scrape_opportunities.py
```

## Courses
```
python scraping/courses/scrape_courses.py
```

---

# 8. Full Rebuild Order

1. Drop database  
2. Create database  
3. Run schema files  
4. Import CSVs  
5. Run procedures  
6. Run queries  
7. Run scrapers  

---

# 9. Verification

```sql
SHOW TABLES;

SELECT COUNT(*) FROM User;
SELECT COUNT(*) FROM Mentorship;
SELECT COUNT(*) FROM Session;
SELECT COUNT(*) FROM Goal;
SELECT COUNT(*) FROM Rating;
```

---

# 10. Notes

This project demonstrates:
- relational schema design
- normalization (3NF)
- constraints & foreign keys
- stored procedures
- query optimization
- data scraping & cleaning

---

