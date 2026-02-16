import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/customer_model.dart';
import '../../models/visit_model.dart';
import '../../models/redemption_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/notification_bell_widget.dart';
import '../../main.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  List<String> _shopIds = []; // Multiple shops
  String? _currentShopId; // Currently selected shop
  Map<String, String> _shopNames = {}; // shopId -> shopName mapping
  Map<String, String> _customerIds = {}; // shopId -> customerId mapping
  Map<String, CustomerModel> _customerData =
      {}; // shopId -> CustomerModel mapping
  bool _isLoading = true;
  bool _isCardFlipped = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userData = await _authService.getUserData(user.uid);
      if (userData == null) {
        throw Exception('Customer data not found');
      }

      final userEmail = user.email ?? '';

      // Clear existing data
      _shopIds = [];
      _shopNames = {};
      _customerIds = {};
      _customerData = {};

      // Always search all shops for this customer's email
      final allFoundShopIds = await _searchAllShopsForCustomer(userEmail);

      // Load data for all found shops
      for (String shopId in allFoundShopIds) {
        await _loadShopData(shopId, userEmail);
      }

      // Update Firestore if we found new shops
      if (allFoundShopIds.isNotEmpty) {
        final existingShopIds = userData.shopIds;
        if (allFoundShopIds.length != existingShopIds.length ||
            !allFoundShopIds.every((id) => existingShopIds.contains(id))) {
          // Update user document with complete list of shops
          await _firestoreService.firestore
              .collection('users')
              .doc(user.uid)
              .update({'shopIds': allFoundShopIds});

          // Show message if new shops were found
          final newShopsCount = allFoundShopIds.length - existingShopIds.length;
          if (mounted && newShopsCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  newShopsCount == 1
                      ? 'Found 1 new shop!'
                      : 'Found $newShopsCount new shops!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }

      // Set current shop to first one if not already set
      if (_currentShopId == null || !_shopIds.contains(_currentShopId)) {
        _currentShopId = _shopIds.isNotEmpty ? _shopIds.first : null;
      }

      if (mounted) {
        setState(() {
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

  Future<void> _loadShopData(String shopId, String userEmail) async {
    try {
      // Find customer by email
      final customersSnapshot =
          await _firestoreService.getCustomersStream(shopId).first;

      // Try to find customer by matching email
      CustomerModel? customer;

      for (var c in customersSnapshot) {
        if (c.email.toLowerCase() == userEmail.toLowerCase()) {
          customer = c;
          break;
        }
      }

      final shop = await _firestoreService.getShop(shopId);

      if (customer != null && shop != null) {
        _shopIds.add(shopId);
        _shopNames[shopId] = shop.name;
        _customerIds[shopId] = customer.id;
        _customerData[shopId] = customer;
      }
    } catch (e) {
      debugPrint('Error loading shop $shopId: $e');
    }
  }

  Future<List<String>> _searchAllShopsForCustomer(String userEmail) async {
    try {
      final shopsSnapshot =
          await _firestoreService.firestore.collection('shops').get();

      List<String> foundShopIds = [];

      for (var shopDoc in shopsSnapshot.docs) {
        final customersSnapshot =
            await shopDoc.reference
                .collection('customers')
                .where('email', isEqualTo: userEmail)
                .get();

        if (customersSnapshot.docs.isNotEmpty) {
          foundShopIds.add(shopDoc.id);
        }
      }

      return foundShopIds;
    } catch (e) {
      debugPrint('Error searching shops: $e');
      return [];
    }
  }

  Future<void> _searchAndLinkShops(String userEmail) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final shopsSnapshot =
          await _firestoreService.firestore.collection('shops').get();

      List<String> foundShopIds = [];

      for (var shopDoc in shopsSnapshot.docs) {
        final customersSnapshot =
            await shopDoc.reference
                .collection('customers')
                .where('email', isEqualTo: userEmail)
                .get();

        if (customersSnapshot.docs.isNotEmpty) {
          final shopId = shopDoc.id;
          foundShopIds.add(shopId);
          await _loadShopData(shopId, userEmail);
        }
      }

      if (foundShopIds.isNotEmpty) {
        // Auto-link all found shops by updating user document with shopIds array
        await _firestoreService.firestore
            .collection('users')
            .doc(user.uid)
            .update({'shopIds': foundShopIds});

        _currentShopId = foundShopIds.first;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                foundShopIds.length == 1
                    ? 'Account linked successfully!'
                    : 'Linked to ${foundShopIds.length} shops!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error searching shops: $e');
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  void _showShopSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Switch Shop',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              ..._shopIds.map((String shopId) {
                final isSelected = _currentShopId == shopId;
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.store,
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                  ),
                  title: Text(
                    _shopNames[shopId] ?? 'Shop',
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                    ),
                  ),
                  trailing:
                      isSelected
                          ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                          : null,
                  onTap: () {
                    Navigator.pop(context);
                    if (_currentShopId != shopId) {
                      setState(() {
                        _currentShopId = shopId;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Switched to ${_shopNames[shopId]}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLinkAccountDialog() async {
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Link Your Account'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter the phone number you gave to the shop owner:',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context);
                    await _linkAccountByPhone(phoneController.text.trim());
                  }
                },
                child: const Text('Link Account'),
              ),
            ],
          ),
    );
  }

  Future<void> _linkAccountByPhone(String phone) async {
    try {
      setState(() => _isLoading = true);

      final user = _authService.currentUser;
      if (user == null) return;

      final userData = await _authService.getUserData(user.uid);
      if (userData == null) return;

      // Search all shops for a customer with this phone number
      final shopsSnapshot =
          await _firestoreService.firestore.collection('shops').get();

      List<String> foundShopIds = [];

      for (var shopDoc in shopsSnapshot.docs) {
        final customersSnapshot =
            await shopDoc.reference
                .collection('customers')
                .where('phone', isEqualTo: phone)
                .get();

        if (customersSnapshot.docs.isNotEmpty) {
          final shopId = shopDoc.id;
          // Only add if not already linked
          if (!userData.shopIds.contains(shopId)) {
            foundShopIds.add(shopId);
          }
        }
      }

      if (foundShopIds.isNotEmpty) {
        // Add new shops to existing list
        List<String> updatedShopIds = List.from(userData.shopIds);
        updatedShopIds.addAll(foundShopIds);

        // Update user document with updated shopIds array
        await _firestoreService.firestore
            .collection('users')
            .doc(user.uid)
            .update({'shopIds': updatedShopIds});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                foundShopIds.length == 1
                    ? 'Account linked successfully!'
                    : 'Linked to ${foundShopIds.length} new shops!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          await _loadData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No customer found with this phone number. Please ask your shop owner to add you first.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
          setState(() => _isLoading = false);
        }
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

  Widget _buildCardFront(BuildContext context, CustomerModel? customer) {
    return AspectRatio(
      aspectRatio: 1.58,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.35),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
          gradient: LinearGradient(
            colors: [Colors.orange[700]!, Colors.amber[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LOYALTY CARD',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_shopNames[_currentShopId] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _shopNames[_currentShopId]!.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
                Icon(
                  Icons.contactless_outlined,
                  color: Colors.white.withOpacity(0.6),
                  size: 30,
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer?.name.toUpperCase() ?? 'NAME NOT SET',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.phone_android_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        customer?.phone ?? 'NO MOBILE NUMBER',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(BuildContext context, CustomerModel? customer) {
    return AspectRatio(
      aspectRatio: 1.58,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.35),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
          gradient: LinearGradient(
            colors: [Colors.deepOrange[700]!, Colors.orange[600]!],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL REWARD POINTS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BALANCE',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.stars_rounded,
                  color: Colors.white.withOpacity(0.6),
                  size: 30,
                ),
              ],
            ),
            const Spacer(),
            Text(
              '${customer?.totalPoints ?? 0}',
              style: const TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AVAILABLE POINTS',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'ID: ${customer?.id.toUpperCase() ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading your profile...'),
      );
    }

    if (_currentShopId == null || _customerIds[_currentShopId] == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Customer Dashboard'),
          actions: [
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to Customer Loop!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'To start earning loyalty points, ask your shop owner to add you as a customer using your email address.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'How it works:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Visit your favorite shop\n2. Ask them to add you with your email\n3. Log in with that same email\n4. Start earning points automatically!',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _showLinkAccountDialog,
                  icon: const Icon(Icons.link),
                  label: const Text('Link My Account'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            _shopIds.length > 1
                ? InkWell(
                  onTap: _showShopSelector,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _shopNames[_currentShopId] ?? 'My Loyalty',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                )
                : Text(_shopNames[_currentShopId] ?? 'My Loyalty'),
        actions: [
          if (_shopIds.length > 1)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: _showShopSelector,
              tooltip: 'Switch Shop',
            ),
          NotificationBellWidget(
            shopId: _currentShopId!,
            userId: _customerIds[_currentShopId]!,
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
                ),
                onPressed: () {
                  themeNotifier.value =
                      mode == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light;
                },
                tooltip: 'Toggle Theme',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: StreamBuilder<CustomerModel?>(
          stream: _firestoreService.getCustomersStream(_currentShopId!).map((
            customers,
          ) {
            try {
              return customers.firstWhere(
                (c) => c.id == _customerIds[_currentShopId],
              );
            } catch (e) {
              return null;
            }
          }),
          builder: (context, snapshot) {
            final customer = snapshot.data ?? _customerData[_currentShopId];

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Interactive Flipped Points Card
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCardFlipped = !_isCardFlipped;
                      });
                    },
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutBack,
                      tween: Tween<double>(
                        begin: 0,
                        end: _isCardFlipped ? math.pi : 0,
                      ),
                      builder: (context, value, child) {
                        final isHalfway = value > (math.pi / 2);

                        return Transform(
                          transform:
                              Matrix4.identity()
                                ..setEntry(3, 2, 0.001) // Perspective
                                ..rotateY(value),
                          alignment: Alignment.center,
                          child:
                              isHalfway
                                  ? Transform(
                                    transform:
                                        Matrix4.identity()..rotateY(math.pi),
                                    alignment: Alignment.center,
                                    child: _buildCardBack(context, customer),
                                  )
                                  : _buildCardFront(context, customer),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Recent Visits
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Visits',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  StreamBuilder<List<VisitModel>>(
                    stream: _firestoreService.getCustomerVisitsStream(
                      shopId: _currentShopId!,
                      customerId: _customerIds[_currentShopId]!,
                    ),
                    builder: (context, visitSnapshot) {
                      if (visitSnapshot.hasError) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Error loading visits: ${visitSnapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (!visitSnapshot.hasData) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }

                      final visits = visitSnapshot.data!.take(5).toList();

                      if (visits.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 48,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No visits yet',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: visits.length,
                          separatorBuilder:
                              (context, index) =>
                                  const Divider(height: 1, indent: 70),
                          itemBuilder: (context, index) {
                            final visit = visits[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_rounded,
                                  size: 20,
                                  color: Colors.orange,
                                ),
                              ),
                              title: Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(visit.visitDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Spent: ₹${visit.purchaseAmount.toStringAsFixed(0)} • +${visit.pointsEarned} pts • ${DateFormat('hh:mm a').format(visit.visitDate)}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Recent Redemptions
                  Text(
                    'Recent Redemptions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  StreamBuilder<List<RedemptionModel>>(
                    stream: _firestoreService.getCustomerRedemptionsStream(
                      shopId: _currentShopId!,
                      customerId: _customerIds[_currentShopId]!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Error loading redemptions: ${snapshot.error}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }

                      final redemptions = snapshot.data!.take(5).toList();

                      if (redemptions.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.redeem_outlined,
                                    size: 48,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No redemptions yet',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: redemptions.length,
                          separatorBuilder:
                              (context, index) =>
                                  const Divider(height: 1, indent: 70),
                          itemBuilder: (context, index) {
                            final redemption = redemptions[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.card_giftcard_rounded,
                                  size: 20,
                                  color: Colors.green,
                                ),
                              ),
                              title: Text(
                                redemption.rewardTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '-${redemption.pointsUsed} pts • ${DateFormat('MMM dd • hh:mm a').format(redemption.redeemedAt)}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Browse Rewards Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_currentShopId == null ||
                            _customerIds[_currentShopId] == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Account still linking... please wait a moment',
                              ),
                            ),
                          );
                          return;
                        }
                        Navigator.pushNamed(
                          context,
                          '/customer-rewards',
                          arguments: {
                            'shopId': _currentShopId!,
                            'customerId': _customerIds[_currentShopId]!,
                          },
                        );
                      },
                      icon: Icon(
                        Icons.redeem_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      label: Text(
                        'BROWSE REWARDS',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
