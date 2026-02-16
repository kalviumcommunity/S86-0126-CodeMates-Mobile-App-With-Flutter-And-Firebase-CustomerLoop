import 'package:flutter/material.dart';

/// Reusable Empty State Widget
/// Assignment 3.47: Handling Errors, Loaders, and Empty States Gracefully
///
/// Displays when there is no data to show
class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customIllustration;

  const EmptyStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.customIllustration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (customIllustration != null)
              customIllustration!
            else
              Icon(
                icon,
                size: 100,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            const SizedBox(height: 24),
            Text(
              title ?? 'Nothing here yet',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message ??
                  'Looks like there\'s no data to display. Get started by adding your first item!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// No Items Empty State
class NoItemsEmptyState extends StatelessWidget {
  final VoidCallback? onAddItem;

  const NoItemsEmptyState({super.key, this.onAddItem});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Items Yet',
      message:
          'You haven\'t created any items yet.\nTap the + button below to add your first item!',
      icon: Icons.inventory_2_outlined,
      actionLabel: onAddItem != null ? 'Create First Item' : null,
      onAction: onAddItem,
    );
  }
}

/// No Customers Empty State
class NoCustomersEmptyState extends StatelessWidget {
  final VoidCallback? onAddCustomer;

  const NoCustomersEmptyState({super.key, this.onAddCustomer});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Customers Found',
      message:
          'You don\'t have any customers yet.\nStart building your customer base by adding your first customer!',
      icon: Icons.people_outline,
      actionLabel: onAddCustomer != null ? 'Add Customer' : null,
      onAction: onAddCustomer,
    );
  }
}

/// No Search Results Empty State
class NoSearchResultsEmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const NoSearchResultsEmptyState({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Results Found',
      message:
          'We couldn\'t find anything matching "$searchQuery".\nTry adjusting your search or clearing filters.',
      icon: Icons.search_off,
      actionLabel: onClearSearch != null ? 'Clear Search' : null,
      onAction: onClearSearch,
    );
  }
}

/// No Notifications Empty State
class NoNotificationsEmptyState extends StatelessWidget {
  const NoNotificationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Notifications',
      message:
          'You\'re all caught up!\nWe\'ll notify you when something important happens.',
      icon: Icons.notifications_none,
    );
  }
}

/// Offline Empty State
class OfflineEmptyState extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineEmptyState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'You\'re Offline',
      message:
          'No internet connection detected.\nConnect to WiFi or mobile data to continue.',
      icon: Icons.cloud_off_outlined,
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }
}

/// No Rewards Empty State
class NoRewardsEmptyState extends StatelessWidget {
  final VoidCallback? onCreateReward;

  const NoRewardsEmptyState({super.key, this.onCreateReward});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Rewards Available',
      message:
          'There are no rewards in the catalog yet.\nCreate rewards to incentivize customer loyalty!',
      icon: Icons.card_giftcard_outlined,
      actionLabel: onCreateReward != null ? 'Create Reward' : null,
      onAction: onCreateReward,
    );
  }
}

/// Coming Soon Empty State
class ComingSoonEmptyState extends StatelessWidget {
  final String featureName;

  const ComingSoonEmptyState({super.key, required this.featureName});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Coming Soon',
      message:
          '$featureName is currently under development.\nStay tuned for updates!',
      icon: Icons.upcoming_outlined,
    );
  }
}

/// Maintenance Empty State
class MaintenanceEmptyState extends StatelessWidget {
  final VoidCallback? onRetry;

  const MaintenanceEmptyState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Under Maintenance',
      message:
          'This feature is temporarily unavailable for maintenance.\nPlease check back soon!',
      icon: Icons.build_outlined,
      actionLabel: onRetry != null ? 'Check Again' : null,
      onAction: onRetry,
    );
  }
}

/// Generic Empty State with Custom Icon
class CustomEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? iconColor;

  const CustomEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: title,
      message: message,
      icon: icon,
      customIllustration:
          iconColor != null ? Icon(icon, size: 100, color: iconColor) : null,
    );
  }
}

/// Empty List with Pull to Refresh hint
class EmptyListWithPullToRefresh extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const EmptyListWithPullToRefresh({
    super.key,
    this.title = 'No Data',
    this.message = 'Pull down to refresh',
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Icon(
            Icons.arrow_downward,
            size: 24,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
