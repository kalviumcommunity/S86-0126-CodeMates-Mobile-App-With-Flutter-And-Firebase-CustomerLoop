import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/customer_model.dart';
import '../models/shop_model.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  UserModel? _userData;
  CustomerModel? _customerData;
  ShopModel? _shopData;
  bool _isLoading = true;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final userData = await _authService.getUserData(user.uid);

      if (userData?.role == 'owner') {
        final shopId = await _authService.getShopId();
        if (shopId != null) {
          final shop = await _firestoreService.getShop(shopId);
          _shopData = shop;
          _shopNameController.text = shop?.name ?? '';
        }
      } else if (userData?.role == 'customer') {
        if (userData?.shopIds.isNotEmpty ?? false) {
          // This part is tricky because we need to find the customer doc in the shop subcollection
          // For now, let's just get the users email and metadata
          // In CustomerDashboard we already have logic to find the customer doc

          final shopId = userData!.shopIds.first;
          final customers =
              await _firestoreService.getCustomersStream(shopId).first;
          try {
            final customer = customers.firstWhere((c) => c.email == user.email);
            _customerData = customer;
            _nameController.text = customer.name;
            _phoneController.text = customer.phone;
          } catch (e) {
            // Document might not exist yet if not linked
          }
        }
      }

      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    try {
      setState(() => _isLoading = true);

      if (_userData?.role == 'owner' && _shopData != null) {
        // Update Shop Name
        await _firestoreService.firestore
            .collection('shops')
            .doc(_shopData!.id)
            .update({'name': _shopNameController.text.trim()});

        // ALSO update Auth Display Name for emails
        await _authService.currentUser?.updateDisplayName(
          _shopNameController.text.trim(),
        );
      } else if (_userData?.role == 'customer' &&
          _customerData != null &&
          (_userData?.shopIds.isNotEmpty ?? false)) {
        // Update Customer Name & Phone in the shop's customer subcollection
        final newName = _nameController.text.trim();
        await _firestoreService.updateCustomer(
          shopId: _userData!.shopIds.first,
          customerId: _customerData!.id,
          name: newName,
          phone: _phoneController.text.trim(),
          email: _customerData!.email,
        );

        // ALSO update Auth Display Name for emails
        await _authService.currentUser?.updateDisplayName(newName);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: LoadingWidget(message: 'Loading profile...'));
    }

    final isOwner = _userData?.role == 'owner';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Header
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                isOwner ? Icons.store_rounded : Icons.person_rounded,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _authService.currentUser?.email ?? '',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isOwner ? 'SHOP OWNER' : 'CUSTOMER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 40),

            if (isOwner) ...[
              CustomTextField(
                controller: _shopNameController,
                label: 'Shop Name',
                prefixIcon: Icons.store_rounded,
              ),
            ] else ...[
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
              ),
            ],

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _updateProfile,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save Changes'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout from Account'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
