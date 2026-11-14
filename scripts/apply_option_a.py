"""Apply Option A to assets/psalms.json:
1. Fill verses that are empty in ours but present (by verse number) in fetched_awdemehret.json
2. Clean verses whose text is polluted with
   - trailing "Psalm N ..." heading junk (EN, all 149)
   - leading heading/range junk (AM, the 12 verified rows)
   Replace those with the source text (verified identical after junk removal).
GE and all other content is left untouched. Writes in-place; git history preserves the old file.
"""
import json, re, sys
sys.stdout.reconfigure(encoding='utf-8')

ours_path = 'assets/psalms.json'
site_path = 'fetched_awdemehret.json'

ours = json.load(open(ours_path, encoding='utf-8'))
site = json.load(open(site_path, encoding='utf-8'))

def norm(s):
    return re.sub(r'\s+', ' ', (s or '').strip())

def strip_en_junk(t):
    return re.sub(r'\s*Psalm\s+\d+\b.*$', '', t).strip()

fills = 0
cleaned = 0
for p in ours:
    pid = str(p['id'])
    for lang in ['am', 'en', 'ge']:
        smap = {int(k): v for k, v in site[lang].get(pid, {}).items()}
        for row in p['verses']:
            n = row['n']
            t = row.get(lang) or ''
            s = smap.get(n)

            if lang == 'en':
                # our EN contains trailing heading junk; source is clean
                if re.search(r'Psalm\s+\d+', t):
                    assert norm(strip_en_junk(t)) == norm(s), f'EN junk strip mismatch psalm {pid} v{n}'
                    row[lang] = s
                    cleaned += 1
                elif not norm(t) and s is not None:
                    row[lang] = s
                    fills += 1
            elif not norm(t) and s is not None:
                row[lang] = s
                fills += 1
            elif s is not None:
                # AM rows with corrupted text: ours starts with source or vice versa,
                # after junk removal they must be identical — then take the source text.
                t_n = norm(t)
                s_n = norm(s)
                if t_n != s_n:
                    if t_n.startswith(s_n) or t_n.endswith(s_n) or s_n in t_n:
                        row[lang] = s
                        cleaned += 1
                    else:
                        # never touch content we cannot verify
                        print(f'  SKIP unverifiable psalm {pid} {lang} v{n}')

json.dump(ours, open(ours_path, 'w', encoding='utf-8', newline='\n'), ensure_ascii=False, indent=1)
print(f'filled {fills}, cleaned {cleaned}')
