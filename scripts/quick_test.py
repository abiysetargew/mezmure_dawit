#!/usr/bin/env python3
import sys, io, re, urllib.request
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

req = urllib.request.Request(
    'https://awdemehret.org/apps/book/viewBook.php?bid=pse&pg=1',
    headers={'User-Agent': 'Mozilla/5.0'}
)
with urllib.request.urlopen(req, timeout=15) as resp:
    html = resp.read().decode('utf-8', errors='replace')

pattern = r'<tr>\s*<td>\s*<div[^>]*id="pageText"[^>]*>(.*?)</div>\s*</td>\s*</tr>'
blocks = re.findall(pattern, html, re.DOTALL)
print(f'Blocks: {len(blocks)}')
for i, b in enumerate(blocks[:2]):
    paras = re.findall(r'<p[^>]*>(.*?)</p>', b, re.DOTALL)
    texts = [re.sub(r'<[^>]+>', '', p).strip() for p in paras if re.sub(r'<[^>]+>', '', p).strip()]
    print(f'Block {i+1}: {len(texts)} paragraphs')
    print(f'  First: {texts[0][:60]}...')