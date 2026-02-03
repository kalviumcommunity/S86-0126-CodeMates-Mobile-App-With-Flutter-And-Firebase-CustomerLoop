import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Debug Console demonstration - App initialization log
  debugPrint('🚀 CustomerLoop App Starting...');
  debugPrint('🔥 Initializing Firebase...');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      // Auto-login flow: Listen to auth state changes and route accordingly
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          debugPrint('🔍 Auth State Check - Connection: ${snapshot.connectionState}');

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
