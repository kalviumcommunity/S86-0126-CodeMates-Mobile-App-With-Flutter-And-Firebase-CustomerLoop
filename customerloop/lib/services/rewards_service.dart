import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reward_model.dart';

class RewardsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String rewardsCollection = 'rewards';
  static const String redemptionsCollection = 'redemptions';

  // Get all active rewards for a business
  Stream<List<Reward>> getRewardsStream(String businessId) {
    return _firestore
        .collection(rewardsCollection)
        .where('businessId', isEqualTo: businessId)
        .where('isActive', isEqualTo: true)
        .orderBy('pointsCost')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Reward.fromFirestore(doc)).toList(),
        );
  }

  // ============================================
  // ADVANCED QUERY METHODS (Assignment 3.35)
  // ============================================

  /// Get affordable rewards for customer (points <= maxPoints)
  /// Filters rewards within customer's budget
  Stream<List<Reward>> getAffordableRewards(String businessId, int maxPoints) {
    return _firestore
        .collection(rewardsCollection)
        .where('businessId', isEqualTo: businessId)
        .where('isActive', isEqualTo: true)
        .where('pointsCost', isLessThanOrEqualTo: maxPoints)
        .orderBy('pointsCost')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Reward.fromFirestore(doc)).toList(),
        );
  }

  /// Get premium rewards (high point cost)
  Stream<List<Reward>> getPremiumRewards(String businessId, int minPoints) {
    return _firestore
        .collection(rewardsCollection)
        .where('businessId', isEqualTo: businessId)
        .where('isActive', isEqualTo: true)
        .where('pointsCost', isGreaterThanOrEqualTo: minPoints)
        .orderBy('pointsCost', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Reward.fromFirestore(doc)).toList(),
        );
  }

  /// Get rewards by type (discount, product, etc.)
  Stream<List<Reward>> getRewardsByType(String businessId, String type) {
    return _firestore
        .collection(rewardsCollection)
        .where('businessId', isEqualTo: businessId)
        .where('isActive', isEqualTo: true)
        .where('type', isEqualTo: type)
        .orderBy('pointsCost')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Reward.fromFirestore(doc)).toList(),
        );
  }

  /// Get top N most popular rewards (by redemption count)
  /// Note: This requires a redemptionCount field to be maintained
  Stream<List<Reward>> getPopularRewards(String businessId, {int limit = 5}) {
    return _firestore
        .collection(rewardsCollection)
        .where('businessId', isEqualTo: businessId)
        .where('isActive', isEqualTo: true)
        .orderBy('pointsCost')
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Reward.fromFirestore(doc)).toList(),
        );
  }

  /// Get recent redemptions with limit
  Stream<List<Redemption>> getRecentRedemptions(
    String businessId, {
    int limit = 10,
  }) {
    return _firestore
        .collection(redemptionsCollection)
        .where('businessId', isEqualTo: businessId)
        .orderBy('redeemedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Redemption.fromFirestore(doc))
                  .toList(),
        );
  }

  /// Get high-value redemptions (points >= threshold)
  Stream<List<Redemption>> getHighValueRedemptions(
    String businessId,
    int minPoints,
  ) {
    return _firestore
        .collection(redemptionsCollection)
        .where('businessId', isEqualTo: businessId)
        .where('pointsUsed', isGreaterThanOrEqualTo: minPoints)
        .orderBy('pointsUsed', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Redemption.fromFirestore(doc))
                  .toList(),
        );
  }

  // Add a new reward
  Future<String> addReward(
    String businessId,
    Map<String, dynamic> rewardData,
  ) async {
    try {
      final docRef = await _firestore.collection(rewardsCollection).add({
        ...rewardData,
        'businessId': businessId,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add reward: $e');
    }
  }

  // Initialize default rewards for a business
  Future<void> initializeDefaultRewards(String businessId) async {
    try {
      final snapshot =
          await _firestore
              .collection(rewardsCollection)
              .where('businessId', isEqualTo: businessId)
              .limit(1)
              .get();

      // Only add defaults if no rewards exist
      if (snapshot.docs.isEmpty) {
        final defaultRewards = [
          {
            'name': '10% Instant Discount',
            'description': 'Get 10% off on your next purchase',
            'pointsCost': 50,
            'type': 'discount',
            'discountPercentage': '10',
          },
          {
            'name': '20% Instant Discount',
            'description': 'Get 20% off on your next purchase',
            'pointsCost': 100,
            'type': 'discount',
            'discountPercentage': '20',
          },
          {
            'name': 'Free Product Voucher',
            'description': 'Redeem for any product worth ₹100',
            'pointsCost': 150,
            'type': 'product',
          },
          {
            'name': '30% Instant Discount',
            'description': 'Get 30% off on your next purchase',
            'pointsCost': 200,
            'type': 'discount',
            'discountPercentage': '30',
          },
          {
            'name': 'Premium Product Bundle',
            'description': 'Exclusive bundle worth ₹500',
            'pointsCost': 500,
            'type': 'product',
          },
        ];

        for (var reward in defaultRewards) {
          await addReward(businessId, reward);
        }
      }
    } catch (e) {
      throw Exception('Failed to initialize rewards: $e');
    }
  }

  // Redeem a reward for a customer
  Future<void> redeemReward({
    required String businessId,
    required String customerId,
    required String customerName,
    required Reward reward,
    required int currentPoints,
  }) async {
    try {
      if (currentPoints < reward.pointsCost) {
        throw Exception('Insufficient points');
      }

      // Create redemption record
      await _firestore.collection(redemptionsCollection).add({
        'businessId': businessId,
        'customerId': customerId,
        'customerName': customerName,
        'rewardId': reward.id,
        'rewardName': reward.name,
        'pointsUsed': reward.pointsCost,
        'redeemedAt': FieldValue.serverTimestamp(),
      });

      // Deduct points from customer
      await _firestore.collection('customers').doc(customerId).update({
        'points': FieldValue.increment(-reward.pointsCost),
      });
    } catch (e) {
      throw Exception('Failed to redeem reward: $e');
    }
  }

  // Get redemption history for a customer
  Stream<List<Redemption>> getCustomerRedemptionsStream(String customerId) {
    return _firestore
        .collection(redemptionsCollection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('redeemedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Redemption.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get all redemptions for a business
  Stream<List<Redemption>> getBusinessRedemptionsStream(String businessId) {
    return _firestore
        .collection(redemptionsCollection)
        .where('businessId', isEqualTo: businessId)
        .orderBy('redeemedAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Redemption.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get redemption statistics
  Future<Map<String, dynamic>> getRedemptionStats(String businessId) async {
    try {
      final snapshot =
          await _firestore
              .collection(redemptionsCollection)
              .where('businessId', isEqualTo: businessId)
              .get();

      int totalRedemptions = snapshot.docs.length;
      int totalPointsRedeemed = snapshot.docs.fold(0, (sum, doc) {
        return sum + (doc.data()['pointsUsed'] ?? 0) as int;
      });

      return {
        'totalRedemptions': totalRedemptions,
        'totalPointsRedeemed': totalPointsRedeemed,
      };
    } catch (e) {
      throw Exception('Failed to get redemption stats: $e');
    }
  }

  // Update reward
  Future<void> updateReward(String rewardId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(rewardsCollection).doc(rewardId).update(data);
    } catch (e) {
      throw Exception('Failed to update reward: $e');
    }
  }

  // Delete reward (soft delete by setting isActive to false)
  Future<void> deleteReward(String rewardId) async {
    try {
      await _firestore.collection(rewardsCollection).doc(rewardId).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Failed to delete reward: $e');
    }
  }
}
