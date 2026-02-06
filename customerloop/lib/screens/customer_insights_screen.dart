import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';
import '../services/auth_service.dart';

/// Advanced Customer Insights Screen
/// Demonstrates Firestore queries with filters, sorting, and limits
/// Assignment 3.35: Structuring Firestore Queries
class CustomerInsightsScreen extends StatefulWidget {
  const CustomerInsightsScreen({super.key});

  @override
  State<CustomerInsightsScreen> createState() => _CustomerInsightsScreenState();
}

class _CustomerInsightsScreenState extends State<CustomerInsightsScreen> {
  final CustomerService _customerService = CustomerService();
  final AuthService _authService = AuthService();

  String _selectedView = 'top_customers';
  int _topLimit = 10;
  int _minPoints = 500;
  final int _daysAgo = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Insights'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Query Filter Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Query Type:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip(
                      'Top Customers',
                      'top_customers',
                      Icons.star,
                    ),
                    _buildFilterChip(
                      'VIP (500+ pts)',
                      'vip_customers',
                      Icons.workspace_premium,
                    ),
                    _buildFilterChip(
                      'Repeat Customers',
                      'repeat_customers',
                      Icons.repeat,
                    ),
                    _buildFilterChip(
                      'Recent (30 days)',
                      'recent_customers',
                      Icons.access_time,
                    ),
                    _buildFilterChip(
                      'Sort by Visits',
                      'sort_by_visits',
                      Icons.sort,
                    ),
                  ],
                ),
                if (_selectedView == 'top_customers') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Show top: '),
                      DropdownButton<int>(
                        value: _topLimit,
                        items:
                            [5, 10, 20, 50]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text('$e'),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() => _topLimit = value!);
                        },
                      ),
                      const Text(' customers'),
                    ],
                  ),
                ],
                if (_selectedView == 'vip_customers') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Min points: '),
                      DropdownButton<int>(
                        value: _minPoints,
                        items:
                            [100, 300, 500, 1000]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text('$e'),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() => _minPoints = value!);
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Results
          Expanded(
            child: StreamBuilder<User?>(
              stream: _authService.authStateChanges,
              builder: (context, authSnapshot) {
                if (!authSnapshot.hasData) {
                  return const Center(child: Text('Please log in'));
                }

                final user = authSnapshot.data!;

                return _buildQueryResults(user.uid);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedView == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedView = value);
      },
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade700,
    );
  }

  Widget _buildQueryResults(String userId) {
    Stream<List<Customer>> stream;

    switch (_selectedView) {
      case 'top_customers':
        stream = _customerService.getTopCustomersByPoints(
          userId,
          limit: _topLimit,
        );
        break;

      case 'vip_customers':
        stream = _customerService.getHighPointCustomers(userId, _minPoints);
        break;

      case 'repeat_customers':
        stream = _customerService.getRepeatCustomers(userId);
        break;

      case 'recent_customers':
        stream = _customerService.getRecentCustomers(userId, daysAgo: _daysAgo);
        break;

      case 'sort_by_visits':
        stream = _customerService.getCustomersSortedBy(
          userId,
          'visits',
          descending: true,
          limit: 20,
        );
        break;

      default:
        stream = _customerService.getCustomersStream(userId);
    }

    return StreamBuilder<List<Customer>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                const Text(
                  'Note: Some queries require Firestore indexes.\nCheck Firebase Console for index creation prompts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final customers = snapshot.data ?? [];

        if (customers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'No customers match this filter',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Query Info
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${customers.length} customers • ${_getQueryDescription()}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            // Customer List
            Expanded(
              child: ListView.builder(
                itemCount: customers.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getAvatarColor(customer.points),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customer.phone),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildBadge(
                                '${customer.points} pts',
                                Colors.purple,
                              ),
                              const SizedBox(width: 8),
                              _buildBadge(
                                '${customer.visits} visits',
                                Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: _getRankBadge(index + 1),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _getQueryDescription() {
    switch (_selectedView) {
      case 'top_customers':
        return 'Sorted by points (DESC) • Limited to $_topLimit';
      case 'vip_customers':
        return 'Points >= $_minPoints • Sorted DESC';
      case 'repeat_customers':
        return 'Visits > 1 • Sorted by visits DESC';
      case 'recent_customers':
        return 'Last $_daysAgo days • Sorted by last visit';
      case 'sort_by_visits':
        return 'Sorted by visits DESC • Top 20';
      default:
        return 'Default query';
    }
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Color.lerp(color, Colors.black, 0.5)!,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _getRankBadge(int rank) {
    if (rank > 3) return const SizedBox.shrink();

    IconData icon;
    Color color;

    switch (rank) {
      case 1:
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case 2:
        icon = Icons.emoji_events;
        color = Colors.grey.shade400;
        break;
      case 3:
        icon = Icons.emoji_events;
        color = Colors.brown.shade300;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Icon(icon, color: color, size: 32);
  }

  Color _getAvatarColor(int points) {
    if (points >= 1000) return Colors.purple.shade700;
    if (points >= 500) return Colors.blue.shade700;
    if (points >= 100) return Colors.green.shade700;
    return Colors.grey.shade600;
  }
}
