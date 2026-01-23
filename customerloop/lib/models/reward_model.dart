import 'package:cloud_firestore/cloud_firestore.dart';

class Reward {
  final String id;
  final String name;
  final String description;
  final int pointsCost;
  final String type; // 'discount' or 'product'
  final String? discountPercentage; // For discount type
  final String? imageUrl;
  final bool isActive;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    required this.type,
    this.discountPercentage,
    this.imageUrl,
    this.isActive = true,
  });

  factory Reward.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reward(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      pointsCost: data['pointsCost'] ?? 0,
      type: data['type'] ?? 'product',
      discountPercentage: data['discountPercentage'],
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'pointsCost': pointsCost,
      'type': type,
      'discountPercentage': discountPercentage,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}

class Redemption {
  final String id;
  final String customerId;
  final String customerName;
  final String rewardId;
  final String rewardName;
  final int pointsUsed;
  final DateTime redeemedAt;
  final String businessId;

  Redemption({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.rewardId,
    required this.rewardName,
    required this.pointsUsed,
    required this.redeemedAt,
    required this.businessId,
  });

  factory Redemption.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Redemption(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      rewardId: data['rewardId'] ?? '',
      rewardName: data['rewardName'] ?? '',
      pointsUsed: data['pointsUsed'] ?? 0,
      redeemedAt: (data['redeemedAt'] as Timestamp).toDate(),
      businessId: data['businessId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'rewardId': rewardId,
      'rewardName': rewardName,
      'pointsUsed': pointsUsed,
      'redeemedAt': Timestamp.fromDate(redeemedAt),
      'businessId': businessId,
    };
  }
}
