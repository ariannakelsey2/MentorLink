# the following code is LLM-generated

import csv
import json
import re
import time
from typing import List, Dict, Optional, Union

import requests
from bs4 import BeautifulSoup
from bs4.element import Tag
import math

# Enhanced headers to bypass bot detection
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
    "Accept-Encoding": "gzip, deflate, br",
    "Referer": "https://catalog.usm.maine.edu/",
    "Connection": "keep-alive",
    "Upgrade-Insecure-Requests": "1",
    "Cache-Control": "max-age=0"
}

# Target URL for USM course catalog (filtered course listing with pagination)
BASE_URL = "https://catalog.usm.maine.edu/content.php?catoid=19&catoid=19&navoid=1022&filter%5Bitem_type%5D=3&filter%5Bonly_active%5D=1&filter%5B3%5D=1&filter%5Bcpage%5D={page}"
MAX_PAGES = 50  # Safety limit to prevent infinite loops
DELAY_BETWEEN_PAGES = 1.5  # Seconds to wait between page requests


def fetch_page(url: str) -> Optional[str]:
    """Download one page and return HTML, or None if request fails."""
    try:
        # Use a session to maintain cookies
        session = requests.Session()
        response = session.get(url, headers=HEADERS, timeout=30, allow_redirects=True)
        response.raise_for_status()

        # Check if we got redirected to a tracking page
        if "tapad.com" in response.url or "snapchat.com" in response.url:
            print(f"[WARNING] Got redirected to tracking page: {response.url}")
            print("[INFO] Try: 1) Install cloudscraper: pip install cloudscraper")
            print("[INFO]      2) Visit the page in a browser first, then try again")
            return None

        return response.text
    except requests.RequestException as e:
        print(f"[ERROR] Could not fetch {url}: {e}")
        return None


def detect_total_pages(html: str) -> int:
    """
    Detect the total number of pages in the course catalog.
    Looks for pagination indicators like page numbers or "Showing X-Y of Z" text.
    Returns 1 if no pagination found, or MAX_PAGES if detection fails.
    """
    soup = BeautifulSoup(html, "html.parser")

    def _extract_page_num(href: str) -> Optional[int]:
        # URL-encoded pattern: filter%5Bcpage%5D=N
        m = re.search(r"cpage%5D=(\d+)", href)
        if not m:
            # Plain pattern: cpage=N or cpage]=N
            m = re.search(r"cpage[\]=]*(\d+)", href)
        return int(m.group(1)) if m else None

    # Strategy 1: Look for pagination links with page numbers
    page_links = soup.find_all(
        "a",
        href=re.compile(r"(?:cpage(?:%5D|\])?=\d+|filter%5Bcpage%5D=\d+)")
    )
    if page_links:
        page_numbers: List[int] = []
        for link in page_links:
            if not isinstance(link, Tag):
                continue
            href = str(link.attrs.get("href", ""))
            page_num = _extract_page_num(href)
            if page_num is not None:
                page_numbers.append(page_num)

        if page_numbers:
            max_page = max(page_numbers)
            print(f"[INFO] Detected {max_page} pages from pagination links")
            return min(max_page, MAX_PAGES)

    # Strategy 2: Look for "Last" or next-page symbols in pagination
    last_links = []
    for link in soup.find_all("a"):
        if not isinstance(link, Tag):
            continue
        link_text = clean_text(link.get_text())
        if re.search(r"^(?:Last|»|>>)$", link_text, re.I):
            last_links.append(link)
    for link in last_links:
        if not isinstance(link, Tag):
            continue
        href = str(link.attrs.get("href", ""))
        page_num = _extract_page_num(href)
        if page_num is not None:
            print(f"[INFO] Detected {page_num} pages from last-link pagination")
            return min(page_num, MAX_PAGES)

    # Strategy 3: Look for text like "Showing 1-20 of 500 courses"
    text = soup.get_text(" ", strip=True)
    match = re.search(r"Showing\s+\d+\s*-\s*\d+\s+of\s+(\d+)", text, re.I)
    if match:
        total_items = int(match.group(1))
        per_page = 20  # typical catalog page size
        estimated_pages = max(1, math.ceil(total_items / per_page))
        print(f"[INFO] Estimated {estimated_pages} pages from 'Showing X-Y of Z'")
        return min(estimated_pages, MAX_PAGES)

    # Strategy 4: Look for pagination container with numbered spans/divs
    pagination_divs = soup.find_all(["div", "ul", "nav"], class_=re.compile(r"pag", re.I))
    for div in pagination_divs:
        nums = [int(n) for n in re.findall(r"\b(\d{1,3})\b", div.get_text(" ", strip=True))]
        if nums:
            max_page = max(nums)
            if max_page > 1:
                print(f"[INFO] Detected {max_page} pages from pagination container")
                return min(max_page, MAX_PAGES)

    print("[INFO] No pagination detected, assuming single page")
    return 1


