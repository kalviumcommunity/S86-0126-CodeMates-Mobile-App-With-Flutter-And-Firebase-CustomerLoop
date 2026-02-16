import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final int totalPoints;
  final int totalVisits;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.totalPoints,
    required this.totalVisits,
    required this.createdAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'totalPoints': totalPoints,
      'totalVisits': totalVisits,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory CustomerModel.fromMap(String id, Map<String, dynamic> map) {
    return CustomerModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      totalPoints: map['totalPoints'] ?? 0,
      totalVisits: map['totalVisits'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create from Firestore DocumentSnapshot
  factory CustomerModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerModel.fromMap(doc.id, data);
  }

  // Create a copy with updated fields
  CustomerModel copyWith({
    String? name,
    String? phone,
    String? email,
    int? totalPoints,
    int? totalVisits,
  }) {
    return CustomerModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      totalPoints: totalPoints ?? this.totalPoints,
      totalVisits: totalVisits ?? this.totalVisits,
      createdAt: createdAt,
    );
  }
}
