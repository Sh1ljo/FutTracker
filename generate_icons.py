#!/usr/bin/env python3
"""
Football Tracker App Icon Generator
Generates Android and iOS app icons from a source image.

Usage:
    python generate_icons.py <source_image_path>
    
Example:
    python generate_icons.py icon_source.png
"""

import sys
import os
from pathlib import Path
from PIL import Image, ImageOps

def generate_android_icons(source_image_path):
    """Generate Android app icons in different densities."""
    
    # Android icon sizes (width x height in pixels)
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }
    
    project_root = Path(__file__).parent
    img = Image.open(source_image_path).convert('RGBA')
    
    print("Generating Android icons...")
    for folder, size in android_sizes.items():
        # Resize image
        resized = img.copy()
        resized.thumbnail((size, size), Image.Resampling.LANCZOS)
        
        # Create a square canvas with padding if needed
        final = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        offset = ((size - resized.width) // 2, (size - resized.height) // 2)
        final.paste(resized, offset, resized)
        
        # Save
        output_path = project_root / 'android' / 'app' / 'src' / 'main' / 'res' / folder / 'ic_launcher.png'
        output_path.parent.mkdir(parents=True, exist_ok=True)
        final.save(output_path, 'PNG')
        print(f"  ✓ Created {folder}/ic_launcher.png ({size}x{size})")

def generate_ios_icons(source_image_path):
    """Generate iOS app icons."""
    
    # iOS icon sizes for AppIcon.appiconset
    ios_sizes = {
        'AppIcon-20x20@1x.png': 20,
        'AppIcon-20x20@2x.png': 40,
        'AppIcon-20x20@3x.png': 60,
        'AppIcon-29x29@1x.png': 29,
        'AppIcon-29x29@2x.png': 58,
        'AppIcon-29x29@3x.png': 87,
        'AppIcon-40x40@1x.png': 40,
        'AppIcon-40x40@2x.png': 80,
        'AppIcon-40x40@3x.png': 120,
        'AppIcon-60x60@2x.png': 120,
        'AppIcon-60x60@3x.png': 180,
        'AppIcon-76x76@1x.png': 76,
        'AppIcon-76x76@2x.png': 152,
        'AppIcon-83.5x83.5@2x.png': 167,
        'AppIcon-1024x1024@1x.png': 1024,
    }
    
    project_root = Path(__file__).parent
    img = Image.open(source_image_path).convert('RGBA')
    
    print("\nGenerating iOS icons...")
    output_folder = project_root / 'ios' / 'Runner' / 'Assets.xcassets' / 'AppIcon.appiconset'
    output_folder.mkdir(parents=True, exist_ok=True)
    
    for filename, size in ios_sizes.items():
        # Resize image
        resized = img.copy()
        resized.thumbnail((size, size), Image.Resampling.LANCZOS)
        
        # Create a square canvas with padding if needed
        final = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        offset = ((size - resized.width) // 2, (size - resized.height) // 2)
        final.paste(resized, offset, resized)
        
        # Save
        output_path = output_folder / filename
        final.save(output_path, 'PNG')
        print(f"  ✓ Created {filename} ({size}x{size})")

def generate_contents_json(output_folder):
    """Generate Contents.json for iOS AppIcon.appiconset."""
    
    contents = {
        "images": [
            {"filename": "AppIcon-20x20@1x.png", "idiom": "iphone", "scale": "1x", "size": "20x20"},
            {"filename": "AppIcon-20x20@2x.png", "idiom": "iphone", "scale": "2x", "size": "20x20"},
            {"filename": "AppIcon-20x20@3x.png", "idiom": "iphone", "scale": "3x", "size": "20x20"},
            {"filename": "AppIcon-29x29@1x.png", "idiom": "iphone", "scale": "1x", "size": "29x29"},
            {"filename": "AppIcon-29x29@2x.png", "idiom": "iphone", "scale": "2x", "size": "29x29"},
            {"filename": "AppIcon-29x29@3x.png", "idiom": "iphone", "scale": "3x", "size": "29x29"},
            {"filename": "AppIcon-40x40@1x.png", "idiom": "iphone", "scale": "1x", "size": "40x40"},
            {"filename": "AppIcon-40x40@2x.png", "idiom": "iphone", "scale": "2x", "size": "40x40"},
            {"filename": "AppIcon-40x40@3x.png", "idiom": "iphone", "scale": "3x", "size": "40x40"},
            {"filename": "AppIcon-60x60@2x.png", "idiom": "iphone", "scale": "2x", "size": "60x60"},
            {"filename": "AppIcon-60x60@3x.png", "idiom": "iphone", "scale": "3x", "size": "60x60"},
            {"filename": "AppIcon-76x76@1x.png", "idiom": "ipad", "scale": "1x", "size": "76x76"},
            {"filename": "AppIcon-76x76@2x.png", "idiom": "ipad", "scale": "2x", "size": "76x76"},
            {"filename": "AppIcon-83.5x83.5@2x.png", "idiom": "ipad", "scale": "2x", "size": "83.5x83.5"},
            {"filename": "AppIcon-1024x1024@1x.png", "idiom": "ios-marketing", "scale": "1x", "size": "1024x1024"},
        ],
        "info": {"author": "xcode", "version": 1}
    }
    
    import json
    json_path = output_folder / 'Contents.json'
    with open(json_path, 'w') as f:
        json.dump(contents, f, indent=2)
    print(f"\n  ✓ Created Contents.json")

def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_icons.py <source_image_path>")
        print("\nExample: python generate_icons.py icon_source.png")
        sys.exit(1)
    
    source_image = sys.argv[1]
    
    if not os.path.exists(source_image):
        print(f"Error: Image file '{source_image}' not found!")
        sys.exit(1)
    
    try:
        print(f"Loading image: {source_image}\n")
        generate_android_icons(source_image)
        generate_ios_icons(source_image)
        
        project_root = Path(__file__).parent
        generate_contents_json(project_root / 'ios' / 'Runner' / 'Assets.xcassets' / 'AppIcon.appiconset')
        
        print("\n✓ All icons generated successfully!")
        print("\nNext steps:")
        print("1. For Android: Icons are ready in android/app/src/main/res/mipmap-*/")
        print("2. For iOS: Icons are ready in ios/Runner/Assets.xcassets/AppIcon.appiconset/")
        print("3. Rebuild your app to apply the new icons")
        
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
