import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/rewards_service.dart';
import '../services/customer_service.dart';
import '../models/reward_model.dart';
import '../models/customer_model.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final _authService = AuthService();
  final _rewardsService = RewardsService();
  final _customerService = CustomerService();

  @override
  void initState() {
    super.initState();
    _initializeRewards();
  }

  Future<void> _initializeRewards() async {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        await _rewardsService.initializeDefaultRewards(user.uid);
      } catch (e) {
        // Ignore if rewards already exist
      }
    }
  }

  void _showRedeemDialog(Reward reward) {
    final user = _authService.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  reward.type == 'discount'
                      ? Icons.discount
                      : Icons.card_giftcard,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Select Customer')),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: StreamBuilder<List<Customer>>(
                stream: _customerService.getCustomersStream(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final customers = snapshot.data ?? [];

                  if (customers.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'No customers found. Add customers first.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      final canRedeem = customer.points >= reward.pointsCost;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              canRedeem ? Colors.green : Colors.grey,
                          child: Text(
                            customer.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(customer.name),
                        subtitle: Text(
                          '${customer.points} points ${canRedeem ? '✓' : '(Need ${reward.pointsCost - customer.points} more)'}',
                        ),
                        trailing:
                            canRedeem
                                ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                                : const Icon(Icons.cancel, color: Colors.grey),
                        enabled: canRedeem,
                        onTap:
                            canRedeem
                                ? () async {
                                  Navigator.pop(context);
                                  await _redeemForCustomer(customer, reward);
                                }
                                : null,
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Future<void> _redeemForCustomer(Customer customer, Reward reward) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      await _rewardsService.redeemReward(
        businessId: user.uid,
        customerId: customer.id,
        customerName: customer.name,
        reward: reward,
        currentPoints: customer.points,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ${customer.name} redeemed ${reward.name}!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // Could navigate to redemption history
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to redeem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddRewardDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final pointsController = TextEditingController();
    final discountController = TextEditingController();
    String selectedType = 'product';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add Custom Reward'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Reward Name *',
                            prefixIcon: Icon(Icons.card_giftcard),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description *',
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: pointsController,
                          decoration: const InputDecoration(
                            labelText: 'Points Cost *',
                            prefixIcon: Icon(Icons.stars),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Reward Type',
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'product',
                              child: Text('Product'),
                            ),
                            DropdownMenuItem(
                              value: 'discount',
                              child: Text('Discount'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedType = value!;
                            });
                          },
                        ),
                        if (selectedType == 'discount') ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: discountController,
                            decoration: const InputDecoration(
                              labelText: 'Discount % *',
                              prefixIcon: Icon(Icons.percent),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
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
                            descriptionController.text.isEmpty ||
                            pointsController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all required fields'),
                            ),
                          );
                          return;
                        }

                        try {
                          final user = _authService.currentUser;
                          if (user != null) {
                            await _rewardsService.addReward(user.uid, {
                              'name': nameController.text.trim(),
                              'description': descriptionController.text.trim(),
                              'pointsCost': int.parse(pointsController.text),
                              'type': selectedType,
                              if (selectedType == 'discount')
                                'discountPercentage':
                                    discountController.text.trim(),
                            });

                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reward added successfully!'),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to add reward: $e'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards Catalog'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to redemption history
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RedemptionHistoryScreen(),
                ),
              );
            },
            tooltip: 'Redemption History',
          ),
        ],
      ),
      body: StreamBuilder<List<Reward>>(
        stream:
            user != null ? _rewardsService.getRewardsStream(user.uid) : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rewards = snapshot.data ?? [];

          if (rewards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No rewards available',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add rewards for customers to redeem',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddRewardDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Reward'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.stars, size: 48, color: Colors.blue),
                      const SizedBox(height: 12),
                      Text(
                        'Loyalty Rewards',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Customers can redeem their points for these rewards',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Rewards Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: rewards.length,
                itemBuilder: (context, index) {
                  final reward = rewards[index];
                  return _buildRewardCard(reward);
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRewardDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Reward'),
      ),
    );
  }

  Widget _buildRewardCard(Reward reward) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () => _showRedeemDialog(reward),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color:
                      reward.type == 'discount'
                          ? Colors.orange.shade100
                          : Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  reward.type == 'discount'
                      ? Icons.discount
                      : Icons.card_giftcard,
                  size: 40,
                  color:
                      reward.type == 'discount'
                          ? Colors.orange.shade700
                          : Colors.purple.shade700,
                ),
              ),
              const SizedBox(height: 12),

              // Name
              Text(
                reward.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Description
              Text(
                reward.description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),

              // Points Cost
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${reward.pointsCost} pts',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RedemptionHistoryScreen extends StatelessWidget {
  const RedemptionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final rewardsService = RewardsService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Redemption History'), elevation: 0),
      body: StreamBuilder<List<Redemption>>(
        stream:
            user != null
                ? rewardsService.getBusinessRedemptionsStream(user.uid)
                : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final redemptions = snapshot.data ?? [];

          if (redemptions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No redemptions yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: redemptions.length,
            itemBuilder: (context, index) {
              final redemption = redemptions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                  title: Text(redemption.customerName),
                  subtitle: Text(
                    '${redemption.rewardName}\n${redemption.redeemedAt.day}/${redemption.redeemedAt.month}/${redemption.redeemedAt.year}',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '-${redemption.pointsUsed} pts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
