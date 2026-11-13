import json, html

with open('preview_en.json','r',encoding='utf-8') as f: en = json.load(f)['en']
with open('preview_am.json','r',encoding='utf-8') as f: am = json.load(f)['am']
with open('preview_ge.json','r',encoding='utf-8') as f: ge = json.load(f)['ge']

days = [
    "እሑድ (Sunday)",
    "ሰኞ (Monday)",
    "ማክሰኞ (Tuesday)",
    "ረቡዕ (Wednesday)",
    "ሐሙስ (Thursday)",
    "ዓርብ (Friday)",
    "ቅዳሜ (Saturday)"
]

tags_by_psalm = {i: (["Morning"] if i<=41 else ["Daylight"] if i<=119 else ["Evening"]) + (["Praise"] if i in [1,19,45,100,103,104,105,106,107,111,113,114,115,118,136,146,147,150] else []) for i in range(1,151)}

psalms = []
for i in range(1, 151):
    verses = []
    en_v = en[str(i)]
    am_v = am[str(i)]
    ge_v = ge[str(i)]

    all_verse_nums = sorted(set(list(en_v.keys()) + list(am_v.keys()) + list(ge_v.keys())), key=lambda x: int(x))
    for n in all_verse_nums:
        verses.append({
            "n": int(n),
            "am": html.unescape(am_v.get(str(n), "")),
            "ge": html.unescape(ge_v.get(str(n), "")),
            "en": en_v.get(str(n), "")
        })

    psalms.append({
        "id": i,
        "title": f"መዝሙር {i}",
        "day": days[(i-1) % 7],
        "tags": tags_by_psalm[i],
        "verses": verses
    })

with open('assets/psalms.json','w',encoding='utf-8') as f:
    json.dump(psalms, f, ensure_ascii=False, indent=2)

total_verses = sum(len(p['verses']) for p in psalms)
print(f"Written {len(psalms)} psalms, {total_verses} total verses")
print(f"Total Amharic verses: {sum(len(am[str(i)]) for i in range(1,151))}")
print(f"Total Ge'ez verses: {sum(len(ge[str(i)]) for i in range(1,151))}")
print(f"Total English verses: {sum(len(en[str(i)]) for i in range(1,151))}")