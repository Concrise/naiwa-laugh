#!/bin/zsh
# 一键打包本地原画质版本，产物放在 dist/
set -euo pipefail
cd ${0:A:h}; D=../dist
python3 build_html.py $D/奶蛙大笑-网页版.html
python3 make_icon.py $D/icon-1024.png
./build_android.sh $D/奶蛙大笑-网页版.html $D/icon-1024.png $D/奶蛙大笑-安卓.apk
./build_mac.sh $D/奶蛙大笑-网页版.html $D/icon-1024.png $D/奶蛙大笑.app
(cd $D && rm -f 奶蛙大笑-Mac.zip && ditto -c -k --keepParent 奶蛙大笑.app 奶蛙大笑-Mac.zip)
./build_windows.sh $D/奶蛙大笑-网页版.html $D/icon-1024.png $D/奶蛙大笑-Windows.exe
