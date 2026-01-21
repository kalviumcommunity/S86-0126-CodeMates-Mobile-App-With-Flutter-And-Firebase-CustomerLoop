# 🔁 Customer Loop

## 🧩 Problem Statement

Small businesses in Tier-2 and Tier-3 towns struggle to retain customers due to the absence of simple, affordable digital loyalty tools. Most shop owners rely on manual methods such as physical loyalty cards or memory, which are inefficient, error-prone, and do not scale with business growth.

---

## 💡 Solution Overview

**Customer Loop** is a **mobile-first loyalty management application** built using **Flutter** and **Firebase**.  
It helps small business owners digitally track repeat customers, record visits, and reward loyalty through a **points-based system**.

### 🔄 How Customer Loop Works
- Shop owners register and log in securely
- Customers are added and managed digitally
- Each visit earns reward points
- Points can be redeemed as:
  - **Instant discounts at the same shop**
  - **Products from an in-app rewards catalog** (MVP demo feature)

Firebase ensures **secure authentication** and **real-time data synchronization**, enabling instant updates across devices.

---

## 🎯 Target Users

- Small business owners  
  *(local shops, cafes, salons, service providers)*
- Their repeat customers

---

## 🚀 Why Flutter + Firebase?

- **Flutter** enables fast, cross-platform mobile app development
- **Firebase** removes backend complexity by providing:
  - Authentication
  - Cloud Firestore (real-time database)
  - Scalable infrastructure

This combination allows rapid MVP development with reliable performance.

---

## 📦 Scope & Boundaries

### ✅ In Scope
- Firebase Authentication (Login / Register)
- Cloud Firestore for customer, visit, and reward data
- Customer visit tracking & points accumulation
- Reward redemption (discounts & rewards catalog)
- Core Flutter screens:
  - Login
  - Dashboard
  - Customers
  - Rewards
- Real-time data synchronization

### ❌ Out of Scope
- Online payments
- Product delivery or shipping
- Push notifications
- Advanced analytics
- Multi-language support

---

## 👥 Team Roles & Responsibilities

| Role | Team Member | Responsibilities |
|----|----|----|
| UI & UX Lead | Keerthana | Wireframes, Flutter UI, navigation, layouts |
| Firebase Lead | Chetan | Firebase Auth, Firestore schema, security rules |
| Integration & Testing Lead | Dinesh | UI–Firebase integration, testing, APK build |

---

## 🗓️ Sprint Timeline (4 Weeks)

| Week | Focus Area | Deliverables |
|----|----|----|
| Week 1 | Setup & Design | Finalize idea, wireframes, Firebase setup |
| Week 2 | Core Development | Auth flows, Firestore CRUD, dashboard UI |
| Week 3 | Integration & Testing | Real-time sync, validations, testing |
| Week 4 | MVP Completion | UI polish, documentation, demo APK |

---

## 🧪 MVP – Minimum Viable Product

### ✅ MVP Features
- Secure authentication using Firebase Auth
- Firestore-based customer & visit management
- Automatic points accumulation
- Reward redemption system
- Real-time UI updates
- Demo-ready APK

---

## 📊 Success Metrics

- All MVP features implemented successfully
- Firebase Authentication and Firestore fully integrated
- Real-time data updates demonstrated
- Working APK shared
- Positive mentor evaluation feedback

---

## ⚠️ Risks & Mitigation

| Risk | Impact | Mitigation |
|----|----|----|
| Firebase configuration issues | Development delay | Early setup & validation |
| UI integration bugs | Demo instability | Incremental testing |
| Time constraints | Feature reduction | Strict MVP focus |

---

## 🏁 Conclusion

**Customer Loop** provides a simple, scalable, and affordable loyalty solution for small businesses.  
By digitizing customer engagement and rewards, it helps shop owners build long-term relationships while keeping the system easy to use and maintain.

---

## 📁 Flutter Project Folder Structure

The project follows a clean, modular architecture that promotes scalability and maintainability:

```
customerloop/lib/
├── main.dart          # Entry point - initializes app and sets up routing
├── screens/           # Individual UI screens (Login, Dashboard, Customers, Rewards)
├── widgets/           # Reusable UI components (buttons, cards, input fields)
├── models/            # Data structures (Customer, Visit, Reward models)
└── services/          # Firebase & API logic (auth, firestore operations)
```

