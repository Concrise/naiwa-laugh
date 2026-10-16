#!/usr/bin/env python3
"""用大笑帧做 1024×1024 方形图标：奶黄底，奶蛙上半身居中。"""
import pathlib, sys
from PIL import Image, ImageDraw
root = pathlib.Path(__file__).resolve().parent.parent
frog = Image.open(root / 'assets/frames/020.webp').convert('RGBA')   # 捧腹大笑循环里的一帧
frog = frog.crop(frog.getbbox())
S = 1024
bg = Image.new('RGBA', (S, S), (0, 0, 0, 0))
ImageDraw.Draw(bg).rounded_rectangle((0, 0, S - 1, S - 1), radius=0, fill=(251, 241, 207, 255))
w = int(S * 0.78); h = int(frog.height * w / frog.width)
frog = frog.resize((w, h), Image.LANCZOS)
bg.alpha_composite(frog, ((S - w) // 2, int(S * 0.10)))   # 下半身超出画面，只露上半身
bg.save(sys.argv[1])
