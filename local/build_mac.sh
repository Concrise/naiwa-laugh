#!/bin/zsh
# 编出 Intel + Apple 芯片通用的 .app。用法：build_mac.sh <网页> <图标png> <输出.app>
set -euo pipefail
HERE=${0:A:h}/mac
HTML=${1:A} ICON=${2:A} APP=${3:A}
W=$(mktemp -d /tmp/naiwa-mac.XXXXXX); trap 'rm -rf "$W"' EXIT

rm -rf $APP; mkdir -p $APP/Contents/MacOS $APP/Contents/Resources
for a in arm64 x86_64; do
  swiftc -O -target $a-apple-macos13 -o $W/naiwa-$a $HERE/main.swift
done
lipo -create $W/naiwa-arm64 $W/naiwa-x86_64 -output $APP/Contents/MacOS/naiwa
cp $HERE/Info.plist $APP/Contents/
cp $HTML $APP/Contents/Resources/index.html

mkdir $W/icon.iconset
for s in 16 32 128 256 512; do
  sips -z $s $s $ICON --out $W/icon.iconset/icon_${s}x${s}.png >/dev/null
  sips -z $((s*2)) $((s*2)) $ICON --out $W/icon.iconset/icon_${s}x${s}@2x.png >/dev/null
done
iconutil -c icns $W/icon.iconset -o $APP/Contents/Resources/icon.icns
codesign --force --deep --sign - $APP   # 临时签名（没有开发者证书），第一次打开要右键→打开
echo $APP
