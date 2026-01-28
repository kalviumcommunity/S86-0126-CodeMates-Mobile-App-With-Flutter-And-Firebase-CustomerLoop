# Multi-Screen Navigation Using Navigator and Routes - Sprint 2 Deliverable

## 📱 Project Overview

This implementation demonstrates **multi-screen navigation** in Flutter using the **Navigator** class and **named routes**. The CustomerLoop app includes 9 screens with seamless navigation, passing data between screens, and a well-structured routing system ready for production use.

---

## 🎯 Understanding Multi-Screen Navigation

### What is Navigator?

The **Navigator** manages a stack of screens (routes) in Flutter. Think of it as a stack of cards:
- **Push** = Add a new screen on top
- **Pop** = Remove the current screen and go back
- **Replace** = Remove current screen and add a new one

### Navigation Stack Example:
```
LoginScreen (bottom)
  → DashboardScreen (pushed)
    → RewardsScreen (pushed)
      → Current Screen (top)
```

When you call `Navigator.pop()`, it removes the top screen and shows the one below.

---

## 📂 App Structure

### Screens in CustomerLoop App:

1. **LoginScreen** (`/` or `/login`) - Entry point
2. **SignupScreen** (`/signup`) - User registration
3. **HomeScreen** (`/home`) - Main user screen with notes
4. **DashboardScreen** (`/dashboard`) - Analytics and overview
5. **RewardsScreen** (`/rewards`) - Customer loyalty points
6. **WidgetTreeDemoScreen** (`/widget-tree-demo`) - Sprint 2 Assignment 1
7. **StatelessStatefulDemoScreen** (`/stateless-stateful-demo`) - Sprint 2 Assignment 2
8. **DebugToolsDemoScreen** (`/debug-demo`) - Sprint 2 Assignment 3

---

## 🔧 Implementation Details

### 1. Defining Routes in main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/widget_tree_demo_screen.dart';
import 'screens/stateless_stateful_demo.dart';
import 'screens/debug_tools_demo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('🚀 CustomerLoop App Starting...');
  debugPrint('🔥 Initializing Firebase...');
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  
  debugPrint('✅ Firebase initialized successfully');
  debugPrint('📱 Launching app...');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CustomerLoop - Loyalty Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      // Initial route - app starts here
      initialRoute: '/',
      // Named routes map
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/rewards': (context) => const RewardsScreen(),
        '/widget-tree-demo': (context) => const WidgetTreeDemoScreen(),
        '/stateless-stateful-demo': (context) => const StatelessStatefulDemoScreen(),
        '/debug-demo': (context) => const DebugToolsDemoScreen(),
      },
    );
  }
}
```

### Key Components:
- **`initialRoute`** - The starting screen when app launches (`'/'` = LoginScreen)
- **`routes`** - Map of route names to screen widgets
- **Named routes** - Use string names instead of constructors for navigation

---

## 🚀 Navigation Methods Used

### Method 1: Navigator.push() - Direct Navigation
```dart
// Navigate to a screen without named routes
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => DashboardScreen()),
);
```

**Used in:** Login/Signup screens for authenticated routes

### Method 2: Navigator.pushNamed() - Named Route Navigation
```dart
// Navigate using route name
Navigator.pushNamed(context, '/dashboard');
```

**Used in:** Demo buttons on login screen

### Method 3: Navigator.pushReplacement() - Replace Current Screen
```dart
// Replace current screen (can't go back)
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => HomeScreen()),
);
```

**Used in:** Login → Home (user shouldn't go back to login)

### Method 4: Navigator.pushReplacementNamed() - Replace with Named Route
```dart
// Replace using route name
Navigator.pushReplacementNamed(context, '/login');
```

**Used in:** Logout functionality

### Method 5: Navigator.pop() - Go Back
```dart
// Return to previous screen
Navigator.pop(context);
```

**Used in:** AppBar back buttons, demo screens

### Method 6: Navigator.popUntil() - Go Back Multiple Screens
```dart
// Go back to first route
Navigator.popUntil(context, (route) => route.isFirst);
```

**Used in:** Logout (go back to login from any screen)

---

## 📝 Real Implementation Examples

### Example 1: Login to Dashboard Navigation

**From LoginScreen:**
```dart
// After successful login
if (user != null && mounted) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const DashboardScreen(),
    ),
  );
}
```

**Why `pushReplacement`?**
- User can't press back to go to login screen after successful login
- Improves UX and security

---

### Example 2: Login to Signup Navigation

**From LoginScreen:**
```dart
GestureDetector(
  onTap: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  },
  child: Text('Sign Up'),
)
```

**Why `pushReplacement`?**
- Switching between login/signup replaces screen instead of stacking

---

### Example 3: Demo Navigation with Named Routes

**From LoginScreen:**
```dart
OutlinedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WidgetTreeDemoScreen(),
      ),
    );
  },
  icon: const Icon(Icons.account_tree),
  label: const Text('View Widget Tree Demo'),
)
```

**Could be refactored to:**
```dart
OutlinedButton.icon(
  onPressed: () {
    Navigator.pushNamed(context, '/widget-tree-demo');
  },
  icon: const Icon(Icons.account_tree),
  label: const Text('View Widget Tree Demo'),
)
```

---

### Example 4: Logout Navigation

**From DashboardScreen:**
```dart
Future<void> _handleLogout() async {
  await _authService.logout();
  if (mounted) {
    Navigator.pushReplacementNamed(context, '/login');
  }
}
```

**Why `pushReplacementNamed`?**
- Clears navigation stack
- User can't go back after logout

---

## 🎨 Navigation Flow Diagram

```
App Launch
    ↓
