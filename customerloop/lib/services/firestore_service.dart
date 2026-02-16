import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import '../models/customer_model.dart';
import '../models/visit_model.dart';
import '../models/reward_model.dart';
import '../models/redemption_model.dart';
import '../models/shop_model.dart';
import '../models/shop_settings_model.dart';
import 'notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Expose firestore instance for advanced queries
  FirebaseFirestore get firestore => _firestore;

  // ==================== SHOP OPERATIONS ====================

  // Get shop by ID
  Future<ShopModel?> getShop(String shopId) async {
    try {
      final doc = await _firestore.collection('shops').doc(shopId).get();
      if (doc.exists) {
        return ShopModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get shop: ${e.toString()}');
    }
  }

  // ==================== SHOP SETTINGS OPERATIONS ====================

  // Get shop settings
  Future<ShopSettingsModel> getShopSettings(String shopId) async {
    try {
      final doc =
          await _firestore
              .collection('shops')
              .doc(shopId)
              .collection('settings')
              .doc('loyalty')
              .get();

      if (doc.exists) {
        return ShopSettingsModel.fromSnapshot(doc);
      }
      // Return default settings if not found
      return ShopSettingsModel.defaultSettings(shopId);
    } catch (e) {
      // Return default settings on error
      return ShopSettingsModel.defaultSettings(shopId);
    }
  }

  // Update shop settings
  Future<void> updateShopSettings({
    required String shopId,
    required double amountPerPoint,
    required int pointsPerAmount,
  }) async {
    try {
      final settings = ShopSettingsModel(
        shopId: shopId,
        amountPerPoint: amountPerPoint,
        pointsPerAmount: pointsPerAmount,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('settings')
          .doc('loyalty')
          .set(settings.toMap());
    } catch (e) {
      throw Exception('Failed to update shop settings: ${e.toString()}');
    }
  }

  // Get shop settings stream
  Stream<ShopSettingsModel> getShopSettingsStream(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('settings')
        .doc('loyalty')
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return ShopSettingsModel.fromSnapshot(doc);
          }
          return ShopSettingsModel.defaultSettings(shopId);
        });
  }

  // ==================== CUSTOMER OPERATIONS ====================

  // Add customer
  Future<CustomerModel> addCustomer({
    required String shopId,
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      final docRef =
          _firestore
              .collection('shops')
              .doc(shopId)
              .collection('customers')
              .doc();

      final customer = CustomerModel(
        id: docRef.id,
        name: name,
        phone: phone,
        email: email,
        totalPoints: 0,
        totalVisits: 0,
        createdAt: DateTime.now(),
      );

      await docRef.set(customer.toMap());
      return customer;
    } catch (e) {
      throw Exception('Failed to add customer: ${e.toString()}');
    }
  }

  // Update customer
  Future<void> updateCustomer({
    required String shopId,
    required String customerId,
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('customers')
          .doc(customerId)
          .update({'name': name, 'phone': phone, 'email': email});
    } catch (e) {
      throw Exception('Failed to update customer: ${e.toString()}');
    }
  }

  // Delete customer
  Future<void> deleteCustomer({
    required String shopId,
    required String customerId,
  }) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('customers')
          .doc(customerId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete customer: ${e.toString()}');
    }
  }

  // Get all customers stream
  Stream<List<CustomerModel>> getCustomersStream(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('customers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => CustomerModel.fromSnapshot(doc))
                  .toList(),
        );
  }

  // Get single customer
  Future<CustomerModel?> getCustomer({
    required String shopId,
    required String customerId,
  }) async {
    try {
      final doc =
          await _firestore
              .collection('shops')
              .doc(shopId)
              .collection('customers')
              .doc(customerId)
              .get();

      if (doc.exists) {
        return CustomerModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get customer: ${e.toString()}');
    }
  }

  // ==================== VISIT OPERATIONS ====================

  // Track visit and add points
  Future<void> trackVisit({
    required String shopId,
    required String customerId,
    required double purchaseAmount,
    required int pointsEarned,
  }) async {
    try {
      final batch = _firestore.batch();

      // Add visit record
      final visitRef =
          _firestore.collection('shops').doc(shopId).collection('visits').doc();

      final visit = VisitModel(
        id: visitRef.id,
        customerId: customerId,
        purchaseAmount: purchaseAmount,
        pointsEarned: pointsEarned,
        visitDate: DateTime.now(),
      );

      batch.set(visitRef, visit.toMap());

      // Update customer points
      final customerRef = _firestore
          .collection('shops')
          .doc(shopId)
          .collection('customers')
          .doc(customerId);

      batch.update(customerRef, {
        'totalPoints': FieldValue.increment(pointsEarned),
        'totalVisits': FieldValue.increment(1),
      });

      await batch.commit();

      // Send notification to customer
      await NotificationService().createNotification(
        shopId: shopId,
        userId: customerId,
        title: '🎉 Reward Points Earned!',
        body:
            'Congratulations! You earned $pointsEarned points from your purchase of \$${purchaseAmount.toStringAsFixed(2)}.',
        type: 'points_added',
        data: {
          'pointsEarned': pointsEarned,
          'purchaseAmount': purchaseAmount,
          'visitId': visit.id,
        },
      );
    } catch (e) {
      throw Exception('Failed to track visit: ${e.toString()}');
    }
  }

  // Get visits stream for a customer
  Stream<List<VisitModel>> getCustomerVisitsStream({
    required String shopId,
    required String customerId,
  }) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('visits')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
          final visits =
              snapshot.docs.map((doc) => VisitModel.fromSnapshot(doc)).toList();
          // Sort in memory to avoid requiring a composite index
          visits.sort((a, b) => b.visitDate.compareTo(a.visitDate));
          return visits;
        });
  }

  // Get all visits stream
  Stream<List<VisitModel>> getAllVisitsStream(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('visits')
        .orderBy('visitDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => VisitModel.fromSnapshot(doc)).toList(),
        );
  }

  // ==================== REWARD OPERATIONS ====================

  // Add reward
  Future<RewardModel> addReward({
    required String shopId,
    required String title,
    required int pointsRequired,
    String? imageUrl,
    int availableQuantity = -1, // -1 = unlimited
  }) async {
    try {
      final docRef =
          _firestore
              .collection('shops')
              .doc(shopId)
              .collection('rewards')
              .doc();

      final reward = RewardModel(
        id: docRef.id,
        title: title,
        imageUrl: imageUrl,
        pointsRequired: pointsRequired,
        availableQuantity: availableQuantity,
      );

      await docRef.set(reward.toMap());
      return reward;
    } catch (e) {
      throw Exception('Failed to add reward: ${e.toString()}');
    }
  }

  // Update reward
  Future<void> updateReward({
    required String shopId,
    required String rewardId,
    required String title,
    required int pointsRequired,
    String? imageUrl,
    int? availableQuantity,
  }) async {
    try {
      final updateData = {
        'title': title,
        'pointsRequired': pointsRequired,
        'imageUrl': imageUrl,
      };

      if (availableQuantity != null) {
        updateData['availableQuantity'] = availableQuantity;
      }

      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('rewards')
          .doc(rewardId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update reward: ${e.toString()}');
    }
  }

  // Delete reward
  Future<void> deleteReward({
    required String shopId,
    required String rewardId,
  }) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('rewards')
          .doc(rewardId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete reward: ${e.toString()}');
    }
  }

  // Get rewards stream
  Stream<List<RewardModel>> getRewardsStream(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('rewards')
        .snapshots()
        .map((snapshot) {
          final rewards =
              snapshot.docs
                  .map((doc) => RewardModel.fromSnapshot(doc))
                  .toList();
          // Sort in memory to avoid requiring an index
          rewards.sort((a, b) => a.pointsRequired.compareTo(b.pointsRequired));
          return rewards;
        });
  }

  // ==================== REDEMPTION OPERATIONS ====================

  // Redeem reward
  Future<void> redeemReward({
    required String shopId,
    required String customerId,
    required String rewardId,
    required String rewardTitle,
    required int pointsUsed,
  }) async {
    try {
      final batch = _firestore.batch();

      // Add redemption record
      final redemptionRef =
          _firestore
              .collection('shops')
              .doc(shopId)
              .collection('redemptions')
              .doc();

      final redemption = RedemptionModel(
        id: redemptionRef.id,
        customerId: customerId,
        rewardId: rewardId,
        rewardTitle: rewardTitle,
        pointsUsed: pointsUsed,
        redeemedAt: DateTime.now(),
      );

      batch.set(redemptionRef, redemption.toMap());

      // Deduct points from customer
      final customerRef = _firestore
          .collection('shops')
          .doc(shopId)
          .collection('customers')
          .doc(customerId);

      batch.update(customerRef, {
        'totalPoints': FieldValue.increment(-pointsUsed),
      });

      // Decrease reward quantity (if not unlimited)
      final rewardRef = _firestore
          .collection('shops')
          .doc(shopId)
          .collection('rewards')
          .doc(rewardId);

      // Get current reward to check if it has limited quantity
      final rewardDoc = await rewardRef.get();
      if (rewardDoc.exists) {
        final reward = RewardModel.fromSnapshot(rewardDoc);
        if (reward.availableQuantity > 0) {
          // Decrease quantity only if it's not unlimited (-1)
          batch.update(rewardRef, {
            'availableQuantity': FieldValue.increment(-1),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to redeem reward: ${e.toString()}');
    }
  }

  // Get redemptions stream
  Stream<List<RedemptionModel>> getRedemptionsStream(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('redemptions')
        .snapshots()
        .map((snapshot) {
          final redemptions =
              snapshot.docs
                  .map((doc) => RedemptionModel.fromSnapshot(doc))
                  .toList();
          // Sort in-memory to avoid requiring an index
          redemptions.sort((a, b) => b.redeemedAt.compareTo(a.redeemedAt));
          return redemptions;
        });
  }

  // Get customer redemptions stream
  Stream<List<RedemptionModel>> getCustomerRedemptionsStream({
    required String shopId,
    required String customerId,
  }) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('redemptions')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
          final redemptions =
              snapshot.docs
                  .map((doc) => RedemptionModel.fromSnapshot(doc))
                  .toList();
          // Sort in-memory to avoid requiring a composite index
          redemptions.sort((a, b) => b.redeemedAt.compareTo(a.redeemedAt));
          return redemptions;
        });
  }

  // ==================== STATISTICS ====================

  // Get total customers count
  Future<int> getTotalCustomers(String shopId) async {
    final snapshot =
        await _firestore
            .collection('shops')
            .doc(shopId)
            .collection('customers')
            .count()
            .get();
    return snapshot.count ?? 0;
  }

  // Get total visits count
  Future<int> getTotalVisits(String shopId) async {
    final snapshot =
        await _firestore
            .collection('shops')
            .doc(shopId)
            .collection('visits')
            .count()
            .get();
    return snapshot.count ?? 0;
  }

  // Get repeat customers count
  Future<int> getRepeatCustomersCount(String shopId) async {
    final snapshot =
        await _firestore
            .collection('shops')
            .doc(shopId)
            .collection('customers')
            .where('totalVisits', isGreaterThan: 1)
            .count()
            .get();
    return snapshot.count ?? 0;
  }

  // Get total redemptions count
  Future<int> getTotalRedemptionsCount(String shopId) async {
    final snapshot =
        await _firestore
            .collection('shops')
            .doc(shopId)
            .collection('redemptions')
            .count()
            .get();
    return snapshot.count ?? 0;
  }

  // Get total points issued
  Future<int> getTotalPointsIssued(String shopId) async {
    final customers =
        await _firestore
            .collection('shops')
            .doc(shopId)
            .collection('customers')
            .get();

    int totalPoints = 0;
    for (var doc in customers.docs) {
      totalPoints += (doc.data()['totalPoints'] as int? ?? 0);
    }
    return totalPoints;
  }

  // ==================== IMAGE UPLOAD ====================

  Future<String> uploadRewardImage(String shopId, Uint8List imageBytes) async {
    try {
      final fileName = 'reward_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('shops')
          .child(shopId)
          .child('rewards')
          .child(fileName);

      final uploadTask = await storageRef.putData(imageBytes);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }
}