### 📂 Directory Purposes

| Directory | Purpose | Example Files |
|-----------|---------|---------------|
| **screens/** | Full-page views representing different app sections | `login_screen.dart`, `dashboard_screen.dart`, `customers_screen.dart` |
| **widgets/** | Reusable UI components used across multiple screens | `custom_button.dart`, `customer_card.dart`, `stats_widget.dart` |
| **models/** | Data classes defining structure of entities | `customer.dart`, `visit.dart`, `reward.dart` |
| **services/** | Business logic, Firebase integration, and API calls | `auth_service.dart`, `firestore_service.dart`, `rewards_service.dart` |

### 🎯 Benefits of This Structure

- **Modularity**: Each folder has a single responsibility, making code easier to understand
- **Scalability**: New features can be added without disrupting existing code
- **Reusability**: Widgets and services can be shared across multiple screens
- **Maintainability**: Clear organization makes debugging and updates faster
- **Team Collaboration**: Multiple developers can work on different modules simultaneously

### 📝 Naming Conventions

- **Files**: `snake_case` (e.g., `customer_screen.dart`, `auth_service.dart`)
- **Classes**: `PascalCase` (e.g., `CustomerScreen`, `AuthService`)
- **Variables/Functions**: `camelCase` (e.g., `userName`, `getUserData()`)
- **Private members**: Prefix with underscore (e.g., `_counter`, `_updateState()`)

---

## 🚀 Setup Instructions

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (v3.0 or higher)
- **Android Studio** or **VS Code** with Flutter & Dart extensions
- **Git** for version control
- A physical device or emulator for testing

### Step 1: Install Flutter SDK

#### Windows
1. Download Flutter SDK from [flutter.dev](https://flutter.dev)
2. Extract to `C:\src\flutter`
3. Add Flutter to PATH:
   - Search "Environment Variables" → Edit System Variables
   - Add `C:\src\flutter\bin` to Path
4. Verify installation:
   ```bash
   flutter doctor
   ```

#### macOS/Linux
```bash
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
```

### Step 2: Set Up Android Studio / VS Code

**Android Studio:**
- Install Flutter and Dart plugins
- Set up Android SDK and emulator

**VS Code:**
```bash
# Install extensions
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
```

### Step 3: Clone and Run This Project

```bash
# Navigate to the project folder
cd customerloop

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Step 4: Verify Installation

Run `flutter doctor` to check for any missing dependencies:

```bash
flutter doctor -v
```

All checkmarks should be green. If issues appear, follow the suggested fixes.

---

## 🎨 Demo

### Welcome Screen

The app now features a custom **Welcome Screen** with:
- ✅ **AppBar** with "Customer Loop" title
- ✅ **Dynamic Icon** that changes on button press
- ✅ **Column Layout** with centered content
- ✅ **State Management** - button toggles theme and text
- ✅ **Smooth Animations** and Material Design 3

![App Screenshot](./screenshots/welcome_screen.png)

*Screenshot will be added after running the app*

---

## 💭 Reflection

### What I Learned About Dart & Flutter

**Dart Language:**
- Strong typing with null safety ensures fewer runtime errors
- `setState()` is the core of reactive UI updates
- Dart's syntax is clean and easy to learn for those familiar with Java/JavaScript

**Flutter Framework:**
- Everything is a widget - composability is powerful
- Hot reload speeds up development significantly
- Material Design components are ready to use out of the box
- State management (StatefulWidget vs StatelessWidget) is intuitive

### How This Structure Helps Build Complex UIs

1. **Separation of Concerns**: UI (screens/widgets) is separate from logic (services/models)
2. **Component Reusability**: Custom widgets can be used across multiple screens
3. **Easy Testing**: Each module can be tested independently
4. **Firebase Integration**: Services layer provides clean abstraction for backend operations
5. **Future-Proof**: Adding new features (like notifications or analytics) won't require restructuring

### Next Steps

- Build authentication screens using Firebase Auth
- Implement customer management with Firestore
- Create a reward redemption flow
- Add real-time data synchronization
- Test on multiple devices and screen sizes

---
