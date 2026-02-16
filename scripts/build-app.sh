#!/usr/bin/env bash
set -euo pipefail

APP_NAME="DisposableNote"
PRODUCT_NAME="disposable-note"
BUNDLE_ID="com.azabraao.disposablenote"
MIN_MACOS_VERSION="13.0"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.build/release"
OUTPUT_DIR="$ROOT_DIR/artifacts"
APP_BUNDLE="$OUTPUT_DIR/${APP_NAME}.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
PLIST_PATH="$CONTENTS_DIR/Info.plist"
EXECUTABLE_PATH="$BUILD_DIR/$PRODUCT_NAME"

echo "Building release binary..."
swift build -c release

if [[ ! -x "$EXECUTABLE_PATH" ]]; then
  echo "Error: built executable not found at $EXECUTABLE_PATH" >&2
  exit 1
fi

echo "Creating app bundle at $APP_BUNDLE"
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$EXECUTABLE_PATH" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>${BUNDLE_ID}</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>${APP_NAME}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>${MIN_MACOS_VERSION}</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
EOF

echo "Codesigning for local launch..."
codesign --force --deep --sign - "$APP_BUNDLE"

echo "App ready: $APP_BUNDLE"
echo "Open it with: open \"$APP_BUNDLE\""
