import json, sys
sys.stdout.reconfigure(encoding='utf-8')
d=json.load(open('assets/psalms.json','r',encoding='utf-8'))
v=d[0]['verses'][0]['am']
print('AM verse 1 chars (first 20):', [c for c in v[:20]])
print('AM verse 1 repr:', repr(v[:80]))
print('Has HTML entities?', '&#' in v)
print('Length:', len(v))