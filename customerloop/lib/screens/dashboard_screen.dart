import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/customer_service.dart';
import '../services/rewards_service.dart';
import '../models/customer_model.dart';
import 'login_screen.dart';
import 'rewards_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _customerService = CustomerService();
  final _rewardsService = RewardsService();
  final _searchController = TextEditingController();

  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? _redemptionStats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
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
        final stats = await _customerService.getStatistics(user.uid);
        final redemptionStats = await _rewardsService.getRedemptionStats(
          user.uid,
        );
        if (mounted) {
          setState(() {
            _statistics = stats;
            _redemptionStats = redemptionStats;
            _isLoadingStats = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingStats = false;
          });
        }
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                      await _customerService.addCustomer(user.uid, {
                        'name': nameController.text.trim(),
                        'phone': phoneController.text.trim(),
                        'email':
                            emailController.text.trim().isEmpty
                                ? null
                                : emailController.text.trim(),
                      });

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
        title: const Text('CustomerLoop Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RewardsScreen()),
              );
            },
            tooltip: 'Rewards Catalog',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search feature coming soon!')),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
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
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _buildStatCard(
                      'Total Customers',
                      '${_statistics?['totalCustomers'] ?? 0}',
                      Icons.people,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Repeat Customers',
                      '${_statistics?['repeatCustomers'] ?? 0}',
                      Icons.repeat,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Rewards Redeemed',
                      '${_redemptionStats?['totalRedemptions'] ?? 0}',
                      Icons.redeem,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Total Visits',
                      '${_statistics?['totalVisits'] ?? 0}',
                      Icons.trending_up,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Avg Visits/Customer',
                      _statistics?['avgVisitsPerCustomer'] ?? '0',
                      Icons.bar_chart,
                      Colors.purple,
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Recent Customers Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Customers',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _showAddCustomerDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Customer'),
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
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    );
                  }

                  final customers = snapshot.data ?? [];

                  if (customers.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No customers yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first customer to start building loyalty!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _showAddCustomerDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Customer'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              customer.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            customer.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${customer.phone} • ${customer.visits} visits • ${customer.points} pts',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (customer.visits > 1)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.green[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Loyal',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () => _showCustomerDetails(customer),
                        ),
                      );
                    },
                  );
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
