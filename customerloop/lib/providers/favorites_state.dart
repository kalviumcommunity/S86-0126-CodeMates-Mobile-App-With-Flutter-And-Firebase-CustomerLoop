import 'package:flutter/material.dart';

class FavoritesState with ChangeNotifier {
  final List<String> _items = [];

  List<String> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  void addItem(String item) {
    if (!_items.contains(item)) {
      _items.add(item);
      notifyListeners();
    }
  }

  void removeItem(String item) {
    _items.remove(item);
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
  }

  bool contains(String item) {
    return _items.contains(item);
  }
}
