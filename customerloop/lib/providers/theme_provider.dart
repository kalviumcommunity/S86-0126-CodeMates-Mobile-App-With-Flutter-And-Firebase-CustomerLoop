import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Provider for managing app theme state
/// Assignment 3.46: Themed UIs with Dark Mode and Dynamic Colors
///
/// Features:
/// - Light/Dark/System theme modes
/// - Persistent theme selection
/// - Dynamic theme switching
/// - Automatic system theme detection
class ThemeProvider with ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Check if provider is initialized
  bool get isInitialized => _isInitialized;

  /// Check if dark mode is currently active
  /// Takes into account system theme when mode is system
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Load saved theme preference from SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeModeKey);

      if (themeModeIndex != null) {
        _themeMode = ThemeMode.values[themeModeIndex];
        debugPrint('🎨 Loaded theme mode from prefs: $_themeMode');
      } else {
        debugPrint('🎨 No saved theme mode, using system default');
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading theme from prefs: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveThemeToPrefs(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
      debugPrint('✅ Saved theme mode to prefs: $mode');
    } catch (e) {
      debugPrint('❌ Error saving theme to prefs: $e');
    }
  }

  /// Set theme mode and persist
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    await _saveThemeToPrefs(mode);

    debugPrint('🎨 Theme mode changed to: $mode');
  }

  /// Toggle between light and dark mode
  /// If current mode is system, switches to dark
  Future<void> toggleTheme(BuildContext context) async {
    final isDark = isDarkMode(context);

    if (isDark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  /// Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Set system theme (follows device setting)
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Get theme mode display name
  String get themeModeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Get theme mode description
  String get themeModeDescription {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Always use light theme';
      case ThemeMode.dark:
        return 'Always use dark theme';
      case ThemeMode.system:
        return 'Follow system settings';
    }
  }

  /// Get theme mode icon
  IconData get themeModeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  /// Clear saved theme preference (reset to system)
  Future<void> resetTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeModeKey);
      _themeMode = ThemeMode.system;
      notifyListeners();
      debugPrint('🎨 Theme preference cleared, reset to system');
    } catch (e) {
      debugPrint('❌ Error clearing theme preference: $e');
    }
  }
}
