#Code generated from Claude AI

import requests
from bs4 import BeautifulSoup
import pandas as pd
import time
import random
import string
import re
import json
from urllib.parse import urljoin

BASE = "https://usm.maine.edu/directories/faculty/page/{}"
DOMAIN = "https://usm.maine.edu"
HEADERS = {"User-Agent": "Mozilla/5.0"}

profile_urls = []
raw_results = []   # raw data → faculty_raw.json
results = []       # cleaned data → faculty_cleaned.csv

# -----------------------
# UTILITIES
# -----------------------
def generate_user_id():
    return random.randint(100000000, 999999999)

def generate_password(length=12):
    chars = string.ascii_letters + string.digits + "!@#$%&*"
    return "".join(random.choice(chars) for _ in range(length))

def split_name(name):
    if not name:
        return None, None
    parts = name.strip().split()
    return parts[0], " ".join(parts[1:]) if len(parts) > 1 else ""

def clean_text(t):
    if not t:
        return None
    # strip pronoun blocks in parentheses, e.g. (he/him), (she/her/hers), (they/them/theirs)
    t = re.sub(r"\([\w/\s,]+\)", "", t, flags=re.I)
    t = re.sub(r"\S+@\S+", "", t)
    t = re.sub(r"\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}", "", t)
    return re.sub(r"\s+", " ", t).strip()

# -----------------------
# LIMIT TO MAIN CONTENT ONLY
# -----------------------
def get_main_content(soup):
    selectors = [
        "main",
        "article",
        ".node__content",
        ".layout__region",
        ".region-content"
    ]
    for sel in selectors:
        el = soup.select_one(sel)
        if el:
            return el
    return soup

# -----------------------
# SECTION SPLITTER
# -----------------------
def split_sections(container):
    sections = {}
    current = "bio"
    for el in container.find_all(["h2", "h3", "strong", "p", "div"], recursive=True):
        txt = el.get_text(" ", strip=True)
        if not txt:
            continue
        if txt.lower() in ["education", "research interests", "selected publications", "courses"]:
            current = txt.lower()
            continue
        sections.setdefault(current, [])
        sections[current].append(txt)
    return sections

# -----------------------
# TITLE + DEPT
# -----------------------
def extract_title_department(sections):
    bio = " ".join(sections.get("bio", []))
    bio = re.sub(r"education.*", "", bio, flags=re.I)

    # --- Title ---
    match = re.search(r"((?:assistant|associate|clinical|adjunct|visiting)?\s*professor|lecturer|chair)", bio, re.I)
    title = match.group(1).strip() if match else None

    # --- Department ---
    dept = None

    # Pattern 1: "Department of X" or "School of X"
    dept_match = re.search(r"((?:department|school|college) of [^.,]+)", bio, re.I)
    if dept_match:
        dept = dept_match.group(1).strip()

    # Pattern 2: "Professor of X" — extract the subject after "of"
    if not dept:
        prof_of = re.search(r"professor of ([^.,\n]+)", bio, re.I)
        if prof_of:
            dept = prof_of.group(1).strip()

    # Pattern 3: "X Professor" — the word(s) before "Professor" describe the field
    if not dept:
        field_match = re.search(r"([A-Z][a-zA-Z\s]+?)\s+(?:Assistant |Associate |Clinical |Adjunct )?Professor\b", bio)
        if field_match:
            candidate = field_match.group(1).strip()
            # filter out noise like the person's name or generic words
            if len(candidate.split()) <= 5 and candidate.lower() not in ("the", "a", "an", "is", "and"):
                dept = candidate

    return clean_text(title), clean_text(dept)

# -----------------------
# PHONE
# -----------------------
def extract_phone(container):
    text = container.get_text(" ", strip=True)
    matches = re.findall(r'\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}', text)
    for m in matches:
        if "800-800-4876" not in m:
            return m
    return None

# -----------------------
# STEP 1: COLLECT URLs
# -----------------------
page = 1

while True:
    url = BASE.format(page)
    r = requests.get(url, headers=HEADERS)
    soup = BeautifulSoup(r.text, "html.parser")

    cards = soup.select("a[href*='/directories/people/']")

    if not cards:
        break

    for c in cards:
        link = urljoin(DOMAIN, c.get("href"))
        if link not in profile_urls:
            profile_urls.append(link)

    if len(profile_urls) >= 50:
        break

    page += 1
    time.sleep(0.2)

profile_urls = profile_urls[:50]

# -----------------------
# STEP 2: SCRAPE PROFILES
# -----------------------
for i, url in enumerate(profile_urls):
    print(f"[{i + 1}/50] Scraping: {url}")

    r = requests.get(url, headers=HEADERS)
    soup = BeautifulSoup(r.text, "html.parser")

    container = get_main_content(soup)

    # NAME
    name_tag = container.find("h1")
    full_name = name_tag.get_text(strip=True) if name_tag else None
    first, last = split_name(full_name)

    # EMAIL
    email_tag = container.select_one("a[href^='mailto:']")
    email = email_tag.get_text(strip=True) if email_tag else None

    # PHONE (raw — uncleaned)
    phone = extract_phone(container)

    # RAW BIO TEXT (saved as-is for the JSON)
    raw_bio = container.get_text(" ", strip=True)

    # ── Save raw record BEFORE any cleaning ──────────────────────────────────
    raw_results.append({
        "source_url": url,
        "full_name": full_name,
        "email": email,
        "phone": phone,
        "raw_bio_text": raw_bio[:1000]  # first 1000 chars to keep file manageable
    })

    # ── Now clean and extract structured fields ───────────────────────────────
    sections = split_sections(container)
    title, department = extract_title_department(sections)

    results.append({
        "UserID": generate_user_id(),
        "FirstName": first,
        "LastName": last,
        "Title": title,
        "Department": department,
        "Email": email,
        "Password": generate_password(),
        "PhoneNumber": phone
    })

    time.sleep(0.2)

# -----------------------
# SAVE RAW → JSON
# -----------------------
with open("faculty_raw.json", "w", encoding="utf-8") as f:
    json.dump(raw_results, f, indent=2, ensure_ascii=False)

print(f"Saved faculty_raw.json ({len(raw_results)} records)")

# -----------------------
# SAVE CLEANED → CSV
# -----------------------
df = pd.DataFrame(results)
df.to_csv("faculty_cleaned.csv", index=False)

print(f"Saved faculty_cleaned.csv ({len(df)} records)")
