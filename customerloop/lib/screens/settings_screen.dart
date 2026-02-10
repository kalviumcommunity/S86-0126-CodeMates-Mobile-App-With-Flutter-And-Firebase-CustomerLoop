import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_state.dart';
import '../providers/counter_state.dart';
import '../providers/favorites_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeState>();
    final counterState = context.watch<CounterState>();
    final favoritesState = context.watch<FavoritesState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings Demo')),
      body: ListView(
        children: [
          // Theme Settings
          const _SectionHeader(title: 'Theme Settings'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(themeState.isDarkMode ? 'Enabled' : 'Disabled'),
            value: themeState.isDarkMode,
            secondary: Icon(
              themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            onChanged: (_) => context.read<ThemeState>().toggleTheme(),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Primary Color'),
            trailing: CircleAvatar(backgroundColor: themeState.primaryColor),
            onTap: () => _showColorPicker(context),
          ),

          const Divider(),

          // State Information
          const _SectionHeader(title: 'Current State'),
          ListTile(
            leading: const Icon(Icons.numbers),
            title: const Text('Counter Value'),
            trailing: Chip(
              label: Text('${counterState.count}'),
              backgroundColor: Colors.blue.withOpacity(0.2),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorite Items'),
            trailing: Chip(
              label: Text('${favoritesState.itemCount}'),
              backgroundColor: Colors.red.withOpacity(0.2),
            ),
          ),

          const Divider(),

          // Actions
          const _SectionHeader(title: 'Quick Actions'),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Reset Counter'),
            onTap: () {
              context.read<CounterState>().reset();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Counter reset!')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Favorites'),
            onTap: () {
              context.read<FavoritesState>().clearAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favorites cleared!')),
              );
            },
          ),

          const Divider(),

          // Information
          const _SectionHeader(title: 'About'),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'This demo showcases Provider state management:\n\n'
              '✓ Multiple providers (Counter, Favorites, Theme)\n'
              '✓ Shared state across screens\n'
              '✓ Reactive UI updates with context.watch()\n'
              '✓ State mutations with context.read()\n'
              '✓ Clean separation of concerns\n\n'
              'All changes are reflected instantly across the app!',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Choose Primary Color'),
            content: Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  colors.map((color) {
                    return InkWell(
                      onTap: () {
                        context.read<ThemeState>().setPrimaryColor(color);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                context.read<ThemeState>().primaryColor == color
                                    ? Colors.black
                                    : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
