import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  final String id;
  final String ownerId;
  final String name;
  final DateTime createdAt;

  ShopModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.createdAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory ShopModel.fromMap(String id, Map<String, dynamic> map) {
    return ShopModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create from Firestore DocumentSnapshot
  factory ShopModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShopModel.fromMap(doc.id, data);
  }
}
