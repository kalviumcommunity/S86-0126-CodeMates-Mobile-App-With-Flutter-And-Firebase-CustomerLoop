/// Example Usage Guide for Custom Reusable Widgets
///
/// This file demonstrates how to use all custom widgets in the CustomerLoop app
/// Copy these examples into your screens for quick implementation
library;

import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';
import '../widgets/info_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/like_button.dart';
import '../widgets/toggle_view_button.dart';
import '../widgets/customer_card.dart';
import '../models/customer_model.dart';

class WidgetExamplesScreen extends StatefulWidget {
  const WidgetExamplesScreen({super.key});

  @override
  State<WidgetExamplesScreen> createState() => _WidgetExamplesScreenState();
}

class _WidgetExamplesScreenState extends State<WidgetExamplesScreen> {
  bool _isGridView = false;
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Widget Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION 1: StatCard Examples
            const Text(
              'StatCard Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                StatCard(
                  title: 'Total Customers',
                  value: '42',
                  icon: Icons.people,
                  color: Colors.blue,
                  subtitle: 'Active users',
                ),
                StatCard(
                  title: 'Revenue',
                  value: '\$12.5K',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                StatCard(
                  title: 'Rewards Given',
                  value: '156',
                  icon: Icons.card_giftcard,
                  color: Colors.orange,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('StatCard tapped!')),
                    );
                  },
                ),
                StatCard(
                  title: 'New This Week',
                  value: '8',
                  icon: Icons.trending_up,
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // SECTION 2: InfoCard Examples
            const Text(
              'InfoCard Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            InfoCard(
              title: 'Profile Settings',
              subtitle: 'Update your account information',
              icon: Icons.person,
              iconColor: Colors.blue,
              onTap: () => print('Navigate to profile'),
            ),
            InfoCard(
              title: 'Rewards Catalog',
              subtitle: 'Browse available rewards',
              icon: Icons.card_giftcard,
              iconColor: Colors.orange,
              onTap: () => print('Navigate to rewards'),
            ),
            InfoCard(
              title: 'Analytics Dashboard',
              subtitle: 'View business insights and reports',
              icon: Icons.bar_chart,
              iconColor: Colors.green,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),

            const SizedBox(height: 32),

            // SECTION 3: CustomButton Examples
            const Text(
              'CustomButton Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Solid button with icon
            CustomButton(
              label: 'Add Customer',
              onPressed: () => print('Add customer'),
              icon: Icons.person_add,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),

            // Outlined button
            CustomButton(
              label: 'Cancel',
              onPressed: () => print('Cancel'),
              isOutlined: true,
              color: Colors.red,
            ),
            const SizedBox(height: 12),

            // Button with loading state
            CustomButton(
              label: 'Saving...',
              onPressed: () {},
              isLoading: true,
              color: Colors.green,
            ),
            const SizedBox(height: 12),

            // Full-width button
            CustomButton(
              label: 'Full Width Button',
              onPressed: () => print('Full width'),
              width: double.infinity,
              icon: Icons.check_circle,
              color: Colors.purple,
            ),

            const SizedBox(height: 32),

            // SECTION 4: Stateful Widgets (LikeButton & ToggleViewButton)
            const Text(
              'Stateful Widget Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // LikeButton Example
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Like Button with animation:'),
                        LikeButton(
                          initialLiked: _isLiked,
                          onChanged: (isLiked) {
                            setState(() => _isLiked = isLiked);
                            print('Liked: $isLiked');
                          },
                        ),
                      ],
                    ),
                    const Divider(),

                    // ToggleViewButton Example
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current view: ${_isGridView ? 'Grid' : 'List'}'),
                        ToggleViewButton(
                          initialValue: _isGridView,
                          onChanged: (isGrid) {
                            setState(() => _isGridView = isGrid);
                            print('Grid view: $isGrid');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // SECTION 5: CustomerCard Examples
            const Text(
              'CustomerCard Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Create a sample customer
            Builder(
              builder: (context) {
                final sampleCustomer = Customer(
                  id: 'sample1',
                  name: 'John Doe',
                  phone: '+1 (555) 123-4567',
                  email: 'john.doe@example.com',
                  visits: 5,
                  points: 50,
                  lastVisit: DateTime.now(),
                  createdAt: DateTime.now().subtract(const Duration(days: 30)),
                );

                return Column(
                  children: [
                    // Compact mode (List view)
                    const Text('Compact Mode (List View):'),
                    const SizedBox(height: 8),
                    CustomerCard(
                      customer: sampleCustomer,
                      isCompact: true,
                      onTap: () => print('Customer tapped'),
                      onLike: () => print('Customer liked'),
                    ),

                    const SizedBox(height: 24),

                    // Extended mode (Grid view)
                    const Text('Extended Mode (Grid View):'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 280,
                      child: CustomerCard(
                        customer: sampleCustomer,
                        isCompact: false,
                        onTap: () => print('Customer tapped'),
                        onLike: () => print('Customer liked'),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // SECTION 6: Combined Example
            const Text(
              'Combined Example: All Widgets Together',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Business Dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ToggleViewButton(
                          initialValue: _isGridView,
                          onChanged: (value) {
                            setState(() => _isGridView = value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.5,
                      children: [
                        StatCard(
                          title: 'Total',
                          value: '42',
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                        StatCard(
                          title: 'Active',
                          value: '38',
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: 'View Full Report',
                      onPressed: () => print('View report'),
                      width: double.infinity,
                      icon: Icons.analytics,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// QUICK REFERENCE: Copy-Paste Examples
/// 
/// StatCard:
/// ```dart
/// StatCard(
///   title: 'Total Customers',
///   value: '42',
///   icon: Icons.people,
///   color: Colors.blue,
/// )
/// ```
/// 
/// InfoCard:
/// ```dart
/// InfoCard(
///   title: 'Profile',
///   subtitle: 'View your account',
///   icon: Icons.person,
///   onTap: () => navigate(),
/// )
/// ```
/// 
/// CustomButton:
/// ```dart
/// CustomButton(
///   label: 'Save',
///   onPressed: () => save(),
///   icon: Icons.save,
/// )
/// ```
/// 
/// LikeButton:
/// ```dart
/// LikeButton(
///   onChanged: (liked) => updateLike(liked),
/// )
/// ```
/// 
/// ToggleViewButton:
/// ```dart
/// ToggleViewButton(
///   onChanged: (isGrid) => updateView(isGrid),
/// )
/// ```
/// 
/// CustomerCard:
/// ```dart
/// CustomerCard(
///   customer: customer,
///   isCompact: true,
///   onTap: () => showDetails(),
/// )
/// ```
