#!/usr/bin/env python3
"""Debug scraper - check if page 2 has different content."""
import sys, io, json, re, urllib.request
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return resp.read().decode("utf-8", errors="replace")

def extract_blocks(html):
    return re.findall(
        r'<tr>\s*<td>\s*<div[^>]*id="pageText"[^>]*>(.*?)</div>\s*</td>\s*</tr>',
        html, re.DOTALL
    )

for pg in [1, 2, 3, 4, 5]:
    for bid, name in [("pse", "EN"), ("psa", "AM"), ("psg", "GE")]:
        url = f"https://awdemehret.org/apps/book/viewBook.php?bid={bid}&pg={pg}"
        html = fetch(url)
        blocks = extract_blocks(html)
        total_verses = 0
        for b in blocks:
            paras = re.findall(r'<p[^>]*>(.*?)</p>', b, re.DOTALL)
            texts = [re.sub(r'<[^>]+>', '', p).strip() for p in paras if re.sub(r'<[^>]+>', '', p).strip()]
            total_verses += len(texts)
        print(f"  {name} pg{pg}: {len(blocks)} blocks, {total_verses} total verses")
    print()