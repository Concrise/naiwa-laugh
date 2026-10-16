#!/usr/bin/env python3
"""从 index.html 生成本地版：原画质 550×890 帧 + 笑声全部内嵌成 data URI，单个文件离线就能打开。"""
import base64, pathlib, re, sys

root = pathlib.Path(__file__).resolve().parent.parent
out = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else root / 'dist' / 'naiwa-laugh.html'

def data_uri(path, mime):
    return f'data:{mime};base64,' + base64.b64encode(path.read_bytes()).decode()

html = (root / 'index.html').read_text(encoding='utf-8')
frames = [data_uri(root / 'assets/frames' / f'{i:03d}.webp', 'image/webp') for i in range(35)]

def sub(pattern, repl, count=1):
    global html
    html, n = re.subn(pattern, repl, html, count=count)
    if n != count: sys.exit(f'没找到要替换的内容：{pattern}')

sub(r'<link rel="(preload|manifest|apple-touch-icon)"[^\n]*\n', '', count=4)
sub(r'width="330" height="534"', 'width="550" height="890"')
sub(r'const \[FW, FH\] = standalone \? \[550, 890\] : \[330, 534\];', 'const [FW, FH] = [550, 890];')
sub(r'<span class="ver">(v\d+)</span>', r'<span class="ver">\1 本地原画质</span>')
sub(r"im\.src = `\$\{FRAME_DIR\}/\$\{String\(i\)\.padStart\(3, '0'\)\}\.webp`;", 'im.src = FRAME_SRC[i];')
sub(r"const LAUGH_SRC = \['assets/laugh\.m4a', 'assets/laugh\.mp3'\];",
    "const LAUGH_SRC = ['" + data_uri(root / 'assets/laugh.m4a', 'audio/mp4') + "', '"
    + data_uri(root / 'assets/laugh.mp3', 'audio/mpeg') + "'];")
sub(r'<script>\n', '<script>\nconst FRAME_SRC = ' + repr(frames).replace("'", '"') + ';\n')

out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(html, encoding='utf-8')
print(out, f'{out.stat().st_size // 1024}K')
