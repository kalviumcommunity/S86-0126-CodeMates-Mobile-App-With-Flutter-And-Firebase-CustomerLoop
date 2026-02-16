import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String role; // "owner" or "customer"
  final List<String>
  shopIds; // For customers, references their shops (can have multiple); for owners, their single shop
  final String name;
  final String email;
  final String? phone;
  final String? fcmToken;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.role,
    List<String>? shopIds,
    required this.name,
    required this.email,
    this.phone,
    this.fcmToken,
    required this.createdAt,
  }) : shopIds = shopIds ?? [];

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'shopIds': shopIds,
      'name': name,
      'email': email,
      'phone': phone,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    // Handle both old (shopId) and new (shopIds) format for backwards compatibility
    List<String> shopIdsList = [];
    if (map['shopIds'] != null) {
      shopIdsList = List<String>.from(map['shopIds']);
    } else if (map['shopId'] != null) {
      // Migrate old single shopId to list
      shopIdsList = [map['shopId'] as String];
    }

    return UserModel(
      uid: uid,
      role: map['role'] ?? '',
      shopIds: shopIdsList,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      fcmToken: map['fcmToken'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create from Firestore DocumentSnapshot
  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(doc.id, data);
  }

  bool isOwner() => role == 'owner';
  bool isCustomer() => role == 'customer';
}
