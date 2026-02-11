import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// Theme Settings Screen
/// Assignment 3.46: Themed UIs with Dark Mode and Dynamic Colors
///
/// Features:
/// - Light/Dark/System theme selection
/// - Visual theme preview
/// - Persistent theme saving
/// - Theme toggle switch
/// - Theme info and benefits
class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme preview card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    themeProvider.themeModeIcon,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Current Theme',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    themeProvider.themeModeName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    themeProvider.themeModeDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Quick toggle switch
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: Text(
                isDark
                    ? 'Currently using dark theme'
                    : 'Currently using light theme',
              ),
              value: isDark,
              onChanged: (value) {
                themeProvider.toggleTheme(context);
              },
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Theme mode selection
          Text(
            'THEME MODE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Light mode option
          _buildThemeOption(
            context: context,
            title: 'Light Mode',
            subtitle: 'Always use light theme',
            icon: Icons.light_mode,
            mode: ThemeMode.light,
            currentMode: themeProvider.themeMode,
            onTap: () => themeProvider.setLightTheme(),
          ),

          // Dark mode option
          _buildThemeOption(
            context: context,
            title: 'Dark Mode',
            subtitle: 'Always use dark theme',
            icon: Icons.dark_mode,
            mode: ThemeMode.dark,
            currentMode: themeProvider.themeMode,
            onTap: () => themeProvider.setDarkTheme(),
          ),

          // System mode option
          _buildThemeOption(
            context: context,
            title: 'System Default',
            subtitle: 'Follow system appearance settings',
            icon: Icons.brightness_auto,
            mode: ThemeMode.system,
            currentMode: themeProvider.themeMode,
            onTap: () => themeProvider.setSystemTheme(),
          ),

          const SizedBox(height: 24),

          // Theme benefits info
          Text(
            'THEME BENEFITS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBenefitRow(
                    context,
                    Icons.visibility,
                    'Reduced Eye Strain',
                    'Dark mode reduces eye fatigue in low-light environments',
                  ),
                  const Divider(),
                  _buildBenefitRow(
                    context,
                    Icons.battery_charging_full,
                    'Battery Saving',
                    'Dark mode saves battery on OLED and AMOLED screens',
                  ),
                  const Divider(),
                  _buildBenefitRow(
                    context,
                    Icons.accessibility_new,
                    'Better Accessibility',
                    'Improves readability for users with visual sensitivities',
                  ),
                  const Divider(),
                  _buildBenefitRow(
                    context,
                    Icons.palette,
                    'Consistent Design',
                    'Maintains brand identity across light and dark themes',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Color preview section
          Text(
            'COLOR PREVIEW',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Colors',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildColorChip(
                        context,
                        'Primary',
                        Theme.of(context).colorScheme.primary,
                      ),
                      _buildColorChip(
                        context,
                        'Secondary',
                        Theme.of(context).colorScheme.secondary,
                      ),
                      _buildColorChip(
                        context,
                        'Surface',
                        Theme.of(context).colorScheme.surface,
                      ),
                      _buildColorChip(
                        context,
                        'Background',
                        Theme.of(context).colorScheme.background,
                      ),
                      _buildColorChip(
                        context,
                        'Error',
                        Theme.of(context).colorScheme.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Sample UI elements
          Text(
            'UI ELEMENTS PREVIEW',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Elevated Button'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Outlined Button'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Text Button'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Text Field',
                      hintText: 'Enter some text',
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Chip(
                        label: const Text('Chip'),
                        avatar: const Icon(Icons.star, size: 16),
                      ),
                      const CircularProgressIndicator(),
                      IconButton(
                        icon: const Icon(Icons.favorite),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Reset button
          OutlinedButton.icon(
            onPressed: () async {
              await themeProvider.resetTheme();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Theme reset to system default'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset to System Default'),
          ),

          const SizedBox(height: 8),

          // Info text
          Text(
            'Theme preference is saved automatically and will persist across app restarts.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;

    return Card(
      elevation: isSelected ? 4 : 1,
      color:
          isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : null,
      child: ListTile(
        leading: Icon(
          icon,
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).iconTheme.color,
          size: 32,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing:
            isSelected
                ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
                : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildBenefitRow(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _getContrastingTextColor(color),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
