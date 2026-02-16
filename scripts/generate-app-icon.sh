#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSETS_DIR="$ROOT_DIR/assets"
ICONSET_DIR="$ASSETS_DIR/AppIcon.iconset"
SOURCE_PNG="$ASSETS_DIR/AppIcon-1024.png"
ICNS_PATH="$ASSETS_DIR/AppIcon.icns"

mkdir -p "$ASSETS_DIR" "$ICONSET_DIR"

echo "Drawing base icon..."
swift - "$SOURCE_PNG" <<'SWIFT'
import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let outputPath = CommandLine.arguments[1]
let width = 1024
let height = 1024

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: r, green: g, blue: b, alpha: a)
}

guard
    let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )
else {
    fputs("Failed to create drawing context\n", stderr)
    exit(1)
}

context.setAllowsAntialiasing(true)
context.setShouldAntialias(true)

let fullRect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
context.clear(fullRect)

let outerRect = fullRect.insetBy(dx: 56, dy: 56)
let outerPath = CGPath(
    roundedRect: outerRect,
    cornerWidth: 220,
    cornerHeight: 220,
    transform: nil
)
context.addPath(outerPath)
context.clip()

let bgGradient = CGGradient(
    colorsSpace: CGColorSpaceCreateDeviceRGB(),
    colors: [color(0.10, 0.26, 0.95), color(0.17, 0.65, 0.98)] as CFArray,
    locations: [0.0, 1.0]
)!
context.drawLinearGradient(
    bgGradient,
    start: CGPoint(x: 160, y: 920),
    end: CGPoint(x: 880, y: 120),
    options: []
)
context.resetClip()
context.addPath(outerPath)
context.clip()

let emoji = "📝"
let font = CTFontCreateWithName("AppleColorEmoji" as CFString, 620, nil)
let attrs: [CFString: Any] = [
    kCTFontAttributeName: font
]
let line = CTLineCreateWithAttributedString(NSAttributedString(string: emoji, attributes: attrs as [NSAttributedString.Key: Any]))
let lineBounds = CTLineGetBoundsWithOptions(line, [.useGlyphPathBounds, .excludeTypographicLeading])
let x = (CGFloat(width) - lineBounds.width) / 2 - lineBounds.origin.x
let y = (CGFloat(height) - lineBounds.height) / 2 - lineBounds.origin.y
context.textPosition = CGPoint(x: x, y: y)
CTLineDraw(line, context)

guard let image = context.makeImage() else {
    fputs("Failed to create image from context\n", stderr)
    exit(1)
}

let destinationURL = URL(fileURLWithPath: outputPath) as CFURL
guard
    let destination = CGImageDestinationCreateWithURL(
        destinationURL,
        UTType.png.identifier as CFString,
        1,
        nil
    )
else {
    fputs("Failed to create image destination\n", stderr)
    exit(1)
}

CGImageDestinationAddImage(destination, image, nil)
if !CGImageDestinationFinalize(destination) {
    fputs("Failed to write PNG image\n", stderr)
    exit(1)
}
SWIFT

echo "Building iconset..."
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

sips -z 16 16 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null
sips -z 32 32 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null
sips -z 32 32 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null
sips -z 64 64 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null
sips -z 128 128 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null
sips -z 256 256 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null
sips -z 256 256 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null
sips -z 512 512 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null
sips -z 512 512 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null
sips -z 1024 1024 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null

echo "Creating .icns..."
iconutil -c icns "$ICONSET_DIR" -o "$ICNS_PATH"

echo "Icon ready: $ICNS_PATH"
