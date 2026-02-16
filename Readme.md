#  CustomerLoop

A mobile-first loyalty management application built with Flutter and Firebase for small businesses.

##  Overview

**CustomerLoop** helps small businesses in Tier-2 and Tier-3 towns digitally track repeat customers, record visits, and reward loyalty through a points-based system.

### Problem Statement
Small businesses struggle to retain customers due to the absence of simple, affordable digital loyalty tools. Shop owners rely on manual methods like physical loyalty cards or memory, which are inefficient and error-prone.

### Our Solution
-  Secure digital customer management
-  Automated visit tracking and points accumulation
-  Reward redemption system
-  Real-time data synchronization
-  Simple, intuitive interface

---

##  Features

### Core Features
- **Role-Based Access**: Separate interfaces for Shop Owners and Customers
- **Authentication**: Firebase Email/Password with persistent login and forgot password
- **Customer Management**: Add, view, edit, and track customers with visit history
- **Points System**: Automatic points accumulation per visit
- **Rewards System**: Create and manage rewards with points-based redemption
- **Shop Management**: Multi-shop support with shop settings
- **Profile Management**: User profile with editable information
- **Notifications**: Push notifications with Firebase Cloud Messaging
- **Image Upload**: Firebase Storage integration for photos
- **Onboarding**: Welcome and onboarding screens for new users
- **Responsive Design**: Adaptive layouts for phone, tablet, and desktop
- **Real-time Sync**: StreamBuilder for live data updates

---

##  Technology Stack

- **Flutter** (v3.0+) - Cross-platform mobile framework
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - NoSQL real-time database
- **Firebase Storage** - Image and file storage
- **Firebase Cloud Messaging** - Push notifications
- **Flutter Local Notifications** - Local notification handling
- **Provider** - State management
- **Image Picker** - Camera and gallery access
- **Material Design 3** - UI design system

---

##  Quick Start

### Prerequisites
- Flutter SDK (v3.0+)
- Firebase project configured
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd S86-0126-CodeMates-Mobile-App-With-Flutter-And-Firebase-CustomerLoop/customerloop
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
   - Place google-services.json in android/app/
   - Place GoogleService-Info.plist in ios/Runner/
   - Enable Email/Password authentication in Firebase Console
   - Set up Cloud Firestore database

4. Run the app
```bash
flutter run
```

---

##  Project Structure

```
customerloop/
├── lib/
│   ├── main.dart              # App entry point
│   ├── firebase_options.dart  # Firebase config
│   ├── screens/               # UI screens
│   │   ├── owner/            # Shop owner screens
│   │   │   ├── owner_dashboard.dart
│   │   │   ├── customers_screen.dart
│   │   │   ├── customer_history_screen.dart
│   │   │   └── owner_rewards_screen.dart
│   │   ├── customer/         # Customer screens
│   │   │   ├── customer_dashboard.dart
│   │   │   └── customer_rewards_screen.dart
│   │   ├── splash_screen.dart
│   │   ├── welcome_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   ├── role_resolver_screen.dart
│   │   ├── profile_screen.dart
│   │   └── notifications_screen.dart
│   ├── widgets/               # Reusable components
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── stat_card.dart
│   │   ├── loading_widget.dart
│   │   ├── error_widget.dart
│   │   └── notification_bell_widget.dart
│   ├── models/                # Data models
│   │   ├── user_model.dart
│   │   ├── customer_model.dart
│   │   ├── visit_model.dart
│   │   ├── reward_model.dart
│   │   ├── redemption_model.dart
│   │   ├── shop_model.dart
│   │   ├── shop_settings_model.dart
│   │   └── notification_model.dart
│   └── services/              # Business logic
│       ├── auth_service.dart
│       ├── firestore_service.dart
│       └── notification_service.dart
├── android/                   # Android files
├── ios/                       # iOS files
└── pubspec.yaml              # Dependencies
```

---

##  Team - CodeMates

| Role | Member | Responsibilities |
|------|--------|------------------|
| UI & UX Lead | Keerthana | Flutter UI, navigation, layouts |
| Firebase Lead | Chetan | Auth, Firestore, security rules |
| Integration Lead | Dinesh | Testing, APK build |

---

##  Key Features Implemented

### Authentication Flow
- Persistent login with StreamBuilder
- Auto-routing based on auth state
- Form validation for email/password

### Responsive Design
- MediaQuery-based layouts
- Dynamic grid columns (1-3 based on device)
- Portrait and landscape support

### State Management
- Local state with setState()
- StreamBuilder for real-time Firebase data
- Clean UI/logic separation

---

##  Testing

```bash
# Run tests
flutter test

# Build APK
flutter build apk --release
```

---

##  Key Implementation Details

### Role-Based Architecture
- Separate dashboards and features for shop owners and customers
- Role resolver screen to route users based on their role
- Owner features: customer management, visit tracking, rewards creation
- Customer features: view points, browse rewards, redeem rewards

### Firebase Integration
- **Authentication**: Email/Password with forgot password functionality
- **Firestore**: Real-time database for customers, visits, rewards, shops
- **Storage**: Image uploads for profiles and rewards
- **Cloud Messaging**: Push notifications for customer engagement

### State Management
- Provider for global state
- StreamBuilder for real-time Firebase data
- setState for local component state

---

##  License

Educational project for learning purposes.

---

**Built with ❤️ by Team CodeMates**