LoginScreen (/)
    ├→ [Login Success] → DashboardScreen (pushReplacement)
    │                        ├→ HomeScreen (bottom nav)
    │                        ├→ RewardsScreen (bottom nav)
    │                        └→ Logout → LoginScreen (pushReplacementNamed)
    │
    ├→ [Sign Up Link] → SignupScreen (pushReplacement)
    │                       └→ [Back] → LoginScreen
    │
    ├→ [Widget Tree Demo] → WidgetTreeDemoScreen (push)
    │                           └→ [Back] → LoginScreen (pop)
    │
    └→ [Stateless/Stateful Demo] → StatelessStatefulDemoScreen (push)
                                       └→ [Back] → LoginScreen (pop)
```

---

## 🔄 Passing Data Between Screens

### Method 1: Constructor Parameters

**Passing Data:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetailScreen(
      title: 'My Title',
      description: 'My Description',
    ),
  ),
);
```

**Receiving Data:**
```dart
class DetailScreen extends StatelessWidget {
  final String title;
  final String description;

  const DetailScreen({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Text(description),
    );
  }
}
```

### Method 2: Named Routes with Arguments

**Passing Data:**
```dart
Navigator.pushNamed(
  context,
  '/detail',
  arguments: {
    'title': 'My Title',
    'description': 'My Description',
  },
);
```

**Receiving Data:**
```dart
@override
Widget build(BuildContext context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
  
  final title = args?['title'] ?? 'No Title';
  final description = args?['description'] ?? 'No Description';
  
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Text(description),
  );
}
```

### Example in CustomerLoop:

**From DashboardScreen to RewardsScreen (currently using bottom nav):**
```dart
// Could pass customer data
Navigator.pushNamed(
  context,
  '/rewards',
  arguments: {
    'customerId': customer.id,
    'customerName': customer.name,
  },
);
```

---

## 📊 Benefits of Named Routes

### 1. **Centralized Configuration**
All routes defined in one place (`main.dart`) - easy to see entire app structure.

### 2. **Cleaner Code**
```dart
// Without named routes
Navigator.push(context, MaterialPageRoute(builder: (context) => VeryLongScreenName()));

// With named routes
Navigator.pushNamed(context, '/screen');
```

### 3. **Easy Refactoring**
Change screen implementation without updating navigation calls throughout the app.

