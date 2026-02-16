import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'models/customer_model.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/role_resolver_screen.dart';
import 'screens/owner/owner_dashboard.dart';
import 'screens/owner/customers_screen.dart';
import 'screens/owner/owner_rewards_screen.dart';
import 'screens/owner/customer_history_screen.dart';
import 'screens/customer/customer_dashboard.dart';
import 'screens/customer/customer_rewards_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notification service
  await NotificationService().initialize();

  runApp(const CustomerLoopApp());
}

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

class CustomerLoopApp extends StatelessWidget {
  const CustomerLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Customer Loop',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.orange,
              primary: Colors.orange[700],
              secondary: Colors.amber[600],
              surface: Colors.white,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.orange,
              primary: Colors.orange[400],
              secondary: Colors.amber[300],
              surface: const Color(0xFF121212),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          home: const SplashScreen(),

          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/welcome': (context) => const WelcomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/role-resolver': (context) => const RoleResolverScreen(),
            '/owner-dashboard': (context) => const OwnerDashboard(),
            '/customer-dashboard': (context) => const CustomerDashboard(),
            '/profile': (context) => const ProfileScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/auth': (context) => const AuthWrapper(),
          },

          onGenerateRoute: (settings) {
            // ... (rest of the route generation logic remains same)
            if (settings.name == '/owner-customers') {
              final shopId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => CustomersScreen(shopId: shopId),
              );
            }
            if (settings.name == '/owner-rewards') {
              final shopId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => OwnerRewardsScreen(shopId: shopId),
              );
            }
            if (settings.name == '/customer-rewards') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder:
                    (context) => CustomerRewardsScreen(
                      shopId: args['shopId']!,
                      customerId: args['customerId']!,
                    ),
              );
            }
            if (settings.name == '/owner-customer-history') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder:
                    (context) => CustomerHistoryScreen(
                      shopId: args['shopId']!,
                      customer: args['customer'] as CustomerModel,
                    ),
              );
            }
            return null;
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is logged in
        if (snapshot.hasData) {
          return const RoleResolverScreen();
        }

        // User is not logged in
        return const WelcomeScreen();
      },
    );
  }
}
