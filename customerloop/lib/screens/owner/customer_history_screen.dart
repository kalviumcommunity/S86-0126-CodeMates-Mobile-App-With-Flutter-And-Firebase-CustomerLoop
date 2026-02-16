import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../models/customer_model.dart';
import '../../models/visit_model.dart';
import '../../models/redemption_model.dart';
import '../../widgets/loading_widget.dart';
import '../../main.dart';

class CustomerHistoryScreen extends StatefulWidget {
  final String shopId;
  final CustomerModel customer;

  const CustomerHistoryScreen({
    super.key,
    required this.shopId,
    required this.customer,
  });

  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
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
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Visits', icon: Icon(Icons.shopping_bag_outlined)),
            Tab(text: 'Redemptions', icon: Icon(Icons.card_giftcard_outlined)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Customer Summary Header
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    widget.customer.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.customer.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        widget.customer.phone,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${widget.customer.id.toUpperCase()}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${widget.customer.totalPoints}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                      Text(
                        'Points',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVisitsList(),
                _buildRedemptionsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsList() {
    return StreamBuilder<List<VisitModel>>(
      stream: _firestoreService.getCustomerVisitsStream(
        shopId: widget.shopId,
        customerId: widget.customer.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const LoadingWidget();
        }

        final visits = snapshot.data!;
        if (visits.isEmpty) {
          return _buildEmptyState(
            icon: Icons.shopping_bag_outlined,
            message: 'No visits tracked yet',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: visits.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final visit = visits[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Purchase: ₹${visit.purchaseAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(visit.visitDate),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${visit.pointsEarned} pts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRedemptionsList() {
    return StreamBuilder<List<RedemptionModel>>(
      stream: _firestoreService.getCustomerRedemptionsStream(
        shopId: widget.shopId,
        customerId: widget.customer.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const LoadingWidget();
        }

        final redemptions = snapshot.data!;
        if (redemptions.isEmpty) {
          return _buildEmptyState(
            icon: Icons.card_giftcard_outlined,
            message: 'No redemptions yet',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: redemptions.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final redemption = redemptions[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.redeem,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                redemption.rewardTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(redemption.redeemedAt),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${redemption.pointsUsed} pts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
