import 'package:cloud_firestore/cloud_firestore.dart';

/// ItemModel - Represents a user's personal item/note/task
/// Used for demonstrating complete CRUD operations
/// Assignment 3.42: Basic CRUD Flow with Firestore and Auth
class ItemModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String userId;

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    required this.userId,
  });

  /// Create ItemModel from Firestore document
  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ItemModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt:
          data['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
              : DateTime.now(),
      updatedAt:
          data['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int)
              : null,
      userId: data['userId'] ?? '',
    );
  }

  /// Create ItemModel from JSON Map
  factory ItemModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ItemModel(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt:
          data['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
              : DateTime.now(),
      updatedAt:
          data['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int)
              : null,
      userId: data['userId'] ?? '',
    );
  }

  /// Convert ItemModel to JSON Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'userId': userId,
    };
  }

  /// Create a copy with updated fields
  ItemModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  /// Get formatted creation date
  String get formattedCreatedAt {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} '
        '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted update date
  String get formattedUpdatedAt {
    if (updatedAt == null) return 'Never';
    return '${updatedAt!.day}/${updatedAt!.month}/${updatedAt!.year} '
        '${updatedAt!.hour.toString().padLeft(2, '0')}:${updatedAt!.minute.toString().padLeft(2, '0')}';
  }

  /// Check if item was updated
  bool get wasUpdated => updatedAt != null;

  @override
  String toString() {
    return 'ItemModel(id: $id, title: $title, userId: $userId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        userId.hashCode;
  }
}
