# Assets Folder

## App Icon Setup

Place your app icon/logo here as `app_icon.png`

### Requirements:
- **Format**: PNG with transparent background
- **Size**: 1024x1024 pixels (recommended) or minimum 512x512 pixels
- **File name**: `app_icon.png`

### Steps to Add Your Logo:

1. **Prepare your logo image**
   - Create or find your logo
   - Make it square (1:1 aspect ratio)
   - Save as PNG with transparent background
   - Recommended size: 1024x1024 pixels

2. **Add to this folder**
   - Copy your logo to this `assets` folder
   - Rename it to `app_icon.png`

3. **Generate app icons**
   ```bash
   flutter pub get
   dart run flutter_launcher_icons
   ```

4. **Run on your device**
   ```bash
   flutter run
   ```

### Configuration

The icon configuration is in `pubspec.yaml`:
- Background color: `#0066FF` (blue) - change this to your brand color
- Will generate icons for both Android and iOS
- Adaptive icons for Android 8.0+

### What Gets Generated?

After running the generator, icons will be created in:
- `android/app/src/main/res/mipmap-*/` (all Android sizes)
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (all iOS sizes)

### Need Help?

If you don't have a logo yet, you can:
1. Use a placeholder from https://placeholder.com
2. Design one using Canva (free)
3. Use your company/brand logo
4. Create a simple text-based logo

---

**Current Status**: 📂 Waiting for `app_icon.png` to be added
