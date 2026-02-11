import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/loading_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/empty_state_widget.dart';

/// States Demo Screen
/// Assignment 3.47: Handling Errors, Loaders, and Empty States Gracefully
///
/// Interactive demo showcasing all loading, error, and empty state widgets
class StatesDemoScreen extends StatefulWidget {
  const StatesDemoScreen({super.key});

  @override
  State<StatesDemoScreen> createState() => _StatesDemoScreenState();
}

class _StatesDemoScreenState extends State<StatesDemoScreen> {
  String _currentDemoState = 'menu';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('States Demo'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
            tooltip: 'About States',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentDemoState) {
      // Loading States
      case 'loading_large':
        return const LoadingStateWidget(
          message: 'Loading data...',
          size: LoadingSize.large,
        );
      case 'loading_medium':
        return const LoadingStateWidget(
          message: 'Processing...',
          size: LoadingSize.medium,
        );
      case 'loading_small':
        return const LoadingStateWidget(
          message: 'Loading',
          size: LoadingSize.small,
        );
      case 'loading_inline':
        return const Center(
          child: InlineLoadingWidget(message: 'Loading inline...'),
        );
      case 'loading_skeleton':
        return _buildSkeletonDemo();
      case 'loading_overlay':
        return LoadingOverlay(
          isLoading: _isLoading,
          message: 'Processing your request...',
          child: _buildSampleContent(),
        );

      // Error States
      case 'error_generic':
        return ErrorStateWidget(onRetry: _simulateRetry);
      case 'error_network':
        return NetworkErrorWidget(onRetry: _simulateRetry);
      case 'error_firebase':
        return FirebaseErrorWidget(
          errorCode: 'permission-denied',
          onRetry: _simulateRetry,
        );
      case 'error_api':
        return ApiErrorWidget(statusCode: 500, onRetry: _simulateRetry);
      case 'error_permission':
        return PermissionErrorWidget(
          permissionName: 'Location',
          onRetry: _simulateRetry,
        );
      case 'error_inline':
        return _buildInlineErrorDemo();

      // Empty States
      case 'empty_items':
        return NoItemsEmptyState(
          onAddItem: () => _showMessage('Add item action'),
        );
      case 'empty_customers':
        return NoCustomersEmptyState(
          onAddCustomer: () => _showMessage('Add customer action'),
        );
      case 'empty_search':
        return NoSearchResultsEmptyState(
          searchQuery: 'Flutter Development',
          onClearSearch: () => _showMessage('Search cleared'),
        );
      case 'empty_notifications':
        return const NoNotificationsEmptyState();
      case 'empty_offline':
        return OfflineEmptyState(onRetry: _simulateRetry);
      case 'empty_rewards':
        return NoRewardsEmptyState(
          onCreateReward: () => _showMessage('Create reward action'),
        );
      case 'empty_coming_soon':
        return const ComingSoonEmptyState(featureName: 'Advanced Analytics');
      case 'empty_maintenance':
        return MaintenanceEmptyState(onRetry: _simulateRetry);

      // Real-world Simulation
      case 'simulation_future':
        return _buildFutureBuilderDemo();
      case 'simulation_stream':
        return _buildStreamBuilderDemo();

      // Main Menu
      default:
        return _buildMenu();
    }
  }

  Widget _buildMenu() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('📊 Loading States', Icons.hourglass_empty),
        _buildMenuCard(
          'Large Loading',
          'Full screen loader with message',
          Icons.hourglass_full,
          () => setState(() => _currentDemoState = 'loading_large'),
        ),
        _buildMenuCard(
          'Medium Loading',
          'Medium-sized loading indicator',
          Icons.hourglass_top,
          () => setState(() => _currentDemoState = 'loading_medium'),
        ),
        _buildMenuCard(
          'Small Loading',
          'Compact loading indicator',
          Icons.hourglass_bottom,
          () => setState(() => _currentDemoState = 'loading_small'),
        ),
        _buildMenuCard(
          'Inline Loading',
          'Horizontal inline loader',
          Icons.more_horiz,
          () => setState(() => _currentDemoState = 'loading_inline'),
        ),
        _buildMenuCard(
          'Skeleton Loading',
          'Shimmer placeholder effect',
          Icons.animation,
          () => setState(() => _currentDemoState = 'loading_skeleton'),
        ),
        _buildMenuCard(
          'Loading Overlay',
          'Full-screen blocking overlay',
          Icons.layers,
          () => setState(() => _currentDemoState = 'loading_overlay'),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('❌ Error States', Icons.error_outline),
        _buildMenuCard(
          'Generic Error',
          'Standard error with retry',
          Icons.error,
          () => setState(() => _currentDemoState = 'error_generic'),
        ),
        _buildMenuCard(
          'Network Error',
          'No internet connection',
          Icons.wifi_off,
          () => setState(() => _currentDemoState = 'error_network'),
        ),
        _buildMenuCard(
          'Firebase Error',
          'Firebase specific errors',
          Icons.cloud_off,
          () => setState(() => _currentDemoState = 'error_firebase'),
        ),
        _buildMenuCard(
          'API Error',
          'HTTP status code errors',
          Icons.api,
          () => setState(() => _currentDemoState = 'error_api'),
        ),
        _buildMenuCard(
          'Permission Error',
          'Missing permissions',
          Icons.lock,
          () => setState(() => _currentDemoState = 'error_permission'),
        ),
        _buildMenuCard(
          'Inline Error',
          'Form validation errors',
          Icons.warning,
          () => setState(() => _currentDemoState = 'error_inline'),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('📭 Empty States', Icons.inbox),
        _buildMenuCard(
          'No Items',
          'Empty items list',
          Icons.inventory_2,
          () => setState(() => _currentDemoState = 'empty_items'),
        ),
        _buildMenuCard(
          'No Customers',
          'Empty customers list',
          Icons.people,
          () => setState(() => _currentDemoState = 'empty_customers'),
        ),
        _buildMenuCard(
          'No Search Results',
          'Search returned nothing',
          Icons.search_off,
          () => setState(() => _currentDemoState = 'empty_search'),
        ),
        _buildMenuCard(
          'No Notifications',
          'All caught up',
          Icons.notifications_none,
          () => setState(() => _currentDemoState = 'empty_notifications'),
        ),
        _buildMenuCard(
          'Offline',
          'No internet connection',
          Icons.cloud_off,
          () => setState(() => _currentDemoState = 'empty_offline'),
        ),
        _buildMenuCard(
          'No Rewards',
          'Empty rewards catalog',
          Icons.card_giftcard,
          () => setState(() => _currentDemoState = 'empty_rewards'),
        ),
        _buildMenuCard(
          'Coming Soon',
          'Feature under development',
          Icons.upcoming,
          () => setState(() => _currentDemoState = 'empty_coming_soon'),
        ),
        _buildMenuCard(
          'Maintenance',
          'System maintenance',
          Icons.build,
          () => setState(() => _currentDemoState = 'empty_maintenance'),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('🎯 Real-World Simulations', Icons.science),
        _buildMenuCard(
          'FutureBuilder Example',
          'Async data loading simulation',
          Icons.sync,
          () => setState(() => _currentDemoState = 'simulation_future'),
        ),
        _buildMenuCard(
          'StreamBuilder Example',
          'Real-time data stream',
          Icons.stream,
          () => setState(() => _currentDemoState = 'simulation_stream'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSkeletonDemo() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SkeletonListItem(),
        SkeletonListItem(),
        SkeletonListItem(),
        SkeletonListItem(),
        SkeletonListItem(),
      ],
    );
  }

  Widget _buildSampleContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Sample Content Behind Overlay',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() => _isLoading = !_isLoading);
            },
            child: Text(_isLoading ? 'Hide Overlay' : 'Show Overlay'),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineErrorDemo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Inline Error Demo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          InlineErrorWidget(
            message: 'Please enter a valid email address',
            onDismiss: () => _showMessage('Error dismissed'),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          InlineErrorWidget(
            message: 'Password must be at least 8 characters',
            onDismiss: () => _showMessage('Error dismissed'),
          ),
        ],
      ),
    );
  }

  Widget _buildFutureBuilderDemo() {
    return FutureBuilder<String>(
      future: _simulateAsyncOperation(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingStateWidget(
            message: 'Fetching data from server...',
            size: LoadingSize.large,
          );
        }

        // Error state
        if (snapshot.hasError) {
          return ErrorStateWidget(
            title: 'Failed to Load Data',
            message: snapshot.error.toString(),
            onRetry: () => setState(() {}), // Rebuild to retry
          );
        }

        // Success state with data
        if (snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 80, color: Colors.green),
                  const SizedBox(height: 24),
                  Text(
                    'Success!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(snapshot.data!, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Reload'),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        return const EmptyStateWidget(
          title: 'No Data',
          message: 'No data was returned from the server.',
        );
      },
    );
  }

  Widget _buildStreamBuilderDemo() {
    return StreamBuilder<int>(
      stream: _simulateStreamData(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingStateWidget(
            message: 'Connecting to stream...',
            size: LoadingSize.large,
          );
        }

        // Error state
        if (snapshot.hasError) {
          return ErrorStateWidget(
            title: 'Stream Error',
            message: snapshot.error.toString(),
            onRetry: () => setState(() {}),
          );
        }

        // No data yet
        if (!snapshot.hasData) {
          return const EmptyStateWidget(
            title: 'Waiting for Data',
            message: 'Stream is active but no data received yet.',
          );
        }

        // Success with live data
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stream, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                'Live Stream Data',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Current Value: ${snapshot.data}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Updates every second',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => _currentDemoState = 'menu'),
                child: const Text('Back to Menu'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _simulateAsyncOperation() async {
    await Future.delayed(const Duration(seconds: 2));
    // Randomly succeed or fail for demo purposes
    if (DateTime.now().second % 3 == 0) {
      throw Exception('Simulated error for demonstration');
    }
    return 'Data loaded successfully! This simulates a successful API call.';
  }

  Stream<int> _simulateStreamData() async* {
    for (int i = 0; i < 60; i++) {
      await Future.delayed(const Duration(seconds: 1));
      yield i;
    }
  }

  void _simulateRetry() {
    setState(() => _currentDemoState = 'menu');
    _showMessage('Retry action triggered - returning to menu');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About States Demo'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'This demo showcases proper handling of UI states:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text('📊 Loading States:'),
                  Text('• Show progress during async operations'),
                  Text('• Prevent UI from appearing frozen'),
                  Text('• Multiple sizes and styles available'),
                  SizedBox(height: 12),
                  Text('❌ Error States:'),
                  Text('• Handle failures gracefully'),
                  Text('• Provide helpful error messages'),
                  Text('• Include retry actions when appropriate'),
                  SizedBox(height: 12),
                  Text('📭 Empty States:'),
                  Text('• Show when no data exists'),
                  Text('• Guide users with clear instructions'),
                  Text('• Provide actions to populate data'),
                  SizedBox(height: 12),
                  Text('🎯 Real-World Examples:'),
                  Text('• FutureBuilder patterns'),
                  Text('• StreamBuilder patterns'),
                  Text('• Production-ready implementations'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it!'),
              ),
            ],
          ),
    );
  }
}