### 4. **Deep Linking Ready**
Named routes work with URL deep linking for web/mobile integration.

### 5. **Testing**
Easier to test navigation flows by mocking route names.

### 6. **Dynamic Routing**
Can add route guards, authentication checks, or analytics in one place:
```dart
onGenerateRoute: (settings) {
  // Check authentication
  if (settings.name == '/dashboard' && !isLoggedIn) {
    return MaterialPageRoute(builder: (context) => LoginScreen());
  }
  // ... handle route
}
```

---

## 🎯 Navigator Stack Management

### How Navigator Manages the Stack:

```
Initial State:
[LoginScreen]

After Navigator.push(DashboardScreen):
[LoginScreen, DashboardScreen]  ← Current screen

After Navigator.pop():
[LoginScreen]  ← Back to this

After Navigator.pushReplacement(SignupScreen):
[SignupScreen]  ← LoginScreen removed, can't go back
```

### Stack Operations:

| Method | Stack Effect | Use Case |
|--------|-------------|----------|
| `push` | Adds on top | Navigate to new screen |
| `pop` | Removes top | Go back |
| `pushReplacement` | Replace top | Login → Home (no back) |
| `pushAndRemoveUntil` | Add + clear stack | Logout to login |
| `popUntil` | Remove until condition | Back to specific screen |

---

## 🐛 Common Navigation Pitfalls

### Issue 1: Using Context After Screen Disposed
```dart
// ❌ Wrong
void navigate() {
  someAsyncFunction();
  Navigator.push(...);  // Context might be invalid
}

// ✅ Correct
void navigate() async {
  await someAsyncFunction();
  if (mounted) {  // Check if widget still active
    Navigator.push(...);
  }
}
```

### Issue 2: Navigation in initState()
```dart
// ❌ Wrong
@override
void initState() {
  super.initState();
  Navigator.pushNamed(context, '/home');  // Context not ready
}

// ✅ Correct
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushNamed(context, '/home');
  });
}
```

### Issue 3: Memory Leaks with Push
```dart
// ❌ Creates stack buildup
onPressed: () {
  Navigator.push(...);  // Keeps adding to stack
}

// ✅ Use pushReplacement when appropriate
onPressed: () {
  Navigator.pushReplacement(...);  // Replaces current screen
}
```

---

## ✅ Implementation Checklist

### Code Implementation:
- [x] Created 8+ screens in `lib/screens/`
- [x] Defined named routes in `main.dart`
- [x] Set `initialRoute` to login screen
- [x] Implemented `Navigator.push()` for forward navigation
- [x] Implemented `Navigator.pop()` for back navigation
- [x] Used `pushReplacement` for authenticated flows
- [x] Used `pushReplacementNamed` for logout
- [x] All navigation tested and working

### Documentation:
- [x] Explained how Navigator manages stack
- [x] Documented all routes in app
- [x] Provided code examples
- [x] Explained benefits of named routes
- [x] Included navigation flow diagram

### Testing:
- [x] Login → Dashboard navigation works
- [x] Dashboard → Home/Rewards navigation works
- [x] Demo screens navigation works
- [x] Back button returns to previous screen
- [x] Logout clears navigation stack
- [x] No navigation errors or crashes

---

## 📸 Screenshots Guide

### Screenshot 1: Login Screen
**Route:** `/` or `/login`
**Shows:** Entry point with demo buttons

### Screenshot 2: Dashboard Screen
**Route:** `/dashboard`
**Shows:** Main app screen after login

### Screenshot 3: Navigation to Home
**Action:** Tap Home tab in bottom navigation
**Shows:** HomeScreen with notes list

### Screenshot 4: Navigation to Rewards
**Action:** Tap Rewards tab
**Shows:** RewardsScreen with customer points

### Screenshot 5: Demo Navigation
**Action:** From login, tap "Widget Tree Demo"
**Shows:** WidgetTreeDemoScreen opens

### Screenshot 6: Back Navigation
**Action:** Tap back button on demo screen
**Shows:** Returns to login screen

