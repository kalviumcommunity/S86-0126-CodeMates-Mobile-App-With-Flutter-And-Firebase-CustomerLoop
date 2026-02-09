import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';

/// ItemsService - Handles all CRUD operations for user items
/// Demonstrates complete Create, Read, Update, Delete flow
/// Assignment 3.42: Basic CRUD Flow with Firestore and Auth
class ItemsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get reference to user's items collection
  CollectionReference _getUserItemsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('items');
  }

  // ============================================
  // CREATE
  // ============================================

  /// Create a new item for the current user
  Future<String> createItem({
    required String title,
    required String description,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final itemsRef = _getUserItemsCollection(userId);

      final docRef = await itemsRef.add({
        'title': title,
        'description': description,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': null,
        'userId': userId,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }

  /// Create item with custom ItemModel
  Future<String> createItemFromModel(ItemModel item) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final itemsRef = _getUserItemsCollection(userId);
      final docRef = await itemsRef.add(item.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }

  // ============================================
  // READ
  // ============================================

  /// Stream all items for current user (real-time)
  Stream<List<ItemModel>> streamUserItems() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _getUserItemsCollection(
      userId,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    });
  }

  /// Get all items for current user (one-time fetch)
  Future<List<ItemModel>> getUserItems() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot =
          await _getUserItemsCollection(
            userId,
          ).orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  /// Get a single item by ID
  Future<ItemModel?> getItemById(String itemId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _getUserItemsCollection(userId).doc(itemId).get();

      if (!doc.exists) {
        return null;
      }

      return ItemModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch item: $e');
    }
  }

  /// Search items by title
  Future<List<ItemModel>> searchItemsByTitle(String searchQuery) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot =
          await _getUserItemsCollection(userId)
              .where('title', isGreaterThanOrEqualTo: searchQuery)
              .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff')
              .get();

      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search items: $e');
    }
  }

  /// Get items count for current user
  Future<int> getItemsCount() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _getUserItemsCollection(userId).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to count items: $e');
    }
  }

  // ============================================
  // UPDATE
  // ============================================

  /// Update an item's title and description
  Future<void> updateItem({
    required String itemId,
    String? title,
    String? description,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (title != null) {
        updateData['title'] = title;
      }

      if (description != null) {
        updateData['description'] = description;
      }

      await _getUserItemsCollection(userId).doc(itemId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  /// Update item with full ItemModel
  Future<void> updateItemFromModel(ItemModel item) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final updateData = item.toMap();
      updateData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      await _getUserItemsCollection(userId).doc(item.id).update(updateData);
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  /// Update only title
  Future<void> updateItemTitle(String itemId, String newTitle) async {
    await updateItem(itemId: itemId, title: newTitle);
  }

  /// Update only description
  Future<void> updateItemDescription(
    String itemId,
    String newDescription,
  ) async {
    await updateItem(itemId: itemId, description: newDescription);
  }

  // ============================================
  // DELETE
  // ============================================

  /// Delete a single item
  Future<void> deleteItem(String itemId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _getUserItemsCollection(userId).doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  /// Delete multiple items at once
  Future<void> deleteMultipleItems(List<String> itemIds) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final batch = _firestore.batch();
      final itemsRef = _getUserItemsCollection(userId);

      for (final itemId in itemIds) {
        batch.delete(itemsRef.doc(itemId));
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete items: $e');
    }
  }

  /// Delete all items for current user
  Future<void> deleteAllItems() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _getUserItemsCollection(userId).get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all items: $e');
    }
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Check if item exists
  Future<bool> itemExists(String itemId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return false;
      }

      final doc = await _getUserItemsCollection(userId).doc(itemId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get items created today
  Future<List<ItemModel>> getItemsCreatedToday() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final startTimestamp = startOfDay.millisecondsSinceEpoch;

      final snapshot =
          await _getUserItemsCollection(userId)
              .where('createdAt', isGreaterThanOrEqualTo: startTimestamp)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch today\'s items: $e');
    }
  }

  /// Get recently updated items
  Future<List<ItemModel>> getRecentlyUpdatedItems({int limit = 10}) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot =
          await _getUserItemsCollection(userId)
              .where('updatedAt', isNotEqualTo: null)
              .orderBy('updatedAt', descending: true)
              .limit(limit)
              .get();

      return snapshot.docs.map((doc) => ItemModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch updated items: $e');
    }
  }
}
