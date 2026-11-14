import json, sys, re
sys.stdout.reconfigure(encoding='utf-8')

ours_path = 'assets/psalms.json'
site_path = 'fetched_awdemehret.json'
ours = json.load(open(ours_path, encoding='utf-8'))
site = json.load(open(site_path, encoding='utf-8'))

def norm(s):
    return re.sub(r'\s+', ' ', (s or '').strip())

def strip_en_junk(t):
    return re.sub(r'\s*Psalm\s+\d+\b.*$', '', t).strip()

def norm_lang(t, lang):
    if lang == 'en':
        t = strip_en_junk(t)
    return norm(t)

stats = {}
mismatches = []
fills = 0
updates_junk = 0
junk_chars_removed = 0
no_site_rows = 0
for lang in ['am', 'en', 'ge']:
    counts = {'match': 0, 'fill': 0, 'update': 0, 'mismatch': 0, 'no_site': 0}
    for p in ours:
        pid = str(p['id'])
        smap = {int(k): norm(v) for k, v in site[lang].get(pid, {}).items()}
        for row in p['verses']:
            n = row['n']
            key = n
            s = smap.get(key)
            t = norm_lang(row.get(lang), lang)
            if s is None:
                if t:
                    counts['no_site'] += 1
                else:
                    counts['no_site'] += 1  # permanently unavailable = fine
                continue
            if not t:
                counts['fill'] += 1
            elif t == s:
                counts['match'] += 1
            elif lang == 'en':
                raw = row['en']
                stripped = strip_en_junk(raw)
                if norm(stripped) == s:
                    counts['update'] += 1
                else:
                    counts['mismatch'] += 1
                    if len(mismatches) < 12:
                        mismatches.append((p['id'], lang, n, norm(raw)[:90], s[:90]))
            else:
                counts['mismatch'] += 1
                if len(mismatches) < 12:
                    mismatches.append((p['id'], lang, n, t[:90], s[:90]))
    stats[lang] = counts

for lang, c in stats.items():
    print(lang.upper(), c)
print()
print('mismatch/update examples (up to 12):')
for m in mismatches:
    print(f'  psalm {m[0]} {m[1]} v{m[2]}')
    print(f'    ours: {m[3]}')
    print(f'    site: {m[4]}')
