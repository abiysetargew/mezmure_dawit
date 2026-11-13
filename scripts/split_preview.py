#!/usr/bin/env python3
"""Split fetched_awdemehret.json into per-language files for preview."""
import json, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

with open("fetched_awdemehret.json", encoding="utf-8") as f:
    data = json.load(f)

for lang in ["en", "am", "ge"]:
    with open(f"preview_{lang}.json", "w", encoding="utf-8") as f:
        json.dump({lang: data[lang]}, f, ensure_ascii=False, indent=2)
    name = {"en": "English", "am": "Amharic", "ge": "Ge'ez"}[lang]
    psalms = data[lang]
    total = sum(len(v) for v in psalms.values())
    print(f"Wrote preview_{lang}.json - {len(psalms)} psalms, {total} verses")