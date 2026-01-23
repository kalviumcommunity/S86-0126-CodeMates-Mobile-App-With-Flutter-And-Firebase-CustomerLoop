import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String customersCollection = 'customers';

  // Add new customer
  Future<String> addCustomer(
    String businessId,
    Map<String, dynamic> customerData,
  ) async {
    try {
      final docRef = await _firestore.collection(customersCollection).add({
        ...customerData,
        'businessId': businessId,
        'visits': 1,
        'points': 10, // Initial welcome points
        'createdAt': FieldValue.serverTimestamp(),
        'lastVisit': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add customer: $e');
    }
  }

  // Get all customers for a business
  Stream<List<Customer>> getCustomersStream(String businessId) {
    return _firestore
        .collection(customersCollection)
        .where('businessId', isEqualTo: businessId)
        .orderBy('lastVisit', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList(),
        );
  }

  // Record customer visit
  Future<void> recordVisit(String customerId, int pointsToAdd) async {
    try {
      final docRef = _firestore.collection(customersCollection).doc(customerId);
      await docRef.update({
        'visits': FieldValue.increment(1),
        'points': FieldValue.increment(pointsToAdd),
        'lastVisit': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to record visit: $e');
    }
  }

  // Redeem points
  Future<void> redeemPoints(String customerId, int pointsToRedeem) async {
    try {
      final docRef = _firestore.collection(customersCollection).doc(customerId);
      final doc = await docRef.get();
      final currentPoints = doc.data()?['points'] ?? 0;

      if (currentPoints >= pointsToRedeem) {
        await docRef.update({'points': FieldValue.increment(-pointsToRedeem)});
      } else {
        throw Exception('Insufficient points');
      }
    } catch (e) {
      throw Exception('Failed to redeem points: $e');
    }
  }

  // Get customer statistics
  Future<Map<String, dynamic>> getStatistics(String businessId) async {
    try {
      final snapshot =
          await _firestore
              .collection(customersCollection)
              .where('businessId', isEqualTo: businessId)
              .get();

      int totalCustomers = snapshot.docs.length;
      int repeatCustomers =
          snapshot.docs.where((doc) {
            final visits = doc.data()['visits'] ?? 0;
            return visits > 1;
          }).length;

      int totalVisits = snapshot.docs.fold(0, (sum, doc) {
        return sum + (doc.data()['visits'] ?? 0) as int;
      });

      int totalPoints = snapshot.docs.fold(0, (sum, doc) {
        return sum + (doc.data()['points'] ?? 0) as int;
      });

      return {
        'totalCustomers': totalCustomers,
        'repeatCustomers': repeatCustomers,
        'totalVisits': totalVisits,
        'totalPoints': totalPoints,
        'avgVisitsPerCustomer':
            totalCustomers > 0
                ? (totalVisits / totalCustomers).toStringAsFixed(1)
                : '0',
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  // Search customer by phone
  Future<Customer?> findCustomerByPhone(String businessId, String phone) async {
    try {
      final snapshot =
          await _firestore
              .collection(customersCollection)
              .where('businessId', isEqualTo: businessId)
              .where('phone', isEqualTo: phone)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return Customer.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to find customer: $e');
    }
  }

  // Update customer details
  Future<void> updateCustomer(
    String customerId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(customersCollection)
          .doc(customerId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  // Delete customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _firestore.collection(customersCollection).doc(customerId).delete();
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }
}
