#!/bin/bash

# iOS and Watch Icon Generator Script
# Generates all required icon sizes from the base 1024x1024 icon

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if base icon exists
if [[ ! -f "$SCRIPT_DIR/icon-1024.png" ]]; then
    echo "Error: icon-1024.png not found in $SCRIPT_DIR"
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null; then
    echo "Error: ImageMagick is required but not installed"
    echo "Install with: brew install imagemagick"
    exit 1
fi

# Define output directories based on Project.swift configuration
IOS_ASSETS_DIR="$SCRIPT_DIR/../../App/TemplateSwiftApp/Assets.xcassets/AppIcon.appiconset"

# Create output directories
mkdir -p "$IOS_ASSETS_DIR"

# Create Contents.json for iOS AppIcon
cat > "$IOS_ASSETS_DIR/Contents.json" << 'EOF'
{
  "images" : [
    {
      "filename" : "Icon-20@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-20@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-29@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-29@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-40@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-40@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-60@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-60@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-20.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-20@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-29.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-29@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-40.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-40@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-76.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-76@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-83.5@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "filename" : "Icon-1024.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "Generating iOS icons..."

# iOS App Icon sizes (for iOS 12+)
# iPhone notifications
magick "$SCRIPT_DIR/icon-1024.png" -resize 40x40 "$IOS_ASSETS_DIR/Icon-20@2x.png"
magick "$SCRIPT_DIR/icon-1024.png" -resize 60x60 "$IOS_ASSETS_DIR/Icon-20@3x.png"

# iPhone settings
magick "$SCRIPT_DIR/icon-1024.png" -resize 58x58 "$IOS_ASSETS_DIR/Icon-29@2x.png"
magick "$SCRIPT_DIR/icon-1024.png" -resize 87x87 "$IOS_ASSETS_DIR/Icon-29@3x.png"

# iPhone spotlight
magick "$SCRIPT_DIR/icon-1024.png" -resize 80x80 "$IOS_ASSETS_DIR/Icon-40@2x.png"
magick "$SCRIPT_DIR/icon-1024.png" -resize 120x120 "$IOS_ASSETS_DIR/Icon-40@3x.png"

# iPhone app
magick "$SCRIPT_DIR/icon-1024.png" -resize 120x120 "$IOS_ASSETS_DIR/Icon-60@2x.png"
magick "$SCRIPT_DIR/icon-1024.png" -resize 180x180 "$IOS_ASSETS_DIR/Icon-60@3x.png"

# iPad notifications
magick "$SCRIPT_DIR/icon-1024.png" -resize 20x20 "$IOS_ASSETS_DIR/Icon-20.png"
magick "$SCRIPT_DIR/icon-1024.png" -resize 40x40 "$IOS_ASSETS_DIR/Icon-20@2x.png"

# iPad settings
magick "$SCRIPT_DIR/icon-1024.png" -resize 29x29 "$IOS_ASSETS_DIR/Icon-29.png"
magick "$SCRIPT_DIR/icon-1024.png" -resize 58x58 "$IOS_ASSETS_DIR/Icon-29@2x.png"

# iPad spotlight
magick "$SCRIPT_DIR/icon-1024.png" -resize 40x40 "$IOS_ASSETS_DIR/Icon-40.png"
magick "$SCRIPT_DIR/icon-1024.png" -resize 80x80 "$IOS_ASSETS_DIR/Icon-40@2x.png"

# iPad app
magick "$SCRIPT_DIR/icon-1024.png" -resize 76x76 "$IOS_ASSETS_DIR/Icon-76.png"
magick "$SCRIPT_DIR/icon-1024.png" -resize 152x152 "$IOS_ASSETS_DIR/Icon-76@2x.png"

# iPad Pro app
magick "$SCRIPT_DIR/icon-1024.png" -resize 167x167 "$IOS_ASSETS_DIR/Icon-83.5@2x.png"

# App Store
magick "$SCRIPT_DIR/icon-1024.png" -resize 1024x1024 "$IOS_ASSETS_DIR/Icon-1024.png"

echo "Icon generation complete!"
