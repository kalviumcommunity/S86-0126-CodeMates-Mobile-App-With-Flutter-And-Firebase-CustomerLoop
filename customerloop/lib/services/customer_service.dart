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

  // ============================================
  // ADVANCED QUERY METHODS (Assignment 3.35)
  // ============================================

  /// Get top customers by points (using orderBy + limit)
  /// Example: Top 10 most loyal customers
  Stream<List<Customer>> getTopCustomersByPoints(
    String businessId, {
    int limit = 10,
  }) {
    return _firestore
        .collection(customersCollection)
        .where('businessId', isEqualTo: businessId)
        .orderBy('points', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList(),
        );
  }

  /// Get customers with points greater than threshold (comparison filter)
  /// Example: VIP customers with 500+ points
  Stream<List<Customer>> getHighPointCustomers(
    String businessId,
    int minPoints,
  ) {
    return _firestore
        .collection(customersCollection)
        .where('businessId', isEqualTo: businessId)
        .where('points', isGreaterThanOrEqualTo: minPoints)
        .orderBy('points', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList(),
        );
  }

  /// Get repeat customers (multiple where filters)
  /// Filters: businessId + visits > 1
  Stream<List<Customer>> getRepeatCustomers(String businessId) {
    return _firestore
        .collection(customersCollection)
        .where('businessId', isEqualTo: businessId)
        .where('visits', isGreaterThan: 1)
        .orderBy('visits', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList(),
        );
  }

  /// Get recent customers (last 30 days using timestamp comparison)
  Stream<List<Customer>> getRecentCustomers(
    String businessId, {
    int daysAgo = 30,
  }) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysAgo));

    return _firestore
        .collection(customersCollection)
        .where('businessId', isEqualTo: businessId)
        .where('lastVisit', isGreaterThanOrEqualTo: cutoffDate)
        .orderBy('lastVisit', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList(),
        );
  }

  /// Search customers by name (startsWith pattern)
  /// Note: Firestore doesn't support full-text search, so we use range query
  Stream<List<Customer>> searchCustomersByName(
    String businessId,
    String searchQuery,
  ) {
    final String searchEnd = searchQuery + '\\uf8ff';

    return _firestore
        .collection(customersCollection)
        .where('businessId', isEqualTo: businessId)
        .where('name', isGreaterThanOrEqualTo: searchQuery)
        .where('name', isLessThanOrEqualTo: searchEnd)
        .orderBy('name')
        .limit(20)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList(),
        );
  }

  /// Get customers sorted by different criteria
  Stream<List<Customer>> getCustomersSortedBy(
    String businessId,
    String sortField, {
    bool descending = true,
    int? limit,
  }) {
    var query = _firestore
        .collection(customersCollection)
        .where('businessId', isEqualTo: businessId)
        .orderBy(sortField, descending: descending);

    if (limit != null) {
      query = query.limit(limit) as Query<Map<String, dynamic>>;
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList(),
    );
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
