#!/usr/bin/env bash
# Build Stock Launcher on the Mac mini without Gradle: aapt2 -> javac -> d8 -> zipalign -> apksigner.
set -euo pipefail
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-/opt/homebrew/share/android-commandlinetools}}"
export JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home}"
export PATH="$JAVA_HOME/bin:$PATH"
ANDROID_JAR="$SDK_ROOT/platforms/android-36/android.jar"
BT="$SDK_ROOT/build-tools/36.0.0"
BUILD="$APP_DIR/.build"; OUT="$APP_DIR/dist"; KEYSTORE="$OUT/debug.keystore"
rm -rf "$BUILD"; mkdir -p "$BUILD/gen" "$BUILD/classes" "$BUILD/dex" "$OUT"

"$BT/aapt2" compile --dir "$APP_DIR/src/main/res" -o "$BUILD/res.zip"
"$BT/aapt2" link -I "$ANDROID_JAR" --manifest "$APP_DIR/src/main/AndroidManifest.xml" \
  --java "$BUILD/gen" --min-sdk-version 26 --target-sdk-version 36 \
  --version-code 1 --version-name 1.0 -o "$BUILD/res.apk" "$BUILD/res.zip"
find "$APP_DIR/src/main/java" "$BUILD/gen" -name '*.java' > "$BUILD/sources.list"
javac -encoding UTF-8 -source 11 -target 11 -classpath "$ANDROID_JAR" -d "$BUILD/classes" @"$BUILD/sources.list"
"$BT/d8" --min-api 26 --lib "$ANDROID_JAR" --output "$BUILD/dex" $(find "$BUILD/classes" -name '*.class')
cp "$BUILD/res.apk" "$BUILD/unsigned.apk"
(cd "$BUILD/dex" && zip -q -u "$BUILD/unsigned.apk" classes.dex)
"$BT/zipalign" -f 4 "$BUILD/unsigned.apk" "$BUILD/aligned.apk"
[[ -f "$KEYSTORE" ]] || keytool -genkeypair -keystore "$KEYSTORE" -storepass android -keypass android \
  -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US" >/dev/null
"$BT/apksigner" sign --ks "$KEYSTORE" --ks-pass pass:android --key-pass pass:android \
  --out "$OUT/StockLauncher.apk" "$BUILD/aligned.apk"
"$BT/apksigner" verify "$OUT/StockLauncher.apk"
echo "$OUT/StockLauncher.apk"
