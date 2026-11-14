from PIL import Image, ImageDraw, ImageFont, ImageFilter

SRC = 'assets/icon.png'
OUT_ICON = 'store-assets/icon.png'            # 512x512 app icon (RGBA)
OUT_FEAT = 'store-assets/feature_graphic.png'  # 1024x500 feature graphic
OUT_SRC = 'store-assets/icon-source.png'       # move original here

import shutil, os
shutil.move(SRC, OUT_SRC)

# ---------- 1) App icon 512x512 ----------
src = Image.open(OUT_SRC).convert('RGB')
# square crop to the artwork (rounded square), centered
x0, x1 = 360, 1312
crop = src.crop((x0, 0, x1, 940))  # 952x940
side = min(crop.size)
crop = crop.crop(((crop.width - side) // 2, ((crop.height - side) // 2) - 1,
                  (crop.width + side) // 2, ((crop.height + side) // 2) - 1))
icon = crop.resize((512, 512), Image.LANCZOS).convert('RGBA')
# rounded-rect alpha mask (transparent outside corners)
mask = Image.new('L', (512, 512), 0)
mdraw = ImageDraw.Draw(mask)
mdraw.rounded_rectangle([0, 0, 512, 512], radius=92, fill=255)
icon.putalpha(mask)
icon.save(OUT_ICON, optimize=True)
print('icon', icon.size, icon.mode)

# ---------- 2) Feature graphic 1024x500 ----------
W, H = 1024, 500
feat = Image.new('RGB', (W, H))
top, bot = (18, 27, 58), (5, 9, 22)   # #121B3A -> #050916 navy
for y in range(H):
    t = y / (H - 1)
    feat.paste(tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)),
               (0, y, W, y + 1))
d = ImageDraw.Draw(feat, 'RGBA')
# faint gold dot pattern
for x in range(0, W + 32, 32):
    for y in range(0, H + 32, 32):
        d.ellipse([x - 1.2, y - 1.2, x + 1.2, y + 1.2], fill=(212, 168, 67, 20))

# right-side scene: king David + harp + Bible (crop from source art)
scene_src = Image.open(OUT_SRC).convert('RGB')
scene = scene_src.crop((360, 60, 1115, 940))        # David, harp, Bible, dome side
scene_h = 372
scene = scene.resize((int(scene.width * scene_h / scene.height), scene_h), Image.LANCZOS)
# rounded corners for the scene card
card = Image.new('RGBA', scene.size, (0, 0, 0, 0))
card_draw = ImageDraw.Draw(card)
card_draw.rounded_rectangle([0, 0, scene.size[0], scene.size[1]], radius=26, fill=(255, 255, 255, 255))
scene = Image.composite(scene.convert('RGBA'), Image.new('RGBA', scene.size, (0, 0, 0, 0)),
                        card.getchannel('A'))
sx, sy = W - scene.size[0] - 44, (H - scene.size[1]) // 2
# soft shadow behind scene card
shadow = Image.new('RGBA', scene.size, (0, 0, 0, 110)).filter(ImageFilter.GaussianBlur(18))
feat_rgba = feat.convert('RGBA')
feat_rgba.paste(shadow, (sx + 6, sy + 8), shadow)
feat_rgba.paste(scene, (sx, sy), scene)
feat = feat_rgba.convert('RGB')
d = ImageDraw.Draw(feat, 'RGBA')

# left column: gold cross + wordmark
gold = (212, 168, 67)
cream = (245, 240, 232)
h_text = 330
# small gold cross above wordmark
cx = 58
cy = 128
d.rounded_rectangle([cx + 12, cy, cx + 26, cy + 62], radius=6, fill=gold)
d.rounded_rectangle([cx - 4, cy + 18, cx + 42, cy + 32], radius=6, fill=gold)

ebrima = 'C:/Windows/Fonts/ebrima.ttf'
ebrimabd = 'C:/Windows/Fonts/ebrimabd.ttf'
georgia = 'C:/Windows/Fonts/georgia.ttf'
georgiai = 'C:/Windows/Fonts/georgiai.ttf'

f_am = ImageFont.truetype(ebrimabd, 64)
f_en = ImageFont.truetype(georgiai, 30)
f_sub = ImageFont.truetype(georgia, 19)

d.text((56, 196), 'መዝሙረ ዳዊት', font=f_am, fill=gold)
d.text((56, 276), 'Psalms of David', font=f_en, fill=cream)
# divider
d.line([(56, 322), (268, 322)], fill=gold, width=2)
d.text((56, 336), "Ge'ez · Amharic · English", font=f_sub, fill=(212, 168, 67, 200))

feat.save(OUT_FEAT, optimize=True)
print('feature', feat.size)