def clean_text(text: str) -> str:
    """Normalize whitespace and remove extra spaces."""
    if not text:
        return ""
    return re.sub(r"\s+", " ", text).strip()


def parse_departments(html: str) -> Dict[str, str]:
    """
    Parse the page to extract department names and their course prefixes.
    Returns a dictionary mapping course prefixes to department names.
    """
    soup = BeautifulSoup(html, "html.parser")
    dept_mapping = {}

    # Look for department headers and their associated course prefixes
    # Common patterns: headers followed by course lists
    headers = soup.find_all(["h2", "h3", "h4"])

    for header in headers:
        header_text = clean_text(header.get_text())

        # Skip non-department headers
        if not header_text or len(header_text) < 3:
            continue

        # Check if this might be a department header
        # Look for courses after this header
        next_element = header.find_next()
        course_prefixes = set()

        # Look through the next several elements for course codes
        current = next_element
        for _ in range(50):  # Check next 50 elements
            if not current:
                break

            # Stop if we hit another header of the same or higher level
            if current.name in ["h2", "h3", "h4"]:
                break

            text = clean_text(current.get_text())
            # Find course codes in this element
            matches = re.findall(r'\b([A-Z]{2,4})\s*\d{3}', text)
            for match in matches:
                course_prefixes.add(match)

            current = current.find_next()

        # If we found course prefixes under this header, it's likely a department
        if course_prefixes:
            # Clean up department name
            dept_name = header_text.strip()
            # Remove common suffixes/prefixes
            dept_name = re.sub(r'\s*\(.*?\)\s*', '', dept_name)  # Remove parentheses
            dept_name = re.sub(r'^\s*Department of\s+', '', dept_name, flags=re.I)
            dept_name = re.sub(r'\s+Department\s*$', '', dept_name, flags=re.I)

            # Map each prefix to this department
            for prefix in course_prefixes:
                if prefix not in dept_mapping:
                    dept_mapping[prefix] = dept_name

    return dept_mapping


def parse_courses(html: str) -> List[Dict[str, str]]:
    """
    Parse the course catalog page and extract courses.
    Only returns courses with valid course codes (e.g., ACC 105).
    """
    soup = BeautifulSoup(html, "html.parser")
    courses = []

    # Strategy 1: Look for courseblock divs (common in Acalog catalogs)
    courseblocks = soup.find_all("div", class_=re.compile(r"courseblock", re.I))
    if courseblocks:
        print(f"[INFO] Found {len(courseblocks)} courseblocks using Strategy 1")
        for block in courseblocks:
            course_data = extract_from_courseblock(block)
            if course_data and is_valid_course(course_data["CourseName"]):
                courses.append({"CourseName": course_data["CourseName"]})
        return courses

    # Strategy 2: Look for table-based layout
    course_tables = soup.find_all("table", class_=re.compile(r"course", re.I))
    if course_tables:
        print(f"[INFO] Found {len(course_tables)} course tables using Strategy 2")
        for table in course_tables:
            table_courses = extract_from_table(table)
            for course in table_courses:
                if is_valid_course(course["CourseName"]):
                    courses.append({"CourseName": course["CourseName"]})
        return courses

    # Strategy 3: Look for any div/section with course-related classes
    course_containers = soup.find_all(["div", "section"], class_=re.compile(r"course|catalog", re.I))
    if course_containers:
        print(f"[INFO] Found {len(course_containers)} course containers using Strategy 3")
        for container in course_containers:
            course_data = extract_from_generic(container)
            if course_data and is_valid_course(course_data["CourseName"]):
                courses.append({"CourseName": course_data["CourseName"]})
        return courses

    # Strategy 4: Look for links to course detail pages
    course_links = soup.find_all("a", href=re.compile(r"course|preview", re.I))
    if course_links:
        print(f"[INFO] Found {len(course_links)} course links using Strategy 4")
        for link in course_links:
            course_name = clean_text(link.get_text())
            # Only include if it's a valid course
            if course_name and is_valid_course(course_name):
                courses.append({"CourseName": course_name})
        return courses

    print("[ERROR] Could not find courses using any parsing strategy")
    print("[DEBUG] Page title:", soup.title.get_text() if soup.title else "No title")
    print("[DEBUG] First 500 chars of body:", soup.get_text()[:500] if soup.body else "No body")
    return courses


