import 'package:flutter/material.dart';
import 'screens/state_management_demo.dart';

void main() {
  runApp(const _DemoApp());
}

class _DemoApp extends StatelessWidget {
  const _DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'State Management Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StateManagementDemo(),
    );
  }
}
