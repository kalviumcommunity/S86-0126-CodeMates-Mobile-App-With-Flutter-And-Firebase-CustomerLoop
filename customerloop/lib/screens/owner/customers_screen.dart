import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../models/customer_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import '../../models/visit_model.dart';
import '../../main.dart';

class CustomersScreen extends StatefulWidget {
  final String shopId;

  const CustomersScreen({super.key, required this.shopId});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isGridView = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Add Customer'),
                  content: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTextField(
                            controller: nameController,
                            label: 'Customer Name',
                            prefixIcon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter customer name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: emailController,
                            label: 'Email Address',
                            prefixIcon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            isPassword: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: phoneController,
                            label: 'Phone Number',
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                if (!formKey.currentState!.validate()) return;

                                setDialogState(() => isLoading = true);

                                try {
                                  await _firestoreService.addCustomer(
                                    shopId: widget.shopId,
                                    name: nameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    email: emailController.text.trim(),
                                  );

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Customer added successfully',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                      ),
                                    );
                                  }
                                } finally {
                                  setDialogState(() => isLoading = false);
                                }
                              },
                      child:
                          isLoading
                              ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showEditCustomerDialog(CustomerModel customer) {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final emailController = TextEditingController(text: customer.email);
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Edit Customer'),
                  content: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTextField(
                            controller: nameController,
                            label: 'Customer Name',
                            prefixIcon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter customer name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: emailController,
                            label: 'Email Address',
                            prefixIcon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            isPassword: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: phoneController,
                            label: 'Phone Number',
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                if (!formKey.currentState!.validate()) return;

                                setDialogState(() => isLoading = true);

                                try {
                                  await _firestoreService.updateCustomer(
                                    shopId: widget.shopId,
                                    customerId: customer.id,
                                    name: nameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    email: emailController.text.trim(),
                                  );

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Customer updated successfully',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                      ),
                                    );
                                  }
                                } finally {
                                  setDialogState(() => isLoading = false);
                                }
                              },
                      child:
                          isLoading
                              ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Update'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteConfirmation(CustomerModel customer) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Customer'),
            content: Text('Are you sure you want to delete ${customer.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    await _firestoreService.deleteCustomer(
                      shopId: widget.shopId,
                      customerId: customer.id,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Customer deleted successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showTrackVisitDialog(CustomerModel customer) async {
    // Fetch shop settings first
    final settings = await _firestoreService.getShopSettings(widget.shopId);

    if (!mounted) return;

    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    int calculatedPoints = 0;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text('Track Visit - ${customer.name}'),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTextField(
                          controller: amountController,
                          label: 'Purchase Amount (₹)',
                          prefixIcon: Icons.currency_rupee,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter purchase amount';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            final amount = double.tryParse(value);
                            if (amount != null && amount > 0) {
                              setDialogState(() {
                                calculatedPoints = settings.calculatePoints(
                                  amount,
                                );
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Points to Award:',
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$calculatedPoints',
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rule: ₹${settings.amountPerPoint.toStringAsFixed(0)} = ${settings.pointsPerAmount} points',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                if (!formKey.currentState!.validate()) return;

                                setDialogState(() => isLoading = true);

                                try {
                                  final amount = double.parse(
                                    amountController.text,
                                  );
                                  final points = settings.calculatePoints(
                                    amount,
                                  );

                                  await _firestoreService.trackVisit(
                                    shopId: widget.shopId,
                                    customerId: customer.id,
                                    purchaseAmount: amount,
                                    pointsEarned: points,
                                  );

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Visit tracked! $points points awarded',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                      ),
                                    );
                                  }
                                } finally {
                                  setDialogState(() => isLoading = false);
                                }
                              },
                      child:
                          isLoading
                              ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Track Visit'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showCustomerDetailsDialog(CustomerModel customer) {
    showDialog(
      context: context,
      builder:
          (context) => StreamBuilder<List<VisitModel>>(
            stream: _firestoreService.getCustomerVisitsStream(
              shopId: widget.shopId,
              customerId: customer.id,
            ),
            builder: (context, snapshot) {
              final visits = snapshot.data ?? [];
              final lastVisit =
                  visits.isNotEmpty ? visits.first.visitDate : null;
              final totalVisits = visits.length;

              return Dialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              child: Text(
                                customer.name[0].toUpperCase(),
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      customer.id.toUpperCase(),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall?.copyWith(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),

                        // Phone
                        _buildInfoRow(
                          context,
                          icon: Icons.phone,
                          label: 'Phone',
                          value: customer.phone,
                        ),
                        const SizedBox(height: 24),

                        // Email
                        _buildInfoRow(
                          context,
                          icon: Icons.email,
                          label: 'Email',
                          value: customer.email,
                        ),
                        const SizedBox(height: 24),

                        // Member Since
                        _buildInfoRow(
                          context,
                          icon: Icons.calendar_today,
                          label: 'Member Since',
                          value: DateFormat(
                            'dd/MM/yyyy',
                          ).format(customer.createdAt),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                        ),

                        // Total Visits
                        _buildInfoRow(
                          context,
                          icon: Icons.repeat,
                          label: 'Total Visits',
                          value: '$totalVisits',
                        ),
                        const SizedBox(height: 24),

                        // Total Spent
                        _buildInfoRow(
                          context,
                          icon: Icons.currency_rupee,
                          label: 'Total Purchased',
                          value:
                              '₹${visits.fold(0.0, (sum, visit) => sum + visit.purchaseAmount).toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 24),

                        // Loyalty Points
                        _buildInfoRow(
                          context,
                          icon: Icons.stars,
                          label: 'Loyalty Points',
                          value: '${customer.totalPoints}',
                        ),
                        const SizedBox(height: 24),

                        // Last Visit
                        _buildInfoRow(
                          context,
                          icon: Icons.access_time,
                          label: 'Recent Visit Date',
                          value:
                              lastVisit != null
                                  ? DateFormat(
                                    'dd/MM/yyyy • hh:mm a',
                                  ).format(lastVisit)
                                  : 'No visits yet',
                        ),
                        const SizedBox(height: 24),

                        // Recent Visit Amount
                        _buildInfoRow(
                          context,
                          icon: Icons.shopping_bag_outlined,
                          label: 'Recent Visit Amount',
                          value:
                              visits.isNotEmpty
                                  ? '₹${visits.first.purchaseAmount.toStringAsFixed(0)}'
                                  : 'None',
                        ),

                        const SizedBox(height: 40),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    '/owner-customer-history',
                                    arguments: {
                                      'shopId': widget.shopId,
                                      'customer': customer,
                                    },
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  side: BorderSide(color: Colors.blue[100]!),
                                ),
                                child: Text(
                                  'View History',
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showTrackVisitDialog(customer);
                                },
                                icon: const Icon(Icons.add_circle, size: 20),
                                label: const Text('Record Visit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5F7FA),
                                  foregroundColor: const Color(0xFF456990),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    side: const BorderSide(
                                      color: Color(0xFFE0E5EC),
                                    ),
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Close',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Customers'),
        actions: [
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
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip:
                _isGridView ? 'Switch to List View' : 'Switch to Grid View',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCustomerDialog,
            tooltip: 'Add Customer',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Customer List
          Expanded(
            child: StreamBuilder<List<CustomerModel>>(
              stream: _firestoreService.getCustomersStream(widget.shopId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const LoadingWidget();
                }

                var customers = snapshot.data!;

                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  customers =
                      customers.where((customer) {
                        return customer.name.toLowerCase().contains(
                              _searchQuery,
                            ) ||
                            customer.phone.contains(_searchQuery);
                      }).toList();
                }

                if (customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No customers yet'
                              : 'No customers found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Tap + to add your first customer'
                              : 'Try a different search term',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (_isGridView) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      return _buildCustomerCard(customers[index]);
                    },
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    return _buildCustomerCard(customers[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    if (_isGridView) {
      return Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showCustomerDetailsDialog(customer),

          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    customer.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customer.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  customer.phone,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stars,
                          size: 12,
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '${customer.totalPoints}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        onPressed: () => _showTrackVisitDialog(customer),
                        tooltip: 'Track Visit',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => _showEditCustomerDialog(customer),
                        tooltip: 'Edit',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        onPressed: () => _showDeleteConfirmation(customer),
                        tooltip: 'Delete',
                        color: Theme.of(context).colorScheme.error,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showCustomerDetailsDialog(customer),

        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      customer.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          customer.phone,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stars,
                          size: 16,
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${customer.totalPoints}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showTrackVisitDialog(customer),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text('Track Visit'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditCustomerDialog(customer),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteConfirmation(customer),
                    tooltip: 'Delete',
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
