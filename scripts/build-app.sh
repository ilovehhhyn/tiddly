#!/bin/sh
# Builds the native Tiddly binary and assembles dist/Tiddly.app with Helen's artwork and the Gaegu font.
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
app="$root/dist/Tiddly.app"
version=$(node -p "require('$root/package.json').version")

log=$(mktemp "${TMPDIR:-/tmp}/tiddly-build.XXXXXX")
if ! swift build -c release --package-path "$root" >"$log" 2>&1; then
  grep -E 'error|warning' "$log" || cat "$log"
  rm -f "$log"
  exit 1
fi
rm -f "$log"

rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources/source" "$app/Contents/Resources/fonts"
cp "$root/.build/release/Tiddly" "$app/Contents/MacOS/Tiddly"
for sheet in hedgehog-v2-original.png owl-v2-original.png wine-button-original.png water-button-original.png drink-frames-original.png; do
  cp "$root/assets/source/$sheet" "$app/Contents/Resources/source/"
done
cp "$root/assets/fonts/Gaegu-Regular.ttf" "$root/assets/fonts/Gaegu-Bold.ttf" "$root/assets/fonts/OFL-Gaegu.txt" "$app/Contents/Resources/fonts/"

cat > "$app/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleDisplayName</key><string>Tiddly</string>
  <key>CFBundleExecutable</key><string>Tiddly</string>
  <key>CFBundleIdentifier</key><string>app.tiddly.desktop</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleName</key><string>Tiddly</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$version</string>
  <key>CFBundleVersion</key><string>$version</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSPrincipalClass</key><string>NSApplication</string>
</dict>
</plist>
PLIST

codesign --force --sign - "$app" >/dev/null 2>&1
printf 'Built %s\n' "$app"
