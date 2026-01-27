import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/widget_tree_demo_screen.dart';
import 'screens/debug_tools_demo_screen.dart';

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
      home: const LoginScreen(),
      routes: {
        '/demo': (context) => const WidgetTreeDemoScreen(),
        '/debug-demo': (context) => const DebugToolsDemoScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
