#!/usr/bin/env python3
"""Merge fetched Amharic psalms with existing Ge'ez/English data."""

import json

with open("assets/psalms.json", encoding="utf-8") as f:
    existing = json.load(f)

with open("fetched_psalms.json", encoding="utf-8") as f:
    fetched = json.load(f)

geez_map = {}
for p in existing:
    for v in p.get("verses", []):
        geez_map[(p["id"], v["n"])] = (v.get("ge", ""), v.get("en", ""))

merged = []
for p in fetched:
    new_verses = []
    for v in p.get("verses", []):
        n = v["n"]
        existing_verse = geez_map.get((p["id"], n), (None, None))
        ge = existing_verse[0] if existing_verse[0] else v.get("ge", "")
        en = existing_verse[1] if existing_verse[1] else v.get("en", "")
        new_verses.append({
            "n": n,
            "am": v["am"],
            "ge": ge,
            "en": en
        })
    merged.append({
        "id": p["id"],
        "title": p["title"],
        "day": p["day"],
        "tags": p["tags"],
        "verses": new_verses
    })

with open("assets/psalms.json", "w", encoding="utf-8") as f:
    json.dump(merged, f, ensure_ascii=False, indent=2)

total_verses = sum(len(p["verses"]) for p in merged)
with_geez = sum(1 for p in merged for v in p["verses"] if v.get("ge"))
with_english = sum(1 for p in merged for v in p["verses"] if v.get("en"))
print(f"Merged: {len(merged)} psalms, {total_verses} verses")
print(f"With Ge'ez: {with_geez}, With English: {with_english}")
