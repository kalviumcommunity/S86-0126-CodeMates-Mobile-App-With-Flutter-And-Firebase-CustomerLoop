import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _controller = TextEditingController();

  final List<String> _suggestions = [
    '📚 Flutter',
    '🔥 Firebase',
    '💙 Dart',
    '📱 Mobile Dev',
    '🎨 UI Design',
    '🚀 Provider',
    '⚡ Riverpod',
    '🌟 State Management',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addFavorite(String item) {
    if (item.trim().isNotEmpty) {
      context.read<FavoritesState>().addItem(item.trim());
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "$item" to favorites'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesState = context.watch<FavoritesState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites Demo'),
        actions: [
          if (favoritesState.itemCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear All?'),
                    content: const Text('Remove all favorite items?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<FavoritesState>().clearAll();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: Column(
        children: [
          // Add Item Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Add to Favorites',
                    hintText: 'Enter item name',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () => _addFavorite(_controller.text),
                    ),
                  ),
                  onSubmitted: _addFavorite,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _suggestions
                      .where((s) => !favoritesState.contains(s))
                      .map(
                        (suggestion) => ActionChip(
                          label: Text(suggestion),
                          onPressed: () => _addFavorite(suggestion),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const Divider(),

          // Favorites List
          Expanded(
            child: favoritesState.itemCount == 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No favorites yet!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add items using the field above',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: favoritesState.itemCount,
                    itemBuilder: (context, index) {
                      final item = favoritesState.items[index];
                      return Dismissible(
                        key: Key(item),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          context.read<FavoritesState>().removeItem(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed "$item"'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  context.read<FavoritesState>().addItem(item);
                                },
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          title: Text(item),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              context.read<FavoritesState>().removeItem(item);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