def extract_from_courseblock(block) -> Optional[Dict[str, str]]:
    """Extract course data from a courseblock div."""
    # Look for course title
    title_elem = block.find(class_=re.compile(r"title|name", re.I))
    if not title_elem:
        title_elem = block.find(["h3", "h4", "strong"])

    if not title_elem:
        return None

    course_name = clean_text(title_elem.get_text())

    # Try to extract course code (e.g., "CS 101") and separate from title
    # Pattern: CODE### - Title or CODE ### - Title
    match = re.match(r"^([A-Z]{2,4}\s*\d{3}[A-Z]?)\s*[-–]\s*(.+)$", course_name)
    if match:
        course_code = match.group(1)
        course_title = match.group(2)
        course_name = f"{course_code} - {course_title}"

    return {"CourseName": course_name}


def extract_from_table(table) -> List[Dict[str, str]]:
    """Extract course data from a table."""
    courses = []
    rows = table.find_all("tr")

    for row in rows[1:]:  # Skip header row
        cells = row.find_all(["td", "th"])
        if len(cells) >= 1:
            course_name = clean_text(cells[0].get_text())

            if course_name:
                courses.append({"CourseName": course_name})

    return courses


def extract_from_generic(container) -> Optional[Dict[str, str]]:
    """Extract course data from a generic container."""
    text = clean_text(container.get_text())

    # Look for course code pattern in text
    match = re.search(r"([A-Z]{2,4}\s*\d{3}[A-Z]?)\s*[-–]\s*(.+?)(?:\.|$)", text)
    if match:
        course_code = match.group(1)
        course_title = match.group(2)[:100]  # Limit title length
        course_name = f"{course_code} - {course_title}"

        return {"CourseName": course_name}

    return None


def extract_course_prefix(course_name: str) -> Optional[str]:
    """
    Extract the course prefix (e.g., 'ACC' from 'ACC 105 - Show Me the Money').
    """
    match = re.match(r"^([A-Z]{2,4})\s*\d", course_name)
    if match:
        return match.group(1)
    return None


def scrape_departments_from_main_catalog() -> Dict[str, str]:
    """
    Scrape departments from the main (non-filtered) catalog page.
    This page has department headers with courses listed under them.
    Iterates through multiple pages to get all departments.
    NO FALLBACK - all departments are parsed from actual catalog structure.
    """
    # The main catalog page also has pagination
    main_catalog_base = "https://catalog.usm.maine.edu/content.php?catoid=19&navoid=1022&filter%5Bitem_type%5D=3&filter%5Bonly_active%5D=1&filter%5B3%5D=1&filter%5Bcpage%5D={page}"
    
    print(f"[INFO] Building complete department mapping from all catalog pages...")
    dept_mapping = {}
    
    # Iterate through pages to find all departments
    for page_num in range(1, 17):  # We know there are 16 pages
        print(f"[INFO] Fetching main catalog page {page_num}/16 for departments...")
        page_url = main_catalog_base.format(page=page_num)
        html = fetch_page(page_url)
        
        if not html:
            print(f"[WARNING] Could not fetch catalog page {page_num}")
            continue
        
        soup = BeautifulSoup(html, "html.parser")
        
        # Find all course links and their context
        course_links = soup.find_all("a", href=re.compile(r"preview_course"))
        
        for link in course_links:
            course_text = clean_text(link.get_text())
            
            # Extract course prefix from course name
            match = re.match(r"^([A-Z]{2,4})\s*\d", course_text)
            if not match:
                continue
            
            prefix = match.group(1)
            
            # Don't override if already found
            if prefix in dept_mapping:
                continue
            
            # Look backwards for nearest department header
            current = link
            for _ in range(100):  # Look up to 100 elements back
                current = current.find_previous(['h2', 'h3', 'h4', 'strong', 'b'])
                if not current:
                    break
                
                header_text = clean_text(current.get_text())
                
                # Check if this looks like a department name
                # Skip very short headers or navigation items
                if len(header_text) < 3 or len(header_text) > 100:
                    continue
                
                # Skip common non-department headers
                skip_terms = ['course', 'search', 'home', 'print', 'help', 'catalog',
                             'forward', 'back', 'page', 'showing', 'filter', 'bookmark',
                             'add to', 'share', 'send to']
                if any(term in header_text.lower() for term in skip_terms):
                    continue
                
                # Clean up department name
                dept_name = header_text.strip()
                dept_name = re.sub(r'\s*\(.*?\)\s*', '', dept_name)  # Remove parentheses
                dept_name = re.sub(r'^\s*Department of\s+', '', dept_name, flags=re.I)
                dept_name = re.sub(r'\s+Department\s*$', '', dept_name, flags=re.I)
                dept_name = re.sub(r'^\s*School of\s+', '', dept_name, flags=re.I)
                dept_name = re.sub(r'^\s*College of\s+', '', dept_name, flags=re.I)
                
                if dept_name and len(dept_name) < 80:
                    dept_mapping[prefix] = dept_name
                    print(f"[DEBUG] Page {page_num}: Mapped {prefix} -> {dept_name}")
                    break
        
        # Add delay between requests
        if page_num < 16:
            time.sleep(DELAY_BETWEEN_PAGES)
    
    return dept_mapping


