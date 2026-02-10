import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/counter_state.dart';
import '../providers/favorites_state.dart';
import '../providers/theme_state.dart';
import 'counter_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class ProviderDemoHome extends StatelessWidget {
  const ProviderDemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    final counterState = context.watch<CounterState>();
    final favoritesState = context.watch<FavoritesState>();
    final themeState = context.watch<ThemeState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider State Management'),
        actions: [
          IconButton(
            icon: Icon(
              themeState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => context.read<ThemeState>().toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // State Overview Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Shared State Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatCard(
                          icon: Icons.numbers,
                          label: 'Counter',
                          value: '${counterState.count}',
                          color: Colors.blue,
                        ),
                        _StatCard(
                          icon: Icons.favorite,
                          label: 'Favorites',
                          value: '${favoritesState.itemCount}',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Navigation Buttons
            _NavigationButton(
              title: 'Counter Demo',
              description: 'Increment/Decrement with Provider',
              icon: Icons.add_circle_outline,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CounterScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _NavigationButton(
              title: 'Favorites Demo',
              description: 'Add/Remove items across screens',
              icon: Icons.favorite_border,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _NavigationButton(
              title: 'Settings Demo',
              description: 'Theme customization with Provider',
              icon: Icons.settings,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
            const Spacer(),

            // Quick Actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.read<CounterState>().increment(),
                  icon: const Icon(Icons.add),
                  label: const Text('Quick +1'),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.read<CounterState>().reset(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Counter'),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.read<FavoritesState>().clearAll(),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Favorites'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _NavigationButton({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
