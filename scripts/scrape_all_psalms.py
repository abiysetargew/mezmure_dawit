#!/usr/bin/env python3
"""Fetch all 150 Amharic psalms from wordpocket.com."""

import re
import json
import urllib.request
import time

BASE_URL = "https://wordpocket.com/lang_texts/am/19/{n}.htm"

def fetch_psalm(n: int) -> list[dict]:
    url = BASE_URL.format(n=n)
    try:
        with urllib.request.urlopen(url, timeout=10) as resp:
            html = resp.read().decode("utf-8", errors="replace")
    except Exception:
        return []
    verses = []
    verse_pattern = re.compile(
        r'<SPAN class="verse" id="(\d+)">\s*(\d+)</SPAN><a name="\d+">\s*(.+?)</a>',
        re.DOTALL
    )
    for m in verse_pattern.finditer(html):
        verse_num = int(m.group(1))
        text = re.sub(r'\s+', ' ', m.group(3).strip())
        text = re.sub(r'[\u00a0\u200b\u200c\u200d]+', '', text)
        if text and len(text) > 2:
            verses.append({"n": verse_num, "am": text, "ge": "", "en": ""})
    return verses

def main():
    all_data = []
    for i in range(1, 151):
        verses = fetch_psalm(i)
        status = f"OK {len(verses)}v" if verses else "FAIL"
        print(f"{i:3d}/{150}: {status}")
        all_data.append({"num": i, "verses": verses})
        time.sleep(0.1)

    result = []
    for item in all_data:
        verses = item["verses"]
        num = item["num"]
        result.append({
            "id": num,
            "title": f"መዝሙር {num}",
            "day": ["እሑድ (Sunday)", "ሰኞ (Monday)", "ማክሰኞ (Tuesday)",
                    "ረቡዕ (Wednesday)", "ሐሙስ (Thursday)",
                    "ዓርብ (Friday)", "ቅዳሜ (Saturday)"][(num - 1) % 7],
            "tags": (["Morning"] if num <= 41 else (["Daylight"] if num <= 119 else ["Evening"])),
            "verses": verses
        })

    with open("fetched_psalms.json", "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)

    total = sum(1 for item in all_data if item["verses"])
    total_verses = sum(len(item["verses"]) for item in all_data)
    print(f"\n{total}/150 psalms, {total_verses} verses -> fetched_psalms.json")

if __name__ == "__main__":
    main()
