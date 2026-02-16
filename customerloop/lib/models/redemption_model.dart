import 'package:cloud_firestore/cloud_firestore.dart';

class RedemptionModel {
  final String id;
  final String customerId;
  final String rewardId; // Added rewardId
  final String rewardTitle;
  final int pointsUsed;
  final DateTime redeemedAt;

  RedemptionModel({
    required this.id,
    required this.customerId,
    required this.rewardId,
    required this.rewardTitle,
    required this.pointsUsed,
    required this.redeemedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'rewardId': rewardId,
      'rewardTitle': rewardTitle,
      'pointsUsed': pointsUsed,
      'redeemedAt': Timestamp.fromDate(redeemedAt),
    };
  }

  // Create from Firestore document
  factory RedemptionModel.fromMap(String id, Map<String, dynamic> map) {
    return RedemptionModel(
      id: id,
      customerId: map['customerId'] ?? '',
      rewardId: map['rewardId'] ?? '',
      rewardTitle: map['rewardTitle'] ?? '',
      pointsUsed: map['pointsUsed'] ?? 0,
      redeemedAt: (map['redeemedAt'] as Timestamp).toDate(),
    );
  }

  // Create from Firestore DocumentSnapshot
  factory RedemptionModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RedemptionModel.fromMap(doc.id, data);
  }
}
