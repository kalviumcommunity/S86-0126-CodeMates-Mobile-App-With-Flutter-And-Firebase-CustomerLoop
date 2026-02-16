import 'package:cloud_firestore/cloud_firestore.dart';

class VisitModel {
  final String id;
  final String customerId;
  final double purchaseAmount; // Purchase amount in currency
  final int pointsEarned;
  final DateTime visitDate;

  VisitModel({
    required this.id,
    required this.customerId,
    required this.purchaseAmount,
    required this.pointsEarned,
    required this.visitDate,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'purchaseAmount': purchaseAmount,
      'pointsEarned': pointsEarned,
      'visitDate': Timestamp.fromDate(visitDate),
    };
  }

  // Create from Firestore document
  factory VisitModel.fromMap(String id, Map<String, dynamic> map) {
    return VisitModel(
      id: id,
      customerId: map['customerId'] ?? '',
      purchaseAmount: (map['purchaseAmount'] ?? 0.0).toDouble(),
      pointsEarned: map['pointsEarned'] ?? 0,
      visitDate: (map['visitDate'] as Timestamp).toDate(),
    );
  }

  // Create from Firestore DocumentSnapshot
  factory VisitModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VisitModel.fromMap(doc.id, data);
  }
}
