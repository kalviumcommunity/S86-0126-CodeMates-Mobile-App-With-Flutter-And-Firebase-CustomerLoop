import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final int visits;
  final int points;
  final DateTime? lastVisit;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.visits,
    required this.points,
    this.lastVisit,
    required this.createdAt,
  });

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Customer(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      visits: data['visits'] ?? 0,
      points: data['points'] ?? 0,
      lastVisit: (data['lastVisit'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'visits': visits,
      'points': points,
      'lastVisit': lastVisit != null ? Timestamp.fromDate(lastVisit!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
