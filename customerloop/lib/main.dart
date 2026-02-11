import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme_light.dart';
import 'theme/app_theme_dark.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Debug Console demonstration - App initialization log
  debugPrint('🚀 CustomerLoop App Starting...');
  debugPrint('🔥 Initializing Firebase...');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('✅ Firebase initialized successfully');

  // Initialize Firebase Cloud Messaging
  debugPrint('🔔 Initializing Push Notifications...');

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize notification service
  try {
    await NotificationService().initialize();
    debugPrint('✅ Push Notifications initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Push Notifications initialization failed: $e');
  }

  debugPrint('📱 Launching app...');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch theme provider for changes
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'CustomerLoop - Loyalty Platform',
      debugShowCheckedModeBanner: false,

      // Assignment 3.46: Theme support with light/dark/system modes
      theme: AppThemeLight.theme,
      darkTheme: AppThemeDark.theme,
      themeMode: themeProvider.themeMode,

      // Auto-login flow: Listen to auth state changes and route accordingly
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          debugPrint(
            '🔍 Auth State Check - Connection: ${snapshot.connectionState}',
          );

          // Firebase is checking session persistence
          if (snapshot.connectionState == ConnectionState.waiting) {
            debugPrint('⏳ Verifying user session...');
            return const SplashScreen();
          }

          // User is already logged in - show dashboard
          if (snapshot.hasData) {
            debugPrint('✅ User logged in: ${snapshot.data?.email}');
            return const DashboardScreen();
          }

          // User is not logged in - show login screen
          debugPrint('❌ No active session - showing login screen');
          return const LoginScreen();
        },
      ),
    );
  }
}
