import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/counter_state.dart';
import 'providers/favorites_state.dart';
import 'providers/theme_state.dart';
import 'screens/provider_demo_home.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterState()),
        ChangeNotifierProvider(create: (_) => FavoritesState()),
        ChangeNotifierProvider(create: (_) => ThemeState()),
      ],
      child: const _DemoApp(),
    ),
  );
}

class _DemoApp extends StatelessWidget {
  const _DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeState>();
    
    return MaterialApp(
      title: 'Provider State Management Demo',
      themeMode: themeState.themeMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeState.primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeState.primaryColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ProviderDemoHome(),
    );
  }
}
