import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/visit_model.dart';
import '../../models/customer_model.dart';
import '../../models/redemption_model.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_widget.dart';
import '../../main.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  
  String? _shopId;
  String? _shopName;
  bool _isLoading = true;
  
  int _totalCustomers = 0;
  int _repeatCustomers = 0;
  int _totalRedemptions = 0;
  int _totalVisits = 0;
  double _avgVisits = 0;
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final shopId = await _authService.getShopId();
      if (shopId == null) {
        throw Exception('Shop not found');
      }

      final shop = await _firestoreService.getShop(shopId);
      
      final customers = await _firestoreService.getTotalCustomers(shopId);
      final repeat = await _firestoreService.getRepeatCustomersCount(shopId);
      final redemptions = await _firestoreService.getTotalRedemptionsCount(shopId);
      final visits = await _firestoreService.getTotalVisits(shopId);
      final points = await _firestoreService.getTotalPointsIssued(shopId);

      if (mounted) {
        setState(() {
          _shopId = shopId;
          _shopName = shop?.name ?? 'My Shop';
          _totalCustomers = customers;
          _repeatCustomers = repeat;
          _totalRedemptions = redemptions;
          _totalVisits = visits;
          _avgVisits = customers > 0 ? visits / customers : 0;
          _totalPoints = points;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading dashboard...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_shopName ?? 'Owner Dashboard'),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              return IconButton(
                icon: Icon(mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
                onPressed: () {
                  themeNotifier.value = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                },
                tooltip: 'Toggle Theme',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Text(
                'Business Overview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              
              // Statistics Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  StatCard(
                    title: 'Total Customers',
                    value: _totalCustomers.toString(),
                    icon: Icons.people_rounded,
                    gradientColors: [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
                    iconColor: Colors.white,
                    iconBgColor: Colors.black.withOpacity(0.15),
                  ),
                  StatCard(
                    title: 'Repeat Customers',
                    value: _repeatCustomers.toString(),
                    icon: Icons.repeat_rounded,
                    gradientColors: [const Color(0xFFF57C00), const Color(0xffffa726)],
                    iconColor: Colors.white,
                    iconBgColor: Colors.black.withOpacity(0.15),
                  ),
                  StatCard(
                    title: 'Rewards Redeemed',
                    value: _totalRedemptions.toString(),
                    icon: Icons.card_giftcard_rounded,
                    gradientColors: [const Color(0xFFFFC107), const Color(0xFFFFD54F)],
                    iconColor: Colors.white,
                    iconBgColor: Colors.black.withOpacity(0.15),
                  ),
                  StatCard(
                    title: 'Total Visits',
                    value: _totalVisits.toString(),
                    icon: Icons.trending_up_rounded,
                    gradientColors: [const Color(0xFFFF8F00), const Color(0xFFFFB300)],
                    iconColor: Colors.white,
                    iconBgColor: Colors.black.withOpacity(0.15),
                  ),
                  StatCard(
                    title: 'Avg Visits/Customer',
                    value: _avgVisits.toStringAsFixed(1),
                    icon: Icons.bar_chart_rounded,
                    gradientColors: [const Color(0xFFFFAD33), const Color(0xFFFFCC80)],
                    iconColor: Colors.white,
                    iconBgColor: Colors.black.withOpacity(0.15),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Recent Visits
              Text(
                'Recent Visits',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              
              StreamBuilder<List<VisitModel>>(
                stream: _firestoreService.getAllVisitsStream(_shopId!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final visits = snapshot.data!.take(5).toList();

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
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No visits yet',
                                style: Theme.of(context).textTheme.bodyLarge,
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
                      separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
                      itemBuilder: (context, index) {
                        final visit = visits[index];
                        return FutureBuilder<CustomerModel?>(
                          future: _firestoreService.getCustomer(shopId: _shopId!, customerId: visit.customerId),
                          builder: (context, customerSnapshot) {
                            final customerName = customerSnapshot.data?.name ?? 'Customer';
                            
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                customerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '₹${visit.purchaseAmount.toStringAsFixed(0)} • +${visit.pointsEarned} pts • ${DateFormat('hh:mm a, MMM dd').format(visit.visitDate)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              
              // Recent Redemptions
              Text(
                'Recent Redemptions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              
              StreamBuilder<List<RedemptionModel>>(
                stream: _firestoreService.getRedemptionsStream(_shopId!),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error loading redemptions: ${snapshot.error}',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
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
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No redemptions yet',
                                style: Theme.of(context).textTheme.bodyLarge,
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
                      separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
                      itemBuilder: (context, index) {
                        final redemption = redemptions[index];
                        return FutureBuilder<CustomerModel?>(
                          future: _firestoreService.getCustomer(
                            shopId: _shopId!,
                            customerId: redemption.customerId,
                          ),
                          builder: (context, customerSnapshot) {
                            final customerName = customerSnapshot.data?.name ?? 'Customer';
                            
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                customerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${redemption.rewardTitle} • -${redemption.pointsUsed} pts • ${DateFormat('hh:mm a, MMM dd').format(redemption.redeemedAt)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        title: 'Customers',
                        subtitle: 'Track visits',
                        icon: Icons.people_outline,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/owner-customers',
                            arguments: _shopId,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        title: 'Rewards',
                        subtitle: 'Manage gifts',
                        icon: Icons.card_giftcard,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/owner-rewards',
                            arguments: _shopId,
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
