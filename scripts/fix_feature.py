from PIL import Image, ImageDraw, ImageFont
import math

SRC = 'assets/feature.png'
OUT = 'store-assets/feature_graphic.png'   # final uploadable feature graphic

im = Image.open(SRC).convert('RGB')
W, H = im.size  # 1024x500

# --- 1) preserve the bottom-left textile/cloth overlay (drawn above strip) ---
overlay = im.crop((0, 380, 220, 434))

# --- 2) rebuild the bottom strip ---
navy = (13, 28, 53)      # deep navy matching brand
gold = (212, 168, 67)
gold_soft = (212, 168, 67, 150)

strip_top = 434
d = ImageDraw.Draw(im)
d.rectangle([0, strip_top, W, H], fill=navy)
# subtle vertical gradient on strip
for y in range(strip_top, H):
    t = (y - strip_top) / (H - strip_top)
    c = tuple(int(navy[i] * (1 - 0.35 * t)) for i in range(3))
    d.line([(0, y), (W, y)], fill=c)
# thin gold top border on strip
d.line([(0, strip_top), (W, strip_top)], fill=(212, 168, 67), width=2)

# cell dividers
for x in (256, 512, 768):
    d.line([(x, strip_top + 8), (x, H - 8)], fill=gold_soft, width=2)

# faint gold dot pattern on strip
for x in range(8, W, 26):
    for y in range(strip_top + 8, H, 26):
        if (x + y) % 52 == 0:
            d.ellipse([x - 1, y - 1, x + 1, y + 1], fill=(212, 168, 67, 26))

# --- 3) paste textile overlay back on top (feathered right edge) ---
mask = Image.new('L', overlay.size, 0)
m = ImageDraw.Draw(mask)
m.rectangle([0, 0, 150, 120], fill=255)
for x in range(150, overlay.size[0]):
    a = int(255 * (1 - (x - 150) / (overlay.size[0] - 150)))
    m.line([(x, 0), (x, overlay.size[1])], fill=a)
im.paste(overlay, (0, 380), mask)
d = ImageDraw.Draw(im)
# --- 4) replace the wooden-sign region behind the subtitle with a navy plaque ---
plaque_left, plaque_right = 252, 772
plaque_top, plaque_bottom = 252, 312
d = ImageDraw.Draw(im)
d.rectangle([plaque_left, plaque_top, plaque_right, plaque_bottom], fill=(16, 25, 52))
# gold hairline borders, fading toward the edges
for x in range(plaque_left, plaque_right + 1):
    edge = min(x - plaque_left, plaque_right - x)
    alpha = min(255, int(edge * 2.4))
    d.point((x, plaque_top), fill=(212, 168, 67, 255) if alpha > 200 else (212, 168, 67))
    d.point((x, plaque_bottom), fill=(212, 168, 67))
# small gold diamonds at the plaque ends
for dx_center in (plaque_left + 16, plaque_right - 16):
    d.polygon([(dx_center, plaque_top + 19), (dx_center + 6, plaque_top + 30),
               (dx_center, plaque_top + 41), (dx_center - 6, plaque_top + 30)],
              fill=(212, 168, 67))

# --- 5) fonts ---
georgia_b = 'C:/Windows/Fonts/georgiab.ttf'
georgia_i = 'C:/Windows/Fonts/georgiai.ttf'
f_sub = ImageFont.truetype(georgia_i, 26)
f_cell = ImageFont.truetype(georgia_b, 19)
f_cell_small = ImageFont.truetype(georgia_i, 17)

# --- 6) draw English subtitle ---
sub = 'The Complete Psalter'
cream = (245, 240, 232)
f_sub = ImageFont.truetype(georgia_i, 28)
tw = d.textlength(sub, font=f_sub)
d.text(((plaque_left + plaque_right - tw) / 2, plaque_top + 15), sub, font=f_sub, fill=cream)

# --- 7) draw the four bullets ---
cells = [
    ('150 Psalms', 0),
    ('Read Daily', 256),
    ('Favorites', 512),
    ('Daily Prayer', 768),
]
cy_icon = 467

def draw_note(cx, cy):
    # beamed eighth notes
    fill = (212, 168, 67)
    for ox in (-12, 8):
        d.ellipse([cx + ox - 6, cy + 6, cx + ox + 6, cy + 16], fill=fill)
        d.line([(cx + ox + 5, cy + 12), (cx + ox + 5, cy - 12)], fill=fill, width=3)
    d.polygon([(cx - 6, cy - 12), (cx + 14, cy - 8), (cx + 14, cy - 2), (cx - 6, cy - 6)], fill=fill)

def draw_book(cx, cy):
    fill = (212, 168, 67)
    # left page
    d.polygon([(cx - 14, cy - 8), (cx, cy - 3), (cx, cy + 12), (cx - 14, cy + 7)], fill=fill)
    # right page
    d.polygon([(cx + 14, cy - 8), (cx, cy - 3), (cx, cy + 12), (cx + 14, cy + 7)], fill=fill)
    # spine
    d.line([(cx, cy - 3), (cx, cy + 12)], fill=(13, 28, 53), width=2)
    d.line([(cx, cy - 6), (cx, cy + 14)], fill=(13, 28, 53), width=1)

def draw_star(cx, cy):
    fill = (212, 168, 67)
    pts = []
    for i in range(10):
        r = 13 if i % 2 == 0 else 5.5
        ang = math.radians(-90 + i * 36)
        pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    d.polygon(pts, fill=fill)

def draw_bell(cx, cy):
    fill = (212, 168, 67)
    # dome
    d.pieslice([cx - 10, cy - 12, cx + 10, cy + 8], 180, 360, fill=fill)
    d.rectangle([cx - 10, cy - 2, cx + 10, cy + 4], fill=fill)
    # lip
    d.polygon([(cx - 13, cy + 8), (cx + 13, cy + 8), (cx + 9, cy + 4), (cx - 9, cy + 4)], fill=fill)
    # clapper
    d.ellipse([cx - 3, cy + 8, cx + 3, cy + 14], fill=fill)

def draw_circle(cx, cy, r=24):
    d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(212, 168, 67, 90), width=2)

for label, x0 in cells:
    cx_icon = x0 + 60
    cx_text = x0 + 158
    draw_circle(cx_icon, cy_icon, 23)
    if label == '150 Psalms':
        draw_note(cx_icon, cy_icon)
    elif label == 'Read Daily':
        draw_book(cx_icon, cy_icon)
    elif label == 'Favorites':
        draw_star(cx_icon, cy_icon)
    elif label == 'Daily Prayer':
        draw_bell(cx_icon, cy_icon)
    tw = d.textlength(label, font=f_cell)
    d.text((cx_text - tw / 2, cy_icon - f_cell.size / 2), label, font=f_cell, fill=cream)

im.save(OUT, 'PNG', optimize=True)
print('saved', OUT, im.size)
