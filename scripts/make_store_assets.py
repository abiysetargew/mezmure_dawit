"""Generate Play Store assets:
 - phone: cropped clean UI (no status/nav bars), PNG 1080x~2120
 - tablet7/tablet10 (same file set): 1440x2560 9:16 with brand background
 - chromebook: 2560x1440 16:9 landscape with brand background
"""
import os
from PIL import Image, ImageDraw, ImageFilter

SRC = sorted(glob('screenshots/*.jpg')) if False else sorted(
    __import__('glob').glob('screenshots/*.jpg'))
OUT_PHONE = 'store-assets/phone'
OUT_TAB = 'store-assets/tablet'
OUT_CR = 'store-assets/chromebook'
for d in (OUT_PHONE, OUT_TAB, OUT_CR):
    os.makedirs(d, exist_ok=True)

CROP_TOP = 100
CROP_BOT = 120

def brand_background(size):
    w, h = size
    img = Image.new('RGB', size)
    top = (26, 15, 15)      # #1A0F0F
    bot = (10, 9, 12)       # #0A090C
    for y in range(h):
        t = y / max(1, h - 1)
        img.paste(tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)),
                  (0, y, w, y + 1))
    # faint gold dot pattern like the app's painter
    d = ImageDraw.Draw(img, 'RGBA')
    for x in range(0, w + 40, 40):
        for y in range(0, h + 40, 40):
            d.ellipse([x - 1.5, y - 1.5, x + 1.5, y + 1.5], fill=(212, 168, 67, 22))
    # subtle gold frame lines at extreme edges
    d.rectangle([0, h - 6, w, h], fill=(212, 168, 67, 90))
    return img

def rounded_shadow(base, shot, center, radius=28):
    # shadow copy of the shot silhouette
    shadow = Image.new('RGBA', shot.size, (0, 0, 0, 180))
    blurred = shadow.filter(ImageFilter.GaussianBlur(30))
    x, y = center
    base.paste(blurred, (x, y), blurred)

shots = []
for f in SRC:
    im = Image.open(f).convert('RGB')
    im = im.crop((0, CROP_TOP, im.width, im.height - CROP_BOT))
    shots.append((f, im))

# ---- phone (clean UI, no bars) ----
for i, (f, im) in enumerate(shots, 1):
    im.save(os.path.join(OUT_PHONE, f'phone_{i:02d}.png'), optimize=True)
    print(f'phone_{i:02d}.png  {im.size}')

# ---- tablet portrait 1440x2560 (9:16) ----
TAB = (1440, 2560)
for i, (f, im) in enumerate(shots, 1):
    scale = min((TAB[0] - 160) / im.width, (TAB[1] - 200) / im.height)
    ns = (int(im.width * scale), int(im.height * scale))
    r = im.resize(ns, Image.LANCZOS)
    cv = brand_background(TAB)
    x = (TAB[0] - ns[0]) // 2
    y = (TAB[1] - ns[1]) // 2
    cv.paste(r, (x, y))
    cv.save(os.path.join(OUT_TAB, f'tablet_{i:02d}.png'), optimize=True)
    print(f'tablet_{i:02d}.png  {TAB}')

# ---- chromebook landscape 2560x1440 (16:9) ----
CR = (2560, 1440)
for i, (f, im) in enumerate(shots, 1):
    scale = min((CR[0] - 200) / im.width, (CR[1] - 140) / im.height)
    ns = (int(im.width * scale), int(im.height * scale))
    r = im.resize(ns, Image.LANCZOS)
    cv = brand_background(CR)
    x = (CR[0] - ns[0]) // 2
    y = (CR[1] - ns[1]) // 2
    cv.paste(r, (x, y))
    cv.save(os.path.join(OUT_CR, f'chromebook_{i:02d}.png'), optimize=True)
    print(f'chromebook_{i:02d}.png  {CR}')

print('done')
