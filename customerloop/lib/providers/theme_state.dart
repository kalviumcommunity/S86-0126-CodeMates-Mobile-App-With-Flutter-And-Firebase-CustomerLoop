import 'package:flutter/material.dart';

class ThemeState with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = Colors.blue;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }
}
