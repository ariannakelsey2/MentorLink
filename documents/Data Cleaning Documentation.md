## Research Areas Data Cleaning

### Source
Wikipedia - Outline of Academic Disciplines 

### Raw Data Issues
	- Introduction paragraph 
	- White space
	- Large list with many disciplines irrelevant to our DB 
	- Subjects have sub-topics that are irrelevant (list inside list)
	- Subject names have special characters (e.g. “(”) with additional text


### Cleaning Steps
	- Inspected the page to view HTML structure
	- Analyzed the hierarchy
	- Found that topics were divided into five main topics	
		- Humanities
		- Social science
		- Natural science 
		- Formal science
		- Applied science
	- Chose fifteen relevant sub-topics total
	- Created a list to store subjects and IDs
	- Used BeautifulSoup to find all sub-topics which were under “h3” or “h4” 	headers
	- Looped through target headers/sub-topics 
	- Found corresponding “div” where unordered lists were stored
	- Looped through list items 
		- Found that subject names were stored in anchor tags 
		- Extracted text(subject names) inside anchor tags
	- Created empty column to store subject IDs

### Output

	- User_subjects.json
	- User_subjects.csv

## Faculty Data Cleaning

### Source: 
	USM Faculty Directory - https://usm.maine.edu/directories/faculty/

### Raw Data Issues
	- Pronoun blocks in name and title fields (`he/him`, `she/her/hers`, `they/	them/theirs`
	- Department field often blank when not explicitly labeled "Department of X"
	- Inconsistent title formatting across profiles
	- Phone numbers mixed into bio text alongside other content
	- Some profiles missing fields (no email, no phone, no department)
 
### Cleaning Steps
	- Inspected USM faculty directory to identify HTML structure
	- Collected up 50 faculty profile URLs by paginating through the directory
	- Followed links matching `/directories/people/` pattern
	- For each profile, isolated main content using semantic selectors (`main`, 	`article`, `.node__content`) to avoid pulling in nav/footer text
	- Extracted name from `h1` tag and split into `FirstName` and `LastName`
	- Extracted email from `mailto:` anchor tag
	- Extracted phone using regex, filtering out the USM general line 	
	`800-800-4876`
	- Stripped pronoun blocks from all text fields using a single parenthetical 	regex `\([\w/\s,]+\)` to catch all formats
	- Split bio text into sections (bio, education, research interests, 		publications) by detecting header keywords
	- Extracted department using three fallback patterns in order:
		-"Department of X" / "School of X" / "College of X"
		-"Professor of X" — subject extracted from after "of"
		-"X Professor" — field name extracted from before "Professor"
	- Extracted title by matching rank keywords: Professor, Assistant Professor, 	- Associate Professor, Clinical Professor, Adjunct Professor, Lecturer, Chair
	- Generated synthetic `UserID` (random 9-digit integer) and `Password` for 	each record
	- Saved unmodified scraped text as raw JSON before any cleaning was applied
 
### Output
	- `faculty_raw.json`
	- `faculty_cleaned.csv`

## Opportunities Data Cleaning

### Source
	Public USM opportunity-related pages, including internship and research 	opportunity pages.

### Raw Data Issues
	- Inconsistent paragraph lengths
	- Repeated whitespace
	- Not all pages used the same structure
	- Some pages were informational rather than standard listing pages
	- Duplicate or overlapping opportunity categories were possible

### Cleaning Steps
	- Extracted page title as the main opportunity title
	- Normalized whitespace
	- Shortened long descriptions
	- Standardized `Type` values into Internship, Research, Scholarship, or Other
	- Removed duplicate records using title + URL
	- Excluded records missing required fields such as title or URL

### Output
	- `opportunities_raw.json`
	- `opportunities_cleaned.csv`

## Course Data Cleaning

### Source
USM Course Catalog - https://catalog.usm.maine.edu/content.php?catoid=19&navoid=1022&filter[item_type]=3&filter[only_active]=1&filter[3]=1&filter[cpage]=1

### Raw Data Issues
- Data spread across 16 paginated pages (approximately 100 courses per page)
- Course names containing commas caused inconsistent CSV quoting
- Department information not available on filtered course listing pages
- No explicit department headers on individual course pages
- Course prefixes needed mapping to full department names
- URL-encoded pagination parameters required special handling

### Cleaning Steps
- Inspected USM catalog to identify HTML structure and pagination pattern
- Detected total pages using URL-encoded pagination links (`filter%5Bcpage%5D=N`)
- Built complete department mapping by iterating through all 16 catalog pages
- For each page, located all course links matching `preview_course` pattern
- Looked backward from each course link to find nearest department header (h2, h3, h4, strong, b tags)
- Cleaned department names by removing institutional prefixes ("Department of", "School of", "College of") and parenthetical content
- Extracted course prefix from course code (e.g., "ACC" from "ACC 105 - Show Me the Money")
- Mapped each unique prefix to its corresponding department name
- Implemented multi-page scraping with 1.5 second delay between requests to avoid rate limiting
- Parsed courses using 4 fallback strategies: courseblocks, tables, generic containers, and course detail links
- Filtered invalid entries including navigation links ("Course Search", "Registration") and pagination controls ("Forward 10")
- Deduplicated 1,581 courses across all pages based on normalized course names
- Applied `csv.QUOTE_ALL` parameter to ensure consistent quoting in all CSV rows
- Saved raw course data to JSON before applying department mapping

### Output
- `courses_raw.json`
- `courses_cleaned.csv`
- `departments.json`
