import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/shop_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register new user with role
  Future<UserModel?> register({
    required String email,
    required String password,
    required String role,
    required String name,
    String? shopName,
    String? phone,
  }) async {
    try {
      // Create auth user
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;
      final String uid = user!.uid;
      String? shopId;

      // Update Auth Display Name immediately for emails
      await user.updateDisplayName(name);

      // If owner, create shop
      if (role == 'owner' && shopName != null) {
        final shopDoc = _firestore.collection('shops').doc();
        shopId = shopDoc.id;

        final shop = ShopModel(
          id: shopId,
          ownerId: uid,
          name: shopName,
          createdAt: DateTime.now(),
        );

        await shopDoc.set(shop.toMap());
      }

      // Create user document
      final userModel = UserModel(
        uid: uid,
        role: role,
        shopIds: shopId != null ? [shopId] : [], // Store as list
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(userModel.toMap());

      return userModel;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get user role from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Get current user's role
  Future<String?> getCurrentUserRole() async {
    final user = currentUser;
    if (user == null) return null;

    final userData = await getUserData(user.uid);
    return userData?.role;
  }

  // Check if current user is owner
  Future<bool> isOwner() async {
    final role = await getCurrentUserRole();
    return role == 'owner';
  }

  // Check if current user is customer
  Future<bool> isCustomer() async {
    final role = await getCurrentUserRole();
    return role == 'customer';
  }

  // Get shop ID for current user
  Future<String?> getShopId() async {
    final user = currentUser;
    if (user == null) return null;

    final userData = await getUserData(user.uid);

    // If owner, find their shop
    if (userData?.role == 'owner') {
      final shopQuery =
          await _firestore
              .collection('shops')
              .where('ownerId', isEqualTo: user.uid)
              .limit(1)
              .get();

      if (shopQuery.docs.isNotEmpty) {
        return shopQuery.docs.first.id;
      }
    }

    // If customer, return their first shopId (for backwards compatibility)
    if (userData?.shopIds.isNotEmpty ?? false) {
      return userData!.shopIds.first;
    }

    return null;
  }

  // Forgot Password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }
}
