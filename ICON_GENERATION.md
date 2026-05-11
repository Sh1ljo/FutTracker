# App Icon Generation Instructions

I've set up Flutter's official icon generator for you. It's much simpler!

## Quick Steps:

### 1. Save Your Icon Image
Save the Football Tracker logo image to the project root as `icon_source.png`:
- Path: `c:\Projects\FootballTracker\icon_source.png`

### 2. Get Dependencies
```bash
flutter pub get
```

### 3. Generate Icons
```bash
dart run flutter_launcher_icons
```

That's it! The icons will be automatically generated for both platforms.

## What Gets Generated:

### Android Icons:
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48×48)
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72×72)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96×96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144×144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192×192)

### iOS Icons:
All required sizes automatically generated in:
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Next Steps After Generation:
1. Run your app to see the new icons
```bash
flutter run
```

Done! No Python dependencies needed.
