#!/bin/zsh
# 在 Mac 上交叉编译 Windows 64 位 exe（纯 Go，不需要 C 编译器）。用法：build_windows.sh <网页> <图标png> <输出exe>
set -euo pipefail
HERE=${0:A:h}/windows
HTML=${1:A} ICON=${2:A} OUT=${3:A}
W=$(mktemp -d /tmp/naiwa-win.XXXXXX); trap 'rm -rf "$W"' EXIT

cp $HERE/main.go $HERE/go.mod $HERE/go.sum $W/
cp $HTML $W/index.html
cd $W
# 图标 + 高分屏清单编进 rsrc_windows_amd64.syso；图标资源 ID 是 1（main.go 里的 IconId）
sips -z 256 256 $ICON --out $W/icon.png >/dev/null
go run github.com/tc-hib/go-winres@v0.3.3 simply --icon icon.png --manifest gui --arch amd64 \
  --product-name 奶蛙大笑 --file-description 奶蛙大笑 --product-version 6.0.0.0 --file-version 6.0.0.0
GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -ldflags '-s -w -H windowsgui' -o $OUT .
echo $OUT $(du -h $OUT | cut -f1)