def build_department_mapping(html: str) -> Dict[str, str]:
    """
    Build a mapping from course prefixes to department names.
    
    Scrapes from the main catalog page which has department headers.
    NO FALLBACK - all departments must be parsed from actual pages.
    """
    # Scrape from main catalog page (not filtered listing)
    dept_mapping = scrape_departments_from_main_catalog()
    
    print(f"[INFO] Built department mapping with {len(dept_mapping)} prefixes")
    
    if len(dept_mapping) < 30:
        print(f"[WARNING] Only found {len(dept_mapping)} departments - this seems low")
        print("[WARNING] The page structure may have changed")
    
    return dept_mapping


def is_valid_course(course_name: str) -> bool:
    """
    Check if the course name is valid (not a navigation link or empty).
    Valid courses typically have a course code pattern like "ABC 123".
    """
    if not course_name or len(course_name) < 5:
        return False
    
    # Invalid entries to filter out
    invalid_entries = [
        "course search",
        "registration",
        "home",
        "back to top",
        "print",
        "help",
        "add to favorites",
        "share this page",
        "forward"
    ]
    
    if course_name.lower().strip() in invalid_entries:
        return False
    
    # Check for "Forward ##" pattern (pagination links)
    if re.match(r"^forward\s+\d+$", course_name, re.I):
        return False
    
    # Valid courses should have a code pattern (ABC 123)
    return bool(re.search(r"^[A-Z]{2,4}\s*\d{3}", course_name))


def deduplicate(courses: List[Dict[str, str]]) -> List[Dict[str, str]]:
    """Remove duplicate courses based on course name."""
    seen = set()
    unique_courses = []
    
    for course in courses:
        # Normalize course name for comparison
        key = course["CourseName"].lower().strip()
        
        if key not in seen and key:
            seen.add(key)
            unique_courses.append(course)
    
    return unique_courses


def apply_department_mapping(courses: List[Dict[str, str]], dept_mapping: Dict[str, str]) -> List[Dict[str, str]]:
    """
    Apply department mapping to courses.
    Returns courses with Department field added.
    """
    courses_with_depts = []
    
    for course in courses:
        prefix = extract_course_prefix(course["CourseName"])
        if prefix:
            department = dept_mapping.get(prefix, prefix)
        else:
            department = "Unknown"
        
        courses_with_depts.append({
            "CourseName": course["CourseName"],
            "Department": department
        })
    
    return courses_with_depts


