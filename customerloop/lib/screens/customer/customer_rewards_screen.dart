import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/reward_model.dart';
import '../../models/customer_model.dart';
import '../../widgets/loading_widget.dart';
import '../../main.dart';

class CustomerRewardsScreen extends StatefulWidget {
  final String shopId;
  final String customerId;

  const CustomerRewardsScreen({
    super.key,
    required this.shopId,
    required this.customerId,
  });

  @override
  State<CustomerRewardsScreen> createState() => _CustomerRewardsScreenState();
}

class _CustomerRewardsScreenState extends State<CustomerRewardsScreen> {
  final _firestoreService = FirestoreService();
  bool _isGridView = false;

  void _showRedeemConfirmation(RewardModel reward, int currentPoints) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Reward'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to redeem "${reward.title}"?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Current Points:'),
                      Text(
                        '$currentPoints',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Points Required:'),
                      Text(
                        '-${reward.pointsRequired}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Remaining Points:'),
                      Text(
                        '${currentPoints - reward.pointsRequired}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _firestoreService.redeemReward(
                  shopId: widget.shopId,
                  customerId: widget.customerId,
                  rewardId: reward.id,
                  rewardTitle: reward.title,
                  pointsUsed: reward.pointsRequired,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reward redeemed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
          ),
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
      ),
      body: StreamBuilder<CustomerModel?>(
        stream: _firestoreService.getCustomersStream(widget.shopId).map((customers) {
          try {
            return customers.firstWhere((c) => c.id == widget.customerId);
          } catch (e) {
            return null;
          }
        }),
        builder: (context, customerSnapshot) {
          if (customerSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading profile: ${customerSnapshot.error}'),
                  ],
                ),
              ),
            );
          }
          
          final customer = customerSnapshot.data;
          final currentPoints = customer?.totalPoints ?? 0;

          return Column(
            children: [
              // Points Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Points',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.stars,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$currentPoints',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Rewards List
              Expanded(
                child: StreamBuilder<List<RewardModel>>(
                  stream: _firestoreService.getRewardsStream(widget.shopId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const LoadingWidget();
                    }

                    final rewards = snapshot.data!;

                    if (rewards.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.card_giftcard_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No rewards available',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back later for new rewards',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (_isGridView) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68, // Increased height to prevent overflow
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                        itemCount: rewards.length,
                        itemBuilder: (context, index) {
                          return _buildRewardCard(rewards[index], currentPoints);
                        },
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: rewards.length,
                      itemBuilder: (context, index) {
                        return _buildRewardCard(rewards[index], currentPoints);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRewardCard(RewardModel reward, int currentPoints) {
    final canRedeem = currentPoints >= reward.pointsRequired && reward.isAvailable;
    final isOutOfStock = !reward.isAvailable;

    if (_isGridView) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: (canRedeem
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest)
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: reward.displayImageUrl != null
                      ? Image.network(
                          reward.displayImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image,
                            color: canRedeem
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 32,
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            );
                          },
                        )
                      : Icon(
                          Icons.card_giftcard,
                          color: canRedeem
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  reward.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        height: 1.1,
                      ),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.stars,
                    size: 12,
                    color: canRedeem
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${reward.pointsRequired}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: canRedeem
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (reward.availableQuantity >= 0) ...[
                const SizedBox(height: 2),
                Text(
                  isOutOfStock ? 'Out of stock' : '${reward.availableQuantity} left',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isOutOfStock
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: canRedeem
                      ? () => _showRedeemConfirmation(reward, currentPoints)
                      : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text(
                    isOutOfStock
                        ? 'Stock'
                        : canRedeem
                            ? 'Redeem'
                            : '${reward.pointsRequired - currentPoints} pts',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: (canRedeem
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest)
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: reward.displayImageUrl != null
                        ? Image.network(
                            reward.displayImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              color: canRedeem
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              size: 32,
                            ),
                          )
                        : Icon(
                            Icons.card_giftcard,
                            color: canRedeem
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 32,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.stars,
                            size: 16,
                            color: canRedeem
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${reward.pointsRequired} points',
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: canRedeem
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          if (reward.availableQuantity >= 0) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '• ${reward.availableQuantity} left',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isOutOfStock
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canRedeem
                    ? () => _showRedeemConfirmation(reward, currentPoints)
                    : null,
                icon: const Icon(Icons.redeem),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isOutOfStock
                        ? 'Out of Stock'
                        : canRedeem
                            ? 'Redeem'
                            : 'Need ${reward.pointsRequired - currentPoints} more points',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
