#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
electron_zip="$HOME/Library/Caches/electron/f9c7436ab4a2c1ed6ac6cea2902187de75bd5b7a60c0973ad8967c318a6313c3/electron-v44.3.0-darwin-arm64.zip"
stage_dir=$(mktemp -d "${TMPDIR:-/tmp}/tiddly-package.XXXXXX")
trap 'find "$stage_dir" -depth -delete 2>/dev/null || true' EXIT
app_dir="$stage_dir/Tiddly.app"
output_dir="$project_dir/out/make/zip/darwin/arm64"

test -f "$electron_zip"
ditto -x -k "$electron_zip" "$stage_dir"
mv "$stage_dir/Electron.app" "$app_dir"
mv "$app_dir/Contents/MacOS/Electron" "$app_dir/Contents/MacOS/Tiddly"

plutil -replace CFBundleDisplayName -string Tiddly "$app_dir/Contents/Info.plist"
plutil -replace CFBundleName -string Tiddly "$app_dir/Contents/Info.plist"
plutil -replace CFBundleExecutable -string Tiddly "$app_dir/Contents/Info.plist"
plutil -replace CFBundleIdentifier -string biz.helenhui.tiddly "$app_dir/Contents/Info.plist"
plutil -replace CFBundleShortVersionString -string 0.1.0 "$app_dir/Contents/Info.plist"
plutil -replace CFBundleVersion -string 0.1.0 "$app_dir/Contents/Info.plist"

app_source="$stage_dir/app-source"
mkdir -p "$app_source" "$output_dir"
cp "$project_dir/package.json" "$app_source/package.json"
cp -R "$project_dir/dist" "$app_source/dist"
"$project_dir/node_modules/.bin/asar" pack "$app_source" "$app_dir/Contents/Resources/app.asar"
cp "$project_dir/dist/native/tiddly-frontmost" "$app_dir/Contents/Resources/tiddly-frontmost"
codesign --force --deep --sign - "$app_dir"
ditto -c -k --sequesterRsrc --keepParent "$app_dir" "$output_dir/Tiddly-darwin-arm64-0.1.0.zip"
printf 'Created %s\n' "$output_dir/Tiddly-darwin-arm64-0.1.0.zip"
