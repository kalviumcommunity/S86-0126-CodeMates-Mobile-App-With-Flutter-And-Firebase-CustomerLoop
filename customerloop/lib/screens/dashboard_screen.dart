import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/customer_service.dart';
import '../services/rewards_service.dart';
import '../models/customer_model.dart';
import '../widgets/stat_card.dart';
import '../widgets/toggle_view_button.dart';
import '../widgets/customer_card.dart';
import '../widgets/realtime_sync_indicator.dart';
import 'rewards_screen.dart';
import 'customer_insights_screen.dart';
import 'profile_screen.dart';
import 'cloud_functions_demo.dart';
import 'push_notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// StatefulWidget: DashboardScreen maintains state for customer data, statistics, and UI toggles
// Widget Tree Structure:
// DashboardScreen (StatefulWidget)
//   └─ _DashboardScreenState (State)
//      └─ Scaffold
//         ├─ AppBar (with search TextField)
//         ├─ SingleChildScrollView
//         │  └─ Column
//         │     ├─ GridView (Statistics cards)
//         │     ├─ StreamBuilder (Real-time customer list)
//         │     │  └─ ListView.builder OR GridView.builder (Toggle view)
//         └─ FloatingActionButton (Add customer)
class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _customerService = CustomerService();
  final _rewardsService = RewardsService();
  final _searchController = TextEditingController();

  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? _redemptionStats;
  bool _isLoadingStats = true;
  bool _isGridView = false; // Toggle between grid and list view

  @override
  void initState() {
    super.initState();
    // Debug logging: Track dashboard initialization
    debugPrint('🎯 Dashboard Screen initialized');
    debugPrint('📊 Loading customer statistics...');
    _loadStatistics();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        debugPrint('👤 User ID: ${user.uid}');
        final stats = await _customerService.getStatistics(user.uid);

        // Try to get redemption stats, but don't fail if permissions are missing
        Map<String, dynamic>? redemptionStats;
        try {
          redemptionStats = await _rewardsService.getRedemptionStats(user.uid);
        } catch (e) {
          debugPrint(
            '⚠️ Could not load redemption stats (permission denied): $e',
          );
          // Set default values if redemption stats fail
          redemptionStats = {'totalRedemptions': 0};
        }

        debugPrint('✅ Statistics loaded: ${stats.toString()}');
        if (mounted) {
          setState(() {
            _statistics = stats;
            _redemptionStats = redemptionStats;
            _isLoadingStats = false;
          });
        }
      } catch (e) {
        debugPrint('❌ Error loading statistics: $e');
        if (mounted) {
          setState(() {
            _isLoadingStats = false;
          });
        }
      }
    } else {
      debugPrint('⚠️ No user found');
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      // Logout successful - authStateChanges() will handle navigation automatically to LoginScreen
      if (mounted) {
        debugPrint(
          '✅ Logout successful - StreamBuilder will auto-navigate to LoginScreen',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    }
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Customer'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name *',
                      prefixIcon: Icon(Icons.person),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email (Optional)',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      phoneController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Name and phone are required'),
                      ),
                    );
                    return;
                  }

                  try {
                    final user = _authService.currentUser;
                    if (user != null) {
                      debugPrint(
                        '➕ Adding new customer: ${nameController.text}',
                      );
                      await _customerService.addCustomer(user.uid, {
                        'name': nameController.text.trim(),
                        'phone': phoneController.text.trim(),
                        'email':
                            emailController.text.trim().isEmpty
                                ? null
                                : emailController.text.trim(),
                      });
                      debugPrint('✅ Customer added successfully');

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Customer added successfully!'),
                          ),
                        );
                        _loadStatistics();
                      }
                    }
                  } catch (e) {
                    debugPrint('❌ Error adding customer: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add customer: $e')),
                      );
                    }
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _showCustomerDetails(Customer customer) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    customer.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    customer.name,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.phone, 'Phone', customer.phone),
                if (customer.email != null)
                  _buildDetailRow(Icons.email, 'Email', customer.email!),
                _buildDetailRow(
                  Icons.calendar_today,
                  'Member Since',
                  '${customer.createdAt.day}/${customer.createdAt.month}/${customer.createdAt.year}',
                ),
                _buildDetailRow(
                  Icons.repeat,
                  'Total Visits',
                  '${customer.visits}',
                ),
                _buildDetailRow(
                  Icons.stars,
                  'Loyalty Points',
                  '${customer.points}',
                ),
                if (customer.lastVisit != null)
                  _buildDetailRow(
                    Icons.access_time,
                    'Last Visit',
                    '${customer.lastVisit!.day}/${customer.lastVisit!.month}/${customer.lastVisit!.year}',
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _recordVisit(customer);
                },
                icon: const Icon(Icons.add_circle),
                label: const Text('Record Visit'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _recordVisit(Customer customer) async {
    try {
      await _customerService.recordVisit(
        customer.id,
        10,
      ); // 10 points per visit
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Visit recorded! ${customer.name} earned 10 points'),
            backgroundColor: Colors.green,
          ),
        );
        _loadStatistics();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to record visit: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomerLoop'),
        elevation: 1,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard),
            onPressed:
                () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            const RewardsScreen(),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                ),
            tooltip: 'Rewards Catalog',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                ),
            tooltip: 'Profile & Media Upload',
          ),
          IconButton(
            icon: const Icon(Icons.cloud),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CloudFunctionsDemo(),
                  ),
                ),
            tooltip: 'Cloud Functions Demo',
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PushNotificationsScreen(),
                  ),
                ),
            tooltip: 'Push Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search customers, phone or email',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (v) {
                  // Navigate to Customer Insights screen (Assignment 3.35)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomerInsightsScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStatistics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue,
                        child: Text(
                          user?.email?[0].toUpperCase() ?? 'B',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome Back! 👋',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Statistics Cards
              const Text(
                'Business Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (_isLoadingStats)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                AnimatedOpacity(
                  opacity: _isLoadingStats ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 600),
                  child: AnimatedScale(
                    scale: _isLoadingStats ? 0.9 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        // Using custom StatCard widget for consistent statistics display
                        StatCard(
                          title: 'Total Customers',
                          value: '${_statistics?['totalCustomers'] ?? 0}',
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                        StatCard(
                          title: 'Repeat Customers',
                          value: '${_statistics?['repeatCustomers'] ?? 0}',
                          icon: Icons.repeat,
                          color: Colors.green,
                        ),
                        StatCard(
                          title: 'Rewards Redeemed',
                          value:
                              '${_redemptionStats?['totalRedemptions'] ?? 0}',
                          icon: Icons.redeem,
                          color: Colors.orange,
                        ),
                        StatCard(
                          title: 'Total Visits',
                          value: '${_statistics?['totalVisits'] ?? 0}',
                          icon: Icons.trending_up,
                          color: Colors.orange,
                        ),
                        StatCard(
                          title: 'Avg Visits/Customer',
                          value: _statistics?['avgVisitsPerCustomer'] ?? '0',
                          icon: Icons.bar_chart,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Recent Customers Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'Recent Customers',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const RealtimeSyncIndicator(
                          isActive: true,
                          message: 'Live Updates',
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Using custom ToggleViewButton widget
                      ToggleViewButton(
                        initialValue: _isGridView,
                        onChanged: (value) {
                          setState(() {
                            _isGridView = value;
                          });
                        },
                      ),
                      TextButton.icon(
                        onPressed: _showAddCustomerDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Customer'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Customer List
              StreamBuilder<List<Customer>>(
                stream:
                    user != null
                        ? _customerService.getCustomersStream(user.uid)
                        : null,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    // Show demo data when Firebase error occurs
                    final demoCustomers = _getDemoCustomers();
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Firebase Connection Issue',
                                      style: TextStyle(
                                        color: Colors.orange.shade900,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Showing demo data. Try toggling grid/list view!',
                                      style: TextStyle(
                                        color: Colors.orange.shade800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCustomerView(demoCustomers),
                      ],
                    );
                  }

                  final customers = snapshot.data ?? [];

                  // Show demo data if no real customers exist
                  final displayCustomers =
                      customers.isEmpty ? _getDemoCustomers() : customers;

                  if (customers.isEmpty) {
                    // Show banner explaining demo data
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Showing demo data. Add your first customer to see real data!',
                                  style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCustomerView(displayCustomers),
                      ],
                    );
                  }

                  return _buildCustomerView(displayCustomers);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomerDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
      ),
    );
  }

  // Generate demo customers for display when no real data exists
  List<Customer> _getDemoCustomers() {
    return [
      Customer(
        id: 'demo1',
        name: 'Sarah Johnson',
        phone: '+1 (555) 123-4567',
        email: 'sarah.j@example.com',
        visits: 5,
        points: 50,
        lastVisit: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Customer(
        id: 'demo2',
        name: 'Michael Chen',
        phone: '+1 (555) 234-5678',
        email: 'michael.c@example.com',
        visits: 3,
        points: 30,
        lastVisit: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      Customer(
        id: 'demo3',
        name: 'Emily Davis',
        phone: '+1 (555) 345-6789',
        email: 'emily.d@example.com',
        visits: 8,
        points: 80,
        lastVisit: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      Customer(
        id: 'demo4',
        name: 'James Wilson',
        phone: '+1 (555) 456-7890',
        visits: 2,
        points: 20,
        lastVisit: DateTime.now().subtract(const Duration(days: 10)),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Customer(
        id: 'demo5',
        name: 'Lisa Anderson',
        phone: '+1 (555) 567-8901',
        email: 'lisa.a@example.com',
        visits: 12,
        points: 120,
        lastVisit: DateTime.now(),
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      Customer(
        id: 'demo6',
        name: 'David Martinez',
        phone: '+1 (555) 678-9012',
        visits: 4,
        points: 40,
        lastVisit: DateTime.now().subtract(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
      ),
    ];
  }

  // Build customer view based on current view mode using custom CustomerCard widget
  Widget _buildCustomerView(List<Customer> customers) {
    return _isGridView
        ? GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index];
            // Using custom CustomerCard widget in extended (grid) mode
            return CustomerCard(
              customer: customer,
              isCompact: false,
              onTap: () => _showCustomerDetails(customer),
            );
          },
        )
        : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index];
            // Using custom CustomerCard widget in compact (list) mode
            return CustomerCard(
              customer: customer,
              isCompact: true,
              onTap: () => _showCustomerDetails(customer),
            );
          },
        );
  }
}
