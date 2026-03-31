-- Accountability Documentation
-- By: Arianna Kelsey (Team Leader)

## Meeting Dates for this Phase: 
	- 03/05/2026 @ 5PM
	- 03/16/2026 @ 5PM
	- 03/24/2026 @ 5PM
	- 03/30/2026 @ 5PM

## Meeting Content

### Meetings were orchestrated and ran by Arianna, delegating tasks and setting timelines and expectations for the progression of the project.


## SQL Scripts (Due Date: 3/15/2026)

### Each individual is responsible for creating their assigned tables, store it in the appropriate database, and adding all constraints and indexes associated. Each individual is also responsible for testing their scripts with sample data and providing that testing within the GitHub repository. 

	Mentorship Module -- Jordie
		- Tables: Mentorship & Mentorship-Member

	Subject Module -- Mathieu
		- Tables: Subject & Session

	Feedback Module -- Arianna
		- Tables: Goal & Rating

	User Module -- Hanan
		- Tables: User & User-Subject


## Sample Data Creation (Due Date: 3/17/2026)

### Each individual is responsible for creating at least two spreadsheets of sample data to be imported by a CSV file into MyWorkBench to test their scripts. 

	- 12 Users, 6-8 Subjects (Hanan)
	- 24 User-Subject Rows, 10-15 Goals, 6 - 10 Ratings (Arianna)
	- 12 Sessions (Mathieu)
	- 6 Mentorships, 12 Mentorship-Members (Jordie)

## Stored Procedures & Functions (Due: 3/20/2026)

### Mathieu and Arianna added their test scripts for their portions of their procedures by choice as additional contributions to the deliverables, although it was not specified as a requirement to turn in.	

	- Arianna: 
		- add_user_subject_interest.sql 
		- add_user_subject_interest_test.sql
		- remove_user_subject_interest.sql
		- remove_user_subject_interest_test.sql
		- submit_rating.sql
		- submit_rating_test.sql
		- reschedule_session.sql
		- reschedule_session_test.sql
	
	- Hanan:
		- add_goal_to_mentorship.sql
		- mark_goal_achieved.sql
		- update_goal_description.sql
		- schedule_session.sql

	- Mathieu:
		- cancel_session.sql
		- end_mentorship.sql
		- get_mentorship_summary.sql
		- count_achieved_goals.sql
		- TEST_RESULTS.md
		- test_functions.py
		- test_user_functions.sql
		- test_user_functions_sample_data.sql
	
	- Jordie:
		- change_user_password.sql
		- update_user_profile.sql
		- create_user.sql
		- create_mentorship.sql
		- activate_mentorship.sql

## Scraping (Due: 3/27/2026)

### Each individual was responsible for generating their own Python scraper and outputting two files from it a raw JSON and a cleaned CSV

	- Opportunities Scraper -- Arianna: 
		- scrape_opportunities.py
		- opportunities_raw.json
		- opportunities_cleaned.csv
	- Research Scraper -- Hanan:
		- scrape_research.py
		- research_raw.json
		- research_cleaned.csv
	- Courses Scraper -- Mathieu:
		- scrape_courses.py
		- courses_raw.json
		- courses_cleaned.csv
		
	- Faculty/Mentor Scraper -- Jordie
		- scrape_faculty.py
		- faculty_raw.json
		- faculty_cleaned.csv

## Data Cleaning Documentation (Due: 3/29/2026)

### Every individual contributes their cleaning documentation within the scope of their   contributions from their python scraping portions:
		
		- Opportunities -- Arianna
		- Research -- Hanan
		- Courses -- Mathieu
		- Faculty/Mentor -- Jordie

## Query Optimization Analysis (Due: 3/29/2026)

### Every individual is responsible for their query and indexing scripts and contributing a markdown file explaining their optimizations to the query

	- Jordie
		- mentor_queries.sql
		- mentor_query_optimization.md
	- Arianna
		- opportunities_query.sql
		- opportunities_query_optimization.md
	- Mathieu
		- mentorship_session_queries.sql
		- mentorship_session_query_optimization.md
	- Hanan
		- research_queries.sql
		- research_query_optimization.md

## Presentation Responsibilities 

### Every individual made their own portions on a singular slideshow for their presentation, and each individual is only accountable for presenting on the work that they wrote. Every individual is responsible for recording their portion of the slideshow and send it to Arianna to merge into one .mp4 file

## Github Repository 

### A large majority of the Github organization was committed by Arianna. Each individual as responsible for making pull requests on their development branches to commit main.  





