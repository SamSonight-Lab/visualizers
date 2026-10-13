#!/bin/sh
# Bouwt SamSo-Fractualizer.app naast index.html
set -e
cd "$(dirname "$0")"
APP="../SamSo-Fractualizer.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
# universeel: Apple Silicon + Intel
T=$(mktemp -d)
swiftc -O -target arm64-apple-macos13.0 main.swift -o "$T"/fv-arm64
swiftc -O -target x86_64-apple-macos13.0 main.swift -o "$T"/fv-x86_64
lipo -create "$T"/fv-arm64 "$T"/fv-x86_64 -output "$APP/Contents/MacOS/SamSo-Fractualizer"
rm -rf "$T"
cp ../index.html AppIcon.icns "$APP/Contents/Resources/"
cat > "$APP/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>SamSo-Fractualizer</string>
  <key>CFBundleIdentifier</key><string>nl.debox.samso-fractualizer</string>
  <key>CFBundleExecutable</key><string>SamSo-Fractualizer</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
EOF
codesign --force --sign - --identifier nl.debox.samso-fractualizer "$APP"
# zip om te delen: map met de app en de handleiding
T=$(mktemp -d)
mkdir "$T/SamSo-Fractualizer"
ditto "$APP" "$T/SamSo-Fractualizer/SamSo-Fractualizer.app"
cp Handleiding.html "$T/SamSo-Fractualizer/"
rm -f ../SamSo-Fractualizer.zip
ditto -c -k --keepParent "$T/SamSo-Fractualizer" ../SamSo-Fractualizer.zip
rm -rf "$T"
echo "klaar: $APP en SamSo-Fractualizer.zip"