---

## 💭 Reflection Questions Answered

### How does Navigator manage the app's stack of screens?

Navigator uses a **Last-In-First-Out (LIFO) stack** to manage screens:

1. **Stack Structure**: Each screen is a "route" stored in a stack
2. **Push Operation**: Adds new screen on top, previous screen hidden below
3. **Pop Operation**: Removes top screen, reveals the one below
4. **State Preservation**: Screens below remain in memory (state preserved)
5. **Memory Management**: Flutter manages lifecycle automatically

**Example:**
```
User Flow: Login → Dashboard → Rewards → Settings

Stack Evolution:
[Login]
[Login, Dashboard]
[Login, Dashboard, Rewards]
[Login, Dashboard, Rewards, Settings] ← Current

After 3 pops:
[Login] ← Back to start
```

**Benefits:**
- ✅ Automatic back button handling
- ✅ State preserved when navigating back
- ✅ Clean memory management
- ✅ Predictable navigation behavior

---

### What are the benefits of using named routes in larger applications?

**1. Centralized Route Management**
- All routes in one place (`main.dart`)
- Easy to see entire app structure at a glance
- Simple to add/remove/modify routes

**2. Cleaner Code**
```dart
// Before (verbose)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VeryLongComplexScreenNameWidget(),
  ),
);

// After (clean)
Navigator.pushNamed(context, '/screen');
```

**3. Scalability**
- Easy to add new screens
- Routes can be organized by module/feature
- Supports micro-frontend architecture

**4. Deep Linking Support**
- Named routes work with web URLs
- Mobile deep linking integration
- Share specific screens via links

**5. Route Guards & Middleware**
- Add authentication checks globally
- Implement analytics tracking
- Handle permissions in one place

**6. Testing**
- Mock navigation by route names
- Test navigation flows easily
- Verify correct routes are called

**7. Dynamic Navigation**
- Conditionally show different screens
- A/B testing different flows
- Feature flags per route

**8. Maintainability**
- Refactor screen implementations without touching navigation
- Change screen structure without breaking navigation
- Clear separation of concerns

**Real-World Example:**
```dart
// Without named routes - scattered throughout app
Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
// Change screen? Update 100+ locations!

// With named routes - change once
Navigator.pushNamed(context, '/profile');
// Change ProfileScreen implementation → automatically reflected everywhere
```

---

## 🎓 Key Takeaways

### Navigation Best Practices:
1. ✅ Use named routes for better organization
2. ✅ Use `pushReplacement` for authenticated flows
3. ✅ Always check `mounted` before navigation in async functions
4. ✅ Clear stacks on logout with `pushAndRemoveUntil`
5. ✅ Pass data efficiently with constructor parameters or arguments
6. ✅ Keep routes centralized in `main.dart`

### CustomerLoop Navigation Architecture:
- **Entry Point**: LoginScreen (`/`)
- **Main Flow**: Login → Dashboard → Home/Rewards
- **Demo Flows**: Login → Demo Screens → Back to Login
- **Logout**: Any Screen → Login (stack cleared)

---

## 📚 Additional Resources

- [Flutter Navigation Documentation](https://docs.flutter.dev/cookbook/navigation)
- [Named Routes Guide](https://docs.flutter.dev/cookbook/navigation/named-routes)
- [Passing Data Between Screens](https://docs.flutter.dev/cookbook/navigation/passing-data)

---

## 🚀 Running the App

```bash
# Navigate to project
cd customerloop

# Run on Chrome (recommended)
flutter run -d chrome

# Or run on mobile device
flutter run
```

### Testing Navigation:
1. **Login Screen** → Enter credentials or click demo buttons
2. **Dashboard** → Use bottom navigation to switch screens
3. **Demo Screens** → Test back navigation
4. **Logout** → Verify returns to login

---

**Date:** January 28, 2026  
**Sprint:** 2  
**Assignment:** Multi-Screen Navigation  
**Team:** CodeMates  
**Status:** ✅ Complete and Documented