def save_json(data: Union[List[Dict[str, str]], Dict[str, str]], filename: str) -> None:
    """Save data to JSON file."""
    with open(filename, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


def save_csv(data: List[Dict[str, str]], filename: str) -> None:
    """Save data to CSV file with CourseName and Department columns."""
    fieldnames = ["CourseName", "Department"]
    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore", quoting=csv.QUOTE_ALL)
        writer.writeheader()
        writer.writerows(data)


def main() -> None:
    """Main scraping workflow with multi-page support."""
    print(f"[INFO] Starting USM course catalog scraper")
    print(f"[INFO] Using filtered course listing URL with pagination")
    
    # Step 1: Fetch first page to detect pagination and build department mapping
    print(f"\n[STEP 1] Fetching first page...")
    first_page_url = BASE_URL.format(page=1)
    html = fetch_page(first_page_url)
    
    if html is None:
        print("[FATAL] Could not fetch the page. Exiting.")
        print("\n[TROUBLESHOOTING]")
        print("1. Try installing cloudscraper: pip install cloudscraper")
        print("2. Visit the URL in your browser first to verify it loads")
        print("3. Check if the URL is correct and accessible")
        return
    
    print(f"[INFO] Successfully fetched first page ({len(html)} characters)")
    
    # Detect total pages
    total_pages = detect_total_pages(html)
    print(f"[INFO] Will scrape {total_pages} page(s)")
    
    # Build department mapping from first page
    print("\n[STEP 2] Building department mapping...")
    dept_mapping = build_department_mapping(html)
    save_json(dept_mapping, "departments.json")
    print(f"[SUCCESS] Saved {len(dept_mapping)} department mappings to departments.json")
    
    # Step 2: Scrape all pages
    print(f"\n[STEP 3] Scraping courses from {total_pages} page(s)...")
    all_courses_from_all_pages = []
    
    for page_num in range(1, total_pages + 1):
        # Use already fetched first page
        if page_num == 1:
            page_html = html
        else:
            print(f"[INFO] Fetching page {page_num}/{total_pages}...")
            page_url = BASE_URL.format(page=page_num)
            page_html = fetch_page(page_url)
            
            if page_html is None:
                print(f"[WARNING] Could not fetch page {page_num}, skipping...")
                continue
            
            # Rate limiting: wait between requests
            if page_num < total_pages:
                time.sleep(DELAY_BETWEEN_PAGES)
        
        # Parse courses from this page
        page_courses = parse_courses(page_html)
        
        if page_courses:
            print(f"[INFO] Page {page_num}: Found {len(page_courses)} course entries")
            all_courses_from_all_pages.extend(page_courses)
        else:
            print(f"[WARNING] Page {page_num}: No courses found")
    
    if not all_courses_from_all_pages:
        print("[ERROR] No courses found on any page. The page structure may be different than expected.")
        print("[ACTION] Please inspect the page HTML manually and update the parsing logic.")
        return
    
    print(f"\n[INFO] Total course entries from all pages: {len(all_courses_from_all_pages)}")
    
    # Step 3: Filter valid courses
    print("\n[STEP 4] Filtering valid courses...")
    valid_courses = [c for c in all_courses_from_all_pages if is_valid_course(c["CourseName"])]
    filtered_count = len(all_courses_from_all_pages) - len(valid_courses)
    print(f"[INFO] Found {len(valid_courses)} valid courses (filtered out {filtered_count} non-course entries)")
    
    # Step 4: Save raw data
    save_json(valid_courses, "courses_raw.json")
    print(f"[SUCCESS] Saved {len(valid_courses)} courses to courses_raw.json")
    
    # Step 5: Deduplicate
    print("\n[STEP 5] Deduplicating courses...")
    unique_courses = deduplicate(valid_courses)
    duplicates_removed = len(valid_courses) - len(unique_courses)
    print(f"[INFO] After deduplication: {len(unique_courses)} unique courses (removed {duplicates_removed} duplicates)")
    
    # Step 6: Apply department mapping
    print("\n[STEP 6] Applying department mapping...")
    courses_with_depts = apply_department_mapping(unique_courses, dept_mapping)
    
    # Step 7: Save cleaned data
    save_csv(courses_with_depts, "courses_cleaned.csv")
    print(f"[SUCCESS] Saved {len(courses_with_depts)} courses to courses_cleaned.csv")
    
    # Print summary
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    print(f"Pages scraped: {total_pages}")
    print(f"Total course entries found: {len(all_courses_from_all_pages)}")
    print(f"Valid courses: {len(valid_courses)}")
    print(f"Unique courses: {len(unique_courses)}")
    print(f"Department mappings: {len(dept_mapping)}")
    
    # Count by department
    dept_counts = {}
    for course in courses_with_depts:
        dept = course["Department"]
        dept_counts[dept] = dept_counts.get(dept, 0) + 1
    
    print(f"\nTop 10 departments by course count:")
    for dept, count in sorted(dept_counts.items(), key=lambda x: x[1], reverse=True)[:10]:
        print(f"  {dept}: {count}")
    
    if len(dept_counts) > 10:
        print(f"  ... and {len(dept_counts) - 10} more departments")
    
    # Warn about unknown departments
    unknown_count = dept_counts.get("Unknown", 0)
    if unknown_count > 0:
        print(f"\n[WARNING] {unknown_count} courses have 'Unknown' department")
        print("[ACTION] You may need to manually review departments.json and update the mapping")
    
    print("\n[COMPLETE] Scraping finished successfully!")


if __name__ == "__main__":
    main()
