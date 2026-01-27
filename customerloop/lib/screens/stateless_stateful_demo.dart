import 'package:flutter/material.dart';

/// Stateless vs Stateful Widgets Demo
/// This screen demonstrates the difference between StatelessWidget and StatefulWidget
///
/// StatelessWidget: Used for static UI that doesn't change
/// StatefulWidget: Used for dynamic UI that responds to user interactions

// ============================================================================
// MAIN DEMO SCREEN (Stateful - manages the overall app state)
// ============================================================================

class StatelessStatefulDemoScreen extends StatefulWidget {
  const StatelessStatefulDemoScreen({super.key});

  @override
  State<StatelessStatefulDemoScreen> createState() =>
      _StatelessStatefulDemoScreenState();
}

class _StatelessStatefulDemoScreenState
    extends State<StatelessStatefulDemoScreen> {
  // State variables for the demo
  int _clickCounter = 0;
  bool _isDarkMode = false;
  Color _selectedColor = Colors.blue;
  bool _isToggled = false;
  String _selectedFruit = 'Apple';

  // Available colors for color picker
  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  // Available fruits for dropdown
  final List<String> _fruits = ['Apple', 'Banana', 'Orange', 'Mango', 'Grape'];

  void _incrementCounter() {
    setState(() {
      _clickCounter++;
    });
  }

  void _resetCounter() {
    setState(() {
      _clickCounter = 0;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _changeColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _toggleSwitch(bool value) {
    setState(() {
      _isToggled = value;
    });
  }

  void _changeFruit(String? fruit) {
    if (fruit != null) {
      setState(() {
        _selectedFruit = fruit;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Stateless vs Stateful Widgets'),
        backgroundColor: _selectedColor,
        elevation: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== STATELESS WIDGETS SECTION =====
              _buildStatelessSection(),
              const SizedBox(height: 24),

              // ===== STATEFUL WIDGETS SECTION =====
              _buildStatefulSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // STATELESS WIDGETS SECTION
  // ============================================================================
  Widget _buildStatelessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header (Stateless)
        StaticHeader(
          title: '📄 Stateless Widgets',
          subtitle: 'Widgets that never change once built',
          color: Colors.blue,
          isDark: _isDarkMode,
        ),
        const SizedBox(height: 16),

        // Example 1: Static Info Card
        StaticInfoCard(
          icon: Icons.info_outline,
          title: 'What is a Stateless Widget?',
          description:
              'A StatelessWidget describes part of the UI that does not change over time. '
              'It is immutable and rebuilt only when its parent rebuilds it with new data.',
          isDark: _isDarkMode,
        ),
        const SizedBox(height: 12),

        // Example 2: Static Label
        StaticLabel(
          label: 'Current Counter Value:',
          value: '$_clickCounter',
          isDark: _isDarkMode,
        ),
        const SizedBox(height: 12),

        // Example 3: Static Welcome Message
        WelcomeMessage(name: 'Flutter Developer', isDark: _isDarkMode),
        const SizedBox(height: 12),

        // Example 4: Static Feature List
        FeatureListCard(
          features: const [
            'Immutable (cannot change)',
            'Rebuilds when parent changes',
            'No setState() method',
            'Lightweight and efficient',
          ],
          isDark: _isDarkMode,
        ),
      ],
    );
  }

  // ============================================================================
  // STATEFUL WIDGETS SECTION
  // ============================================================================
  Widget _buildStatefulSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header (Stateless, but displays stateful data)
        StaticHeader(
          title: '🔄 Stateful Widgets',
          subtitle: 'Widgets that change dynamically with user interaction',
          color: Colors.green,
          isDark: _isDarkMode,
        ),
        const SizedBox(height: 16),

        // Example 1: Counter Widget
        CounterCard(
          counter: _clickCounter,
          onIncrement: _incrementCounter,
          onReset: _resetCounter,
          isDark: _isDarkMode,
        ),
        const SizedBox(height: 12),

        // Example 2: Theme Toggle Widget
        ThemeToggleCard(
          isDarkMode: _isDarkMode,
          onToggle: _toggleTheme,
          isDark: _isDarkMode,
        ),
        const SizedBox(height: 12),

        // Example 3: Color Picker Widget
        ColorPickerCard(
          colors: _colors,
          selectedColor: _selectedColor,
          onColorSelected: _changeColor,
          isDark: _isDarkMode,
        ),
        const SizedBox(height: 12),

        // Example 4: Toggle Switch Widget
        ToggleSwitchCard(
          isToggled: _isToggled,
          onToggle: _toggleSwitch,
          isDark: _isDarkMode,
        ),
        const SizedBox(height: 12),

        // Example 5: Dropdown Widget
        DropdownCard(
          fruits: _fruits,
          selectedFruit: _selectedFruit,
          onFruitChanged: _changeFruit,
          isDark: _isDarkMode,
        ),
      ],
    );
  }
}

// ============================================================================
// STATELESS WIDGET EXAMPLES
// ============================================================================

/// Stateless Widget: Static Header
/// This widget never changes on its own - it only updates when parent rebuilds it
class StaticHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;

  const StaticHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stateless Widget: Info Card
/// Displays static information that doesn't change
class StaticInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDark;

  const StaticInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stateless Widget: Static Label
/// Displays a label with a value (the value comes from parent)
class StaticLabel extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const StaticLabel({
    super.key,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stateless Widget: Welcome Message
/// Displays a personalized greeting (static until parent changes it)
class WelcomeMessage extends StatelessWidget {
  final String name;
  final bool isDark;

  const WelcomeMessage({super.key, required this.name, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.waving_hand, color: Colors.amber, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Welcome, $name!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stateless Widget: Feature List
/// Displays a static list of features
class FeatureListCard extends StatelessWidget {
  final List<String> features;
  final bool isDark;

  const FeatureListCard({
    super.key,
    required this.features,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Characteristics:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// STATEFUL WIDGET EXAMPLES
// ============================================================================

/// Stateful Widget: Counter Card
/// Manages its own counter state and updates UI on button press
class CounterCard extends StatefulWidget {
  final int counter;
  final VoidCallback onIncrement;
  final VoidCallback onReset;
  final bool isDark;

  const CounterCard({
    super.key,
    required this.counter,
    required this.onIncrement,
    required this.onReset,
    required this.isDark,
  });

  @override
  State<CounterCard> createState() => _CounterCardState();
}

class _CounterCardState extends State<CounterCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: widget.isDark ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.touch_app, size: 48, color: Colors.blue),
            const SizedBox(height: 12),
            Text(
              'Interactive Counter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.counter}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: widget.counter > 10 ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.onIncrement,
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: widget.onReset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Click buttons to update state!',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stateful Widget: Theme Toggle Card
class ThemeToggleCard extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;
  final bool isDark;

  const ThemeToggleCard({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
    required this.isDark,
  });

  @override
  State<ThemeToggleCard> createState() => _ThemeToggleCardState();
}

class _ThemeToggleCardState extends State<ThemeToggleCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: widget.isDark ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 48,
              color: widget.isDarkMode ? Colors.amber : Colors.orange,
            ),
            const SizedBox(height: 12),
            Text(
              widget.isDarkMode ? 'Dark Mode Active' : 'Light Mode Active',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: widget.onToggle,
              icon: Icon(
                widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              label: Text(
                widget.isDarkMode ? 'Switch to Light' : 'Switch to Dark',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toggle changes entire app theme!',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stateful Widget: Color Picker Card
class ColorPickerCard extends StatefulWidget {
  final List<Color> colors;
  final Color selectedColor;
  final Function(Color) onColorSelected;
  final bool isDark;

  const ColorPickerCard({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
    required this.isDark,
  });

  @override
  State<ColorPickerCard> createState() => _ColorPickerCardState();
}

class _ColorPickerCardState extends State<ColorPickerCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: widget.isDark ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: widget.selectedColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Dynamic Color Picker',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children:
                  widget.colors.map((color) {
                    final isSelected = color == widget.selectedColor;
                    return GestureDetector(
                      onTap: () => widget.onColorSelected(color),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child:
                            isSelected
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap colors to change AppBar!',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stateful Widget: Toggle Switch Card
class ToggleSwitchCard extends StatefulWidget {
  final bool isToggled;
  final Function(bool) onToggle;
  final bool isDark;

  const ToggleSwitchCard({
    super.key,
    required this.isToggled,
    required this.onToggle,
    required this.isDark,
  });

  @override
  State<ToggleSwitchCard> createState() => _ToggleSwitchCardState();
}

class _ToggleSwitchCardState extends State<ToggleSwitchCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: widget.isDark ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              widget.isToggled ? Icons.toggle_on : Icons.toggle_off,
              size: 64,
              color: widget.isToggled ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              widget.isToggled ? 'Feature Enabled' : 'Feature Disabled',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Switch(
              value: widget.isToggled,
              onChanged: widget.onToggle,
              thumbColor: WidgetStateProperty.all(Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              'Switch toggles state dynamically!',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stateful Widget: Dropdown Card
class DropdownCard extends StatefulWidget {
  final List<String> fruits;
  final String selectedFruit;
  final Function(String?) onFruitChanged;
  final bool isDark;

  const DropdownCard({
    super.key,
    required this.fruits,
    required this.selectedFruit,
    required this.onFruitChanged,
    required this.isDark,
  });

  @override
  State<DropdownCard> createState() => _DropdownCardState();
}

class _DropdownCardState extends State<DropdownCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: widget.isDark ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.apple, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              'Selected: ${widget.selectedFruit}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: widget.selectedFruit,
              isExpanded: true,
              items:
                  widget.fruits.map((String fruit) {
                    return DropdownMenuItem<String>(
                      value: fruit,
                      child: Text(fruit),
                    );
                  }).toList(),
              onChanged: widget.onFruitChanged,
              dropdownColor: widget.isDark ? Colors.grey[800] : Colors.white,
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dropdown manages selection state!',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
