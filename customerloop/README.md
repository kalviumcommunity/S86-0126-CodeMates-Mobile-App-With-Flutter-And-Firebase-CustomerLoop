# CustomerLoop - Flutter Application

This is the main Flutter application directory for **CustomerLoop**, a loyalty management system for small businesses.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (v3.0+)
- Firebase project configured
- Android Studio or VS Code with Flutter extensions

### Installation

1. **Install dependencies**
```bash
cd customerloop
flutter pub get
```

2. **Configure Firebase**
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/`

3. **Run the app**
```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
├── services/                 # Business logic & Firebase integration
├── widgets/                  # Reusable UI components
└── screens/                  # UI screens
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── signup_screen.dart
    ├── dashboard_screen.dart
    ├── customers_screen.dart
    └── rewards_screen.dart
```

## 🔧 Available Commands

```bash
# Run in debug mode
flutter run

# Build APK
flutter build apk --release

# Run tests
flutter test

# Check for issues
flutter doctor

# Clean build files
flutter clean
```

## 🧪 Testing

### Manual Testing Checklist
- ✅ User can sign up with valid credentials
- ✅ User can log in successfully
- ✅ User stays logged in after app restart
- ✅ User can add and manage customers
- ✅ User can track visits and points
- ✅ User can create and redeem rewards

## 📚 Documentation

For complete documentation, setup instructions, and architecture details, see the main [README.md](../README.md) in the root directory.

## 🐛 Troubleshooting

**Firebase initialization error:**
```bash
flutter clean
flutter pub get
flutter run
```

**Build errors:**
```bash
cd android
./gradlew clean
cd ..
flutter pub get
```

## 📄 License

This project is part of an educational assignment for learning purposes.

---

**For detailed documentation, visit the [main README](../README.md)**

