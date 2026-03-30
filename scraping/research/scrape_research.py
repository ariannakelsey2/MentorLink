import requests
from bs4 import BeautifulSoup
import csv
import json

url = "https://en.wikipedia.org/wiki/List_of_academic_fields"

headers = {
    "User-Agent": "Mozilla/5.0"
}
response = requests.get(url, headers=headers)

soup = BeautifulSoup(response.text, "html.parser")

# list to store subject names and their IDs
subjects = []
# find all h3 and h4 tags to get the subtopics
h_sub_topics = soup.find_all(["h3", "h4"])
# filter relevant subtopics
target_ids = ["History", "Philosophy", "Psychology", "Languages and Literature", "Business",
              "Economics", "Geography", "Political_science", "Physics", "Chemistry", "Biology",
              "Computer_science", "Pure_mathematics", "Applied_mathematics", "Statistics"]

# loop through headers
for h in h_sub_topics:
    # placeholder for Subject ID
    subject_id = ""
    department_name = h.get_text(strip=True)
    # skip headers that are not in the target list
    if h.get("id") not in target_ids:
        continue
    # find the next div with class "div-col" which contains the list of subjects
    text = h.find_next("div", class_="div-col")
    # find all lists inside the div
    ul_elements = text.find_all("ul")
    for ul in ul_elements:
            # loop through list items and extratct subject names
            for li in ul.find_all("li"):
                text = li.get_text(strip=True, separator=" ")
                # only extrat the text inside the link 
                if li.find("a"):
                    text = li.find("a").get_text(strip=True)
                    # store the tuple in the list
                subjects.append((subject_id, text, department_name))
# remove duplicates using set
subjects = list(set(subjects))

print(f"\nTotal subjects: {len(subjects)}\n")

# print the tuple (SubjectID, SubjectName)
for s in subjects:
    print(s)

# create json file
with open("/Users/hananali/Documents/research_raw.json", mode="w", encoding="utf-8") as write_file:
    json.dump(subjects, write_file)

# create csv file
with open("/Users/hananali/Documents/research_cleaned.csv", mode="w", encoding="utf-8", newline="") as csv_file:
    writer = csv.writer(csv_file)
    writer.writerow(["SubjectID", "SubjectName", "DepartmentName"])

    for subject in subjects:
        writer.writerow(subject)
