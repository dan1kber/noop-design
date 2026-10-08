#!/bin/bash
# Builds an UNSIGNED W3P-prototype.ipa (the design mockup in a web-view shell) for sideloading.
# Needs the iOS SDK, so run it on a Mac with Xcode or on a macOS GitHub Actions runner.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SHELL_DIR="$ROOT/design/ios-shell"
OUT="$ROOT/build/w3p-prototype"
APP="$OUT/Payload/W3P.app"

rm -rf "$OUT"
mkdir -p "$APP"
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
xcrun --sdk iphoneos swiftc -parse-as-library -O \
  -target arm64-apple-ios16.0 -sdk "$SDK" \
  "$SHELL_DIR/App.swift" -o "$APP/W3P"
cp "$SHELL_DIR/Info.plist" "$APP/Info.plist"
cp "$ROOT/design/W3P-prototype.html" "$APP/index.html"
cp "$SHELL_DIR"/Icon-60@2x.png "$SHELL_DIR"/Icon-60@3x.png "$APP/"
printf 'APPL????' > "$APP/PkgInfo"
(cd "$OUT" && zip -qry W3P-prototype.ipa Payload)
echo "Built $OUT/W3P-prototype.ipa"
