#!/usr/bin/env python3
"""
Scraper for awdemehret.org - fetches all 150 psalms in 3 languages:
  English: bid=pse
  Amharic: bid=psa
  Ge'ez:   bid=psg

Each page &pg=N contains ALL 150 psalms as table rows.
Row N-1 contains Psalm N content (0-indexed).
"""
import sys, io, json, re, time, html, urllib.request
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


def get_page_blocks(html):
    return re.findall(
        r'<tr>\s*<td>\s*<div[^>]*id="pageText"[^>]*>(.*?)</div>\s*</td>\s*</tr>',
        html, re.DOTALL
    )


def parse_verses(block):
    paras = re.findall(r'<p[^>]*>(.*?)</p>', block, re.DOTALL)
    texts = []
    for p in paras:
        text = re.sub(r'<[^>]+>', '', p).strip()
        text = html.unescape(text).strip()
        if text:
            texts.append(text)
    return texts


def extract_with_number(text):
    # Handles "12  ...", "v37 ...", "8-9 ...", "13-14 ..." (combined verse
    # ranges in the Amharic book). Ranges expand to every verse they cover.
    m = re.match(r'^(?:v\s*)?(\d+)(?:\s*-\s*(\d+))?\s*[፡።.፦:]*\s*(.*)$', text, re.DOTALL)
    if m:
        first = int(m.group(1))
        if m.group(2):
            last = int(m.group(2))
            return (first, last, m.group(3).strip())
        return (first, None, m.group(3).strip())
    return (None, None, text)


def scrape_language(lang_code, lang_name, base_url):
    print(f"\n{'='*60}")
    print(f"Scraping {lang_name} ({lang_code})...")
    print(f"{'='*60}")

    url = f"{base_url}&pg=1"
    html_text = fetch(url)
    blocks = get_page_blocks(html_text)

    print(f"  Fetched page, got {len(blocks)} blocks (psalms)")

    psalms = {}
    suspicious = []
    for idx, block in enumerate(blocks):
        psalm_num = idx + 1
        texts = parse_verses(block)

        if lang_code == "en":
            # English paragraphs are unnumbered and the block ends with a
            # trailing "…Psalm N <superscription>" heading that belongs to
            # the next psalm — strip it from every paragraph.
            texts = [re.sub(r'\s*Psalm\s+\d+\b.*$', '', t).strip() for t in texts]
            texts = [t for t in texts if t]

        verses = {}
        if texts:
            if lang_code == "en":
                for i, text in enumerate(texts, 1):
                    verses[i] = text
            else:
                for text in texts:
                    vnum, vend, content = extract_with_number(text)
                    if vnum is not None:
                        for n in range(vnum, (vend or vnum) + 1):
                            verses[n] = content
                    else:
                        if verses:
                            verses[max(verses.keys())] += " " + text
                            suspicious.append((psalm_num, text[:60]))
                        else:
                            verses[1] = text

        psalms[psalm_num] = verses
        if psalm_num <= 3 or (psalm_num <= 10 and len(verses) > 0):
            print(f"  Psalm {psalm_num}: {len(verses)} verses")

    if suspicious:
        print(f"  WARNING: {len(suspicious)} unnumbered paragraphs merged into previous verse:")
        for psalm, snippet in suspicious:
            print(f"    psalm {psalm}: {snippet}")

    return psalms


def main():
    all_data = {}
    for lang_code, (lang_name, base_url) in LANGUAGES.items():
        psalms = scrape_language(lang_code, lang_name, base_url)
        all_data[lang_code] = psalms
        total_psalms = len(psalms)
        total_verses = sum(len(v) for v in psalms.values())
        print(f"\n  {lang_name} total: {total_psalms} psalms, {total_verses} verses")
        time.sleep(1)

    output_file = "fetched_awdemehret.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(all_data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*60}")
    print(f"Saved to {output_file}")
    for lang_code, (lang_name, _) in LANGUAGES.items():
        psalms = all_data[lang_code]
        total_psalms = len(psalms)
        total_verses = sum(len(v) for v in psalms.values())
        print(f"  {lang_name}: {total_psalms} psalms, {total_verses} verses")

    print(f"\nSample Psalm 1 verses:")
    for lang_code, (lang_name, _) in LANGUAGES.items():
        psalms = all_data[lang_code]
        if 1 in psalms and psalms[1]:
            print(f"\n  {lang_name}:")
            for vnum in sorted(psalms[1].keys())[:3]:
                print(f"    v{vnum}: {psalms[1][vnum][:80]}...")


if __name__ == "__main__":
    main()