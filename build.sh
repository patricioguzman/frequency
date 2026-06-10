#!/usr/bin/env bash
# Frequency — Android APK Builder
# Requires: Android SDK with build-tools and platform-tools on PATH
#           or set ANDROID_HOME/SDK_ROOT env vars.
#
# Usage: ./build.sh [keystore_path] [keystore_alias]
#   Defaults: /tmp/debug.keystore  /  debug

set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$APP_DIR/app/src/main"
BT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Android/Sdk}}/build-tools"
SDK="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Android/Sdk}}/platforms"

# Pick the highest available build-tools and platform
BT_VER=$(ls -1 "$BT" | sort -V | tail -1)
SDK_VER=$(ls -1 "$SDK" | sort -V | tail -1)

BT="$BT/$BT_VER"
JAR="$SDK/$SDK_VER/android.jar"

KEYSTORE="${1:-/tmp/debug.keystore}"
ALIAS="${2:-debug}"

echo "=== Frequency Build ==="
echo "Build-tools: $BT_VER"
echo "Platform:    $SDK_VER"

WORK="$APP_DIR/build"
rm -rf "$WORK" && mkdir -p "$WORK"

# 1. Compile resources (drawables)
if ls "$SRC"/res/drawable/*.png &>/dev/null 2>&1; then
  for f in "$SRC"/res/drawable/*.png; do
    "$BT/aapt2" compile -o "$WORK" "$f"
  done
fi

# 2. Link APK skeleton
"$BT/aapt2" link -I "$JAR" --manifest "$SRC/AndroidManifest.xml" \
  -A "$SRC/assets" -o "$WORK/base.apk" "$WORK"/*.flat 2>/dev/null || \
"$BT/aapt2" link -I "$JAR" --manifest "$SRC/AndroidManifest.xml" \
  -A "$SRC/assets" -o "$WORK/base.apk"

# 3. Compile Java
find "$SRC/java" -name "*.java" > "$WORK/sources.txt"
javac -source 8 -target 8 -d "$WORK" -cp "$JAR" "@$WORK/sources.txt"

# 4. DEX
"$BT/d8" --lib "$JAR" --output "$WORK" $(find "$WORK" -name "*.class")

# 5. Package & sign
cp "$WORK/base.apk" "$WORK/unsigned.apk"
(cd "$WORK" && zip -q unsigned.apk classes.dex)
"$BT/zipalign" -p 4 "$WORK/unsigned.apk" "$WORK/aligned.apk"

echo ""
echo "Keystore: $KEYSTORE (alias: $ALIAS)"
echo "Enter keystore password to sign..."

"$BT/apksigner" sign --ks "$KEYSTORE" "$WORK/aligned.apk"

FINAL="$APP_DIR/frequency.apk"
cp "$WORK/aligned.apk" "$FINAL"
echo ""
echo "=== Done: $FINAL ($(du -h "$FINAL" | cut -f1)) ==="
