import 'package:cloud_firestore/cloud_firestore.dart';

/// Shop settings for configurable loyalty rules
/// Example: Spend ₹1000 → Earn 20 points
class ShopSettingsModel {
  final String shopId;
  final double amountPerPoint; // Amount needed to earn points (e.g., 1000)
  final int pointsPerAmount; // Points earned per amount (e.g., 20)
  final DateTime updatedAt;

  ShopSettingsModel({
    required this.shopId,
    required this.amountPerPoint,
    required this.pointsPerAmount,
    required this.updatedAt,
  });

  /// Calculate points from purchase amount
  /// Example: ₹2500 with rule (₹1000 = 20 points) → 50 points
  int calculatePoints(double purchaseAmount) {
    if (purchaseAmount <= 0 || amountPerPoint <= 0) return 0;
    return ((purchaseAmount / amountPerPoint) * pointsPerAmount).floor();
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'amountPerPoint': amountPerPoint,
      'pointsPerAmount': pointsPerAmount,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore document
  factory ShopSettingsModel.fromMap(String shopId, Map<String, dynamic> map) {
    return ShopSettingsModel(
      shopId: shopId,
      amountPerPoint: (map['amountPerPoint'] ?? 1000.0).toDouble(),
      pointsPerAmount: map['pointsPerAmount'] ?? 20,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create from Firestore DocumentSnapshot
  factory ShopSettingsModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShopSettingsModel.fromMap(doc.id, data);
  }

  // Default settings for new shops
  factory ShopSettingsModel.defaultSettings(String shopId) {
    return ShopSettingsModel(
      shopId: shopId,
      amountPerPoint: 1000.0, // ₹1000
      pointsPerAmount: 20, // 20 points
      updatedAt: DateTime.now(),
    );
  }

  // Create a copy with updated fields
  ShopSettingsModel copyWith({
    double? amountPerPoint,
    int? pointsPerAmount,
  }) {
    return ShopSettingsModel(
      shopId: shopId,
      amountPerPoint: amountPerPoint ?? this.amountPerPoint,
      pointsPerAmount: pointsPerAmount ?? this.pointsPerAmount,
      updatedAt: DateTime.now(),
    );
  }
}
