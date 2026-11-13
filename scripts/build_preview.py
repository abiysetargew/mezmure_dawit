import json, os

with open('preview_en.json','r',encoding='utf-8') as f: en = json.load(f)
with open('preview_am.json','r',encoding='utf-8') as f: am = json.load(f)
with open('preview_ge.json','r',encoding='utf-8') as f: ge = json.load(f)

en_data = json.dumps(en['en'], ensure_ascii=False)
am_data = json.dumps(am['am'], ensure_ascii=False)
ge_data = json.dumps(ge['ge'], ensure_ascii=False)

html = '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Psalms Preview - Awdemehret.org</title>
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'Segoe UI', Arial, sans-serif; background: #f5f5f5; color: #222; }
.hdr { background: linear-gradient(135deg,#1a4a1a,#2d7a2d); color: #fff; padding: 20px; text-align: center; }
.hdr h1 { font-size: 1.5em; }
.hdr p { font-size: 0.85em; opacity: 0.8; margin-top: 5px; }
.tabs { display: flex; background: #fff; border-bottom: 3px solid #1a4a1a; position: sticky; top: 0; z-index: 10; }
.tab { flex: 1; padding: 14px 8px; text-align: center; cursor: pointer; font-weight: 600; font-size: 0.95em; transition: all 0.2s; }
.tab:hover { background: #f0f0f0; }
.tab.active { background: #1a4a1a; color: #fff; }
.psalm-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 16px; padding: 16px; }
.psalm-card { background: #fff; border-radius: 10px; padding: 16px; cursor: pointer; box-shadow: 0 2px 8px rgba(0,0,0,0.1); transition: transform 0.2s, box-shadow 0.2s; }
.psalm-card:hover { transform: translateY(-2px); box-shadow: 0 4px 16px rgba(0,0,0,0.15); }
.psalm-num { font-size: 1.8em; font-weight: bold; color: #1a4a1a; margin-bottom: 6px; }
.psalm-prev { font-size: 0.85em; color: #555; line-height: 1.5; max-height: 4.5em; overflow: hidden; }
.expanded { display: none; }
.expanded.open { display: block; margin-top: 14px; border-top: 1px solid #ddd; padding-top: 12px; }
.expanded .verse { padding: 5px 0; border-bottom: 1px solid #eee; font-size: 0.9em; line-height: 1.6; }
.expanded .vnum { font-weight: bold; color: #1a4a1a; margin-right: 8px; min-width: 24px; display: inline-block; }
.lang-badge { display: inline-block; padding: 2px 8px; border-radius: 12px; font-size: 0.7em; margin-bottom: 6px; }
.lang-en { background: #e8f5e9; color: #1a4a1a; }
.lang-am { background: #fff3e0; color: #e65100; }
.lang-ge { background: #e3f2fd; color: #1565c0; }
.legend { text-align: center; padding: 12px; font-size: 0.8em; color: #666; }
.legend span { margin: 0 10px; }
</style>
</head>
<body>
<div class="hdr"><h1>mezmure_dawit - Awdemehret.org Data</h1><p>Scraped: June 2026 | 150 Psalms x 3 Languages</p></div>
<div class="tabs">
  <div class="tab active" id="tab-en" onclick="switchLang('en')">English (2,460 verses)</div>
  <div class="tab" id="tab-am" onclick="switchLang('am')">አማርኛ (2,441 verses)</div>
  <div class="tab" id="tab-ge" onclick="switchLang('ge')">ግዕዝ (2,621 verses)</div>
</div>
<div class="legend">
  <span>✓ English = no embedded verse numbers</span>
  <span>• Amharic = HTML entities (ብፁዕ... format)</span>
  <span>• Ge'ez = Ge'ez script (ብፁዕ... format)</span>
</div>
<div id="grid" class="psalm-grid"></div>
<script>
var DATA = {en: ''' + en_data + ''', am: ''' + am_data + ''', ge: ''' + ge_data + '''};
var curLang = 'en';
function switchLang(lang) {
  curLang = lang;
  document.getElementById('tab-en').classList.toggle('active', lang==='en');
  document.getElementById('tab-am').classList.toggle('active', lang==='am');
  document.getElementById('tab-ge').classList.toggle('active', lang==='ge');
  render();
}
function render() {
  var grid = document.getElementById('grid');
  var psalms = DATA[curLang];
  var html = '';
  for (var n in psalms) {
    var verses = psalms[n];
    var firstFew = Object.values(verses).slice(0,3).join(' ');
    var total = Object.keys(verses).length;
    var badge = curLang==='en'?'EN':curLang==='am'?'አማ':'ግዕ';
    var cls = curLang==='en'?'lang-en':curLang==='am'?'lang-am':'lang-ge';
    html += '<div class="psalm-card" onclick="toggleCard(this)"><span class="lang-badge '+cls+'">'+badge+'</span><div class="psalm-num">Psalm '+n+'</div><div class="psalm-prev">'+total+' verses — '+firstFew+'</div><div class="expanded" id="exp-'+n+'"></div></div>';
  }
  grid.innerHTML = html;
  document.querySelectorAll('.expanded').forEach(function(el) {
    var id = el.id.split('-')[1];
    var v = DATA[curLang][id];
    el.innerHTML = Object.entries(v).map(function(entry) {
      return '<div class="verse"><span class="vnum">'+entry[0]+'.</span>'+entry[1]+'</div>';
    }).join('');
  });
}
function toggleCard(card) {
  var exp = card.querySelector('.expanded');
  exp.classList.toggle('open');
}
render();
</script>
</body>
</html>'''

with open('preview.html','w',encoding='utf-8') as f: f.write(html)
print('Written preview.html')
print('Size:', os.path.getsize('preview.html'), 'bytes')
print('EN verses total:', sum(len(v) for v in en['en'].values()))
print('AM verses total:', sum(len(v) for v in am['am'].values()))
print('GE verses total:', sum(len(v) for v in ge['ge'].values()))