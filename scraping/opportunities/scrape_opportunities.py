import csv
import json
import re
from typing import List, Dict, Optional

import requests
from bs4 import BeautifulSoup

HEADERS = {
    "User-Agent": "Mozilla/5.0 (compatible; MentorLinkScraper/1.0; +https://example.com)"
}

URLS = [
    "https://usm.maine.edu/career-employment-hub/career-exploration-program/",
    "https://usm.maine.edu/research/urop/",
    "https://usm.maine.edu/department-environmental-science-policy/environmental-science-policy-internship-program/",
    "https://usm.maine.edu/department-biological-sciences/research-opportunities/"
]


def fetch_page(url: str) -> Optional[str]:
    """Download one page and return HTML, or None if request fails."""
    try:
        response = requests.get(url, headers=HEADERS, timeout=15)
        response.raise_for_status()
        return response.text
    except requests.RequestException as e:
        print(f"[ERROR] Could not fetch {url}: {e}")
        return None


def clean_text(text: str) -> str:
    """Normalize whitespace."""
    if not text:
        return ""
    return re.sub(r"\s+", " ", text).strip()


def infer_type(url: str, title: str, description: str) -> str:
    """Infer opportunity type from URL/title/description."""
    combined = f"{url} {title} {description}".lower()

    if "internship" in combined:
        return "Internship"
    if "research" in combined or "urop" in combined:
        return "Research"
    if "scholarship" in combined:
        return "Scholarship"
    return "Other"


def infer_source_page(url: str) -> str:
    """Map URL to a short source section name."""
    lower = url.lower()
    if "career-employment-hub" in lower:
        return "Career & Employment Hub"
    if "/research/" in lower:
        return "Research"
    if "environmental-science-policy" in lower:
        return "Environmental Science and Policy"
    if "biological-sciences" in lower:
        return "Biological Sciences"
    return "USM"


def parse_page(html: str, url: str) -> Optional[Dict[str, str]]:
    """
    Extract a single opportunity-like record from a USM page.
    This page-based approach is more reliable than assuming repeating cards.
    """
    soup = BeautifulSoup(html, "html.parser")

    title = ""
    h1 = soup.find("h1")
    if h1:
        title = clean_text(h1.get_text())

    if not title and soup.title:
        title = clean_text(soup.title.get_text())

    paragraphs = []
    for p in soup.find_all("p"):
        text = clean_text(p.get_text())
        if text:
            paragraphs.append(text)

    description = " ".join(paragraphs[:3])  # first few paragraphs only
    description = clean_text(description)

    if len(description) > 500:
        description = description[:497] + "..."

    if not title:
        return None

    return {
        "Title": title,
        "Type": infer_type(url, title, description),
        "Organization": "University of Southern Maine",
        "SourcePage": infer_source_page(url),
        "URL": url,
        "Description": description
    }


def deduplicate(records: List[Dict[str, str]]) -> List[Dict[str, str]]:
    """Remove duplicates using title + URL."""
    seen = set()
    cleaned = []

    for record in records:
        key = (record["Title"].lower(), record["URL"].lower())
        if key not in seen:
            seen.add(key)
            cleaned.append(record)

    return cleaned


def save_json(data: List[Dict[str, str]], filename: str) -> None:
    with open(filename, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


def save_csv(data: List[Dict[str, str]], filename: str) -> None:
    fieldnames = ["Title", "Type", "Organization", "SourcePage", "URL", "Description"]
    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(data)


def main() -> None:
    raw_records = []

    for url in URLS:
        html = fetch_page(url)
        if html is None:
            continue

        record = parse_page(html, url)
        if record:
            raw_records.append(record)

    save_json(raw_records, "opportunities_raw.json")

    cleaned_records = deduplicate(raw_records)
    cleaned_records = [r for r in cleaned_records if r["Title"] and r["URL"]]

    save_csv(cleaned_records, "opportunities_cleaned.csv")

    print(f"[SUCCESS] Saved {len(raw_records)} raw records to opportunities_raw.json")
    print(f"[SUCCESS] Saved {len(cleaned_records)} cleaned records to opportunities_cleaned.csv")


if __name__ == "__main__":
    main()
