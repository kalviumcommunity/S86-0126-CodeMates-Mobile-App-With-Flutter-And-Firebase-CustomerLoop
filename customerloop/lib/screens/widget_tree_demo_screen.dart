import 'package:flutter/material.dart';

/// Widget Tree Demo Screen
/// This screen demonstrates Flutter's widget tree hierarchy and reactive UI model
/// 
/// Widget Tree Structure:
/// Scaffold
///  ┣ AppBar (with title)
///  ┗ Body (SafeArea)
///     ┗ SingleChildScrollView
///        ┗ Padding
///           ┗ Column
///              ┣ Card (Counter Section)
///              ┃  ┗ Column
///              ┃     ┣ Icon (dynamic color)
///              ┃     ┣ Text (counter value - stateful)
///              ┃     ┗ Row (increment/decrement buttons)
///              ┣ Card (Theme Toggle Section)
///              ┃  ┗ Column
///              ┃     ┣ Icon (theme mode icon)
///              ┃     ┣ Text (theme description)
///              ┃     ┗ ElevatedButton (toggle theme)
///              ┣ Card (Color Picker Section)
///              ┃  ┗ Column
///              ┃     ┣ Container (color preview box)
///              ┃     ┣ Text (color description)
///              ┃     ┗ Wrap (color selection buttons)
///              ┗ Card (Widget Visibility Section)
///                 ┗ Column
///                    ┣ SwitchListTile (visibility toggle)
///                    ┗ AnimatedContainer (conditionally visible widget)
class WidgetTreeDemoScreen extends StatefulWidget {
  const WidgetTreeDemoScreen({super.key});

  @override
  State<WidgetTreeDemoScreen> createState() => _WidgetTreeDemoScreenState();
}

class _WidgetTreeDemoScreenState extends State<WidgetTreeDemoScreen> {
  // State variables - when these change, Flutter rebuilds affected widgets
  int _counter = 0;
  bool _isDarkMode = false;
  Color _selectedColor = Colors.blue;
  bool _showExtraWidget = false;

  // Available colors for the color picker
  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  /// Increment counter - demonstrates reactive UI
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  /// Decrement counter - demonstrates reactive UI
  void _decrementCounter() {
    setState(() {
      if (_counter > 0) _counter--;
    });
  }

  /// Toggle theme mode - demonstrates state change affecting multiple widgets
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  /// Change selected color - demonstrates visual state update
  void _changeColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  /// Toggle widget visibility - demonstrates conditional rendering
  void _toggleWidgetVisibility(bool value) {
    setState(() {
      _showExtraWidget = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Widget Tree & Reactive UI Demo'),
        backgroundColor: _selectedColor,
        elevation: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section 1: Counter with Reactive Updates
                _buildCounterSection(),
                const SizedBox(height: 16),

                // Section 2: Theme Toggle
                _buildThemeToggleSection(),
                const SizedBox(height: 16),

                // Section 3: Color Picker
                _buildColorPickerSection(),
                const SizedBox(height: 16),

                // Section 4: Widget Visibility Toggle
                _buildVisibilityToggleSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Counter Section - Demonstrates setState() and reactive UI
  Widget _buildCounterSection() {
    return Card(
      elevation: 4,
      color: _isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.looks_one,
              size: 48,
              color: _counter > 10 ? Colors.green : _selectedColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Counter Value',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_counter',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _selectedColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _decrementCounter,
                  icon: const Icon(Icons.remove),
                  label: const Text('Decrement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _incrementCounter,
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tap buttons to see reactive UI update!',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Theme Toggle Section - Demonstrates global state affecting multiple widgets
  Widget _buildThemeToggleSection() {
    return Card(
      elevation: 4,
      color: _isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 48,
              color: _selectedColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Theme Mode',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isDarkMode ? 'Dark Mode Active' : 'Light Mode Active',
              style: TextStyle(
                fontSize: 16,
                color: _isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _toggleTheme,
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              label: Text(_isDarkMode ? 'Switch to Light' : 'Switch to Dark'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Notice how multiple widgets update together!',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Color Picker Section - Demonstrates visual state changes
  Widget _buildColorPickerSection() {
    return Card(
      elevation: 4,
      color: _isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _selectedColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Selected Theme Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap a color to change the theme',
              style: TextStyle(
                fontSize: 14,
                color: _isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _availableColors.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () => _changeColor(color),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              'AppBar and buttons update instantly!',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget Visibility Section - Demonstrates conditional rendering
  Widget _buildVisibilityToggleSection() {
    return Card(
      elevation: 4,
      color: _isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                'Show Extra Widget',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Text(
                'Toggle to add/remove widget from tree',
                style: TextStyle(
                  fontSize: 14,
                  color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              value: _showExtraWidget,
              onChanged: _toggleWidgetVisibility,
              activeThumbColor: _selectedColor,
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _showExtraWidget ? 120 : 0,
              child: _showExtraWidget
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _selectedColor.withOpacity(0.3),
                            _selectedColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.celebration,
                              size: 40,
                              color: _selectedColor,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'I\'m a dynamic widget!',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _selectedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            if (_showExtraWidget) const SizedBox(height: 12),
            Text(
              _showExtraWidget
                  ? 'Widget added to the tree dynamically!'
                  : 'Widget removed from the tree',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
