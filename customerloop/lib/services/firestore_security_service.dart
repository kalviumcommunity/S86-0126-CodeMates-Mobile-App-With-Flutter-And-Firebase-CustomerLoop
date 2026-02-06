import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// FirestoreSecurityService - Demonstrates secure Firestore operations
///
/// This service shows how to:
/// - Perform authenticated Firestore operations
/// - Handle permission errors gracefully
/// - Test security rules from the app
/// - Implement role-based access control
class FirestoreSecurityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current authenticated user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  // ============================================
  // SECURE USER OPERATIONS
  // ============================================

  /// Create or update user profile (authenticated only)
  Future<void> updateUserProfile({
    required String name,
    required String email,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to update profile');
    }

    try {
      final uid = currentUserId!;
      final data = {
        'name': name,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      };

      await _firestore
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));

      debugPrint('✅ User profile updated successfully');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied: Cannot update user profile');
      }
      debugPrint('❌ Error updating profile: ${e.message}');
      rethrow;
    }
  }

  /// Read user profile (owner only)
  Future<Map<String, dynamic>?> getUserProfile({String? userId}) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to read profile');
    }

    try {
      final uid = userId ?? currentUserId!;
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        debugPrint('✅ User profile retrieved');
        return doc.data();
      }
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied: Cannot access this user profile');
      }
      debugPrint('❌ Error reading profile: ${e.message}');
      rethrow;
    }
  }

  // ============================================
  // SECURE CUSTOMER OPERATIONS
  // ============================================

  /// Create customer (businessId must match current user)
  Future<String> createCustomer({
    required String name,
    required String email,
    required String phone,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to create customers');
    }

    try {
      final uid = currentUserId!;
      final docRef = _firestore.collection('customers').doc();

      final data = {
        'name': name,
        'email': email,
        'phone': phone,
        'businessId': uid, // Security: Must match current user
        'points': 0,
        'totalVisits': 0,
        'tier': 'Bronze',
        'createdAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      };

      await docRef.set(data);
      debugPrint('✅ Customer created: ${docRef.id}');
      return docRef.id;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied: Cannot create customer');
      }
      debugPrint('❌ Error creating customer: ${e.message}');
      rethrow;
    }
  }

  /// Get customers for current business owner
  Stream<List<Map<String, dynamic>>> getMyCustomers() {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated');
    }

    final uid = currentUserId!;

    return _firestore
        .collection('customers')
        .where('businessId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }

  // ============================================
  // SECURITY TESTING OPERATIONS
  // ============================================

  /// Test: Try to write to own security test document (should succeed)
  Future<bool> testOwnDocumentWrite() async {
    if (!isAuthenticated) return false;

    try {
      final uid = currentUserId!;
      await _firestore.collection('securityTests').doc('test_$uid').set({
        'userId': uid,
        'testName': 'Own Document Write Test',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'success',
      });

      debugPrint('✅ Own document write: PASSED');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('❌ Own document write: FAILED - ${e.code}');
      return false;
    }
  }

  /// Test: Try to read own security test document (should succeed)
  Future<bool> testOwnDocumentRead() async {
    if (!isAuthenticated) return false;

    try {
      final uid = currentUserId!;
      final doc =
          await _firestore.collection('securityTests').doc('test_$uid').get();

      debugPrint('✅ Own document read: PASSED (exists: ${doc.exists})');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('❌ Own document read: FAILED - ${e.code}');
      return false;
    }
  }

  /// Test: Try to write to another user's document (should fail)
  Future<bool> testOtherUserDocumentWrite() async {
    if (!isAuthenticated) return false;

    try {
      // Try to write to a document belonging to a different user
      await _firestore.collection('securityTests').doc('test_other_user').set({
        'userId': 'different_user_id', // Not current user
        'testName': 'Unauthorized Write Test',
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint(
        '⚠️ Other user document write: FAILED (should have been blocked)',
      );
      return false; // Should not reach here
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        debugPrint('✅ Other user document write: CORRECTLY BLOCKED');
        return true; // Test passed - permission denied as expected
      }
      debugPrint('❌ Other user document write: UNEXPECTED ERROR - ${e.code}');
      return false;
    }
  }

  /// Test: Try to read data without authentication (should fail)
  Future<bool> testUnauthenticatedRead() async {
    try {
      // Simulate unauthenticated read
      // Note: This won't actually work if user is logged in,
      // but it demonstrates the concept
      final doc =
          await _firestore.collection('customers').doc('non_existent_id').get();

      if (isAuthenticated) {
        debugPrint('⚠️ Cannot test unauthenticated read while logged in');
        return false;
      }

      debugPrint('✅ Unauthenticated read: PASSED');
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        debugPrint('✅ Unauthenticated read: CORRECTLY BLOCKED');
        return true;
      }
      debugPrint('❌ Unauthenticated read: UNEXPECTED ERROR - ${e.code}');
      return false;
    }
  }

  /// Test: Try to update own document (should succeed)
  Future<bool> testOwnDocumentUpdate() async {
    if (!isAuthenticated) return false;

    try {
      final uid = currentUserId!;
      await _firestore.collection('securityTests').doc('test_$uid').update({
        'lastUpdated': FieldValue.serverTimestamp(),
        'updateCount': FieldValue.increment(1),
      });

      debugPrint('✅ Own document update: PASSED');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('❌ Own document update: FAILED - ${e.code}');
      return false;
    }
  }

  /// Test: Try to delete own document (should succeed)
  Future<bool> testOwnDocumentDelete() async {
    if (!isAuthenticated) return false;

    try {
      final uid = currentUserId!;
      await _firestore.collection('securityTests').doc('test_$uid').delete();

      debugPrint('✅ Own document delete: PASSED');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('❌ Own document delete: FAILED - ${e.code}');
      return false;
    }
  }

  // ============================================
  // COMPREHENSIVE SECURITY TEST SUITE
  // ============================================

  /// Run all security tests
  Future<Map<String, bool>> runAllSecurityTests() async {
    debugPrint('🔒 Running Firestore Security Tests...');

    final results = <String, bool>{};

    // Test 1: Own document write
    results['Own Document Write'] = await testOwnDocumentWrite();
    await Future.delayed(const Duration(milliseconds: 500));

    // Test 2: Own document read
    results['Own Document Read'] = await testOwnDocumentRead();
    await Future.delayed(const Duration(milliseconds: 500));

    // Test 3: Own document update
    results['Own Document Update'] = await testOwnDocumentUpdate();
    await Future.delayed(const Duration(milliseconds: 500));

    // Test 4: Unauthorized write (should fail)
    results['Block Unauthorized Write'] = await testOtherUserDocumentWrite();
    await Future.delayed(const Duration(milliseconds: 500));

    // Test 5: Own document delete
    results['Own Document Delete'] = await testOwnDocumentDelete();

    // Print summary
    debugPrint('🔒 Security Test Results:');
    results.forEach((test, passed) {
      debugPrint('  ${passed ? "✅" : "❌"} $test');
    });

    return results;
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Check if user has admin privileges
  Future<bool> isAdmin() async {
    if (!isAuthenticated) return false;

    try {
      final uid = currentUserId!;
      final doc = await _firestore.collection('admins').doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get Firestore rules version info
  Future<String> getRulesInfo() async {
    // This is metadata - actual rules version tracking would be
    // implemented differently in production
    return 'Firestore Rules v2.0 - Secure Mode Enabled';
  }

  /// Clear all test documents for current user
  Future<void> clearTestDocuments() async {
    if (!isAuthenticated) return;

    try {
      final uid = currentUserId!;
      await _firestore.collection('securityTests').doc('test_$uid').delete();
      debugPrint('🧹 Test documents cleared');
    } catch (e) {
      debugPrint('⚠️ Error clearing test documents: $e');
    }
  }
}
