#!/usr/bin/env python3
import sys, io, json, re, urllib.request, time
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

LANGUAGES = {
    "en": ("English", "https://awdemehret.org/apps/book/viewBook.php?bid=pse"),
    "am": ("Amharic",  "https://awdemehret.org/apps/book/viewBook.php?bid=psa"),
    "ge": ("Ge'ez",    "https://awdemehret.org/apps/book/viewBook.php?bid=psg"),
}

def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return resp.read().decode("utf-8", errors="replace")

def extract_page_text(html):
    return re.findall(
        r'<tr>\s*<td>\s*<div[^>]*id="pageText"[^>]*>(.*?)</div>\s*</td>\s*</tr>',
        html, re.DOTALL
    )

def parse_paragraphs(block):
    paras = re.findall(r'<p[^>]*>(.*?)</p>', block, re.DOTALL)
    texts = []
    for p in paras:
        text = re.sub(r'<[^>]+>', '', p).strip()
        if text:
            texts.append(text)
    return texts

def extract_psalm_number(text):
    m = re.match(r'^(\d+)\s+(.*)$', text, re.DOTALL)
    if m:
        return int(m.group(1)), m.group(2).strip()
    return None, text

all_data = {}
for lang_code, (lang_name, base_url) in LANGUAGES.items():
    print(f"Scraping {lang_name} page 1...")
    html = fetch(f"{base_url}&pg=1")
    blocks = extract_page_text(html)
    verses = {}
    for block in blocks:
        for text in parse_paragraphs(block):
            vnum, content = extract_psalm_number(text)
            if vnum is not None:
                verses[vnum] = content
    all_data[lang_code] = {1: verses}
    print(f"  {lang_name}: Psalm 1 has {len(verses)} verses")
    time.sleep(0.5)

print()
with open("test_sample.json", "w", encoding="utf-8") as f:
    json.dump(all_data, f, ensure_ascii=False, indent=2)
print("Saved to test_sample.json")
print()
for lang_code, (lang_name, _) in LANGUAGES.items():
    print(f"=== {lang_name} (Psalm 1) ===")
    for vnum in sorted(all_data[lang_code][1].keys()):
        print(f"  v{vnum}: {all_data[lang_code][1][vnum][:100]}")
    print()