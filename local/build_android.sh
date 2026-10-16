#!/bin/zsh
# 不用 Gradle，直接用 Android SDK 的 aapt2 / d8 / apksigner 打 APK。用法：build_android.sh <网页> <图标png> <输出apk>
set -euo pipefail
SDK=${ANDROID_HOME:-$HOME/Library/Android/sdk}
BT=$SDK/build-tools/$(ls $SDK/build-tools | sort -V | tail -1)
JAR=$SDK/platforms/android-36/android.jar
HERE=${0:A:h}/android
HTML=${1:A} ICON=${2:A} OUT=${3:A}
W=$(mktemp -d /tmp/naiwa-apk.XXXXXX); trap 'rm -rf "$W"' EXIT

mkdir -p $W/res/mipmap-xxxhdpi $W/assets $W/classes $W/dex
sips -z 192 192 $ICON --out $W/res/mipmap-xxxhdpi/icon.png >/dev/null
cp $HTML $W/assets/index.html
$BT/aapt2 compile --dir $W/res -o $W/res.zip
$BT/aapt2 link -I $JAR --manifest $HERE/AndroidManifest.xml -A $W/assets -o $W/base.apk $W/res.zip
javac -source 11 -target 11 -nowarn -classpath $JAR -d $W/classes $HERE/src/com/concrise/naiwa/*.java 2>&1 | grep -v 'bootstrap classpath' || true
$BT/d8 --min-api 24 --lib $JAR --output $W/dex $W/classes/com/concrise/naiwa/*.class
(cd $W/dex && zip -q $W/base.apk classes.dex)
$BT/zipalign -f 4 $W/base.apk $W/aligned.apk
# 用本机 Android 调试证书签名，够自己和朋友侧载安装
$BT/apksigner sign --ks $HOME/.android/debug.keystore --ks-pass pass:android --ks-key-alias androiddebugkey --out $OUT $W/aligned.apk
rm -f $OUT.idsig
echo $OUT $(du -h $OUT | cut -f1)
