#!/usr/bin/env python3
"""Decode HTML entities in fetched_awdemehret.json and show sample."""
import sys, io, json, html
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

with open("fetched_awdemehret.json", encoding="utf-8") as f:
    data = json.load(f)

for lang in ["en", "am", "ge"]:
    print(f"\n=== {lang.upper()} ===")
    for pnum in [1, 2, 3]:
        ps = data[lang][str(pnum)]
        print(f"\nPsalm {pnum}:")
        for vnum in sorted(ps.keys())[:2]:
            text = html.unescape(ps[str(vnum)])
            print(f"  v{vnum}: {text[:80]}...")

print("\n\nJSON structure is valid. To view in browser, serve with UTF-8 encoding.")