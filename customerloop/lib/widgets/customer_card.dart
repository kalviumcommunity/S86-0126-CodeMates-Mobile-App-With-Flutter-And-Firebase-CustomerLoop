import 'package:flutter/material.dart';
import '../models/customer_model.dart';

/// CustomerCard - A reusable widget for displaying customer information
///
/// This custom widget displays customer details in a consistent card format
/// Features:
/// - Two display modes: Compact (list) and Extended (grid)
/// - Shows customer name, points, phone, loyalty tier
/// - Tap action support
/// - Like/favorite button integration
/// Benefits:
/// - Consistent customer display across dashboard and reports
/// - Easy to maintain and update
/// - Supports different view modes
class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool isLiked;
  final bool isCompact;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    this.onLike,
    this.isLiked = false,
    this.isCompact = true,
  });

  Color _getTierColor() {
    // Calculate tier based on points
    final tier = _calculateTier();
    switch (tier.toLowerCase()) {
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey;
      case 'bronze':
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  String _calculateTier() {
    // Calculate loyalty tier based on points
    if (customer.points >= 100) return 'Gold';
    if (customer.points >= 50) return 'Silver';
    if (customer.points >= 20) return 'Bronze';
    return 'Member';
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactCard(context);
    } else {
      return _buildExtendedCard(context);
    }
  }

  /// Compact card for list view
  Widget _buildCompactCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: _getTierColor().withOpacity(0.2),
          child: Text(
            customer.name[0].toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getTierColor(),
            ),
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  customer.phone,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.stars, size: 14, color: _getTierColor()),
                const SizedBox(width: 4),
                Text(
                  '${customer.points} pts • ${_calculateTier()}',
                  style: TextStyle(
                    fontSize: 13,
                    color: _getTierColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing:
            onLike != null
                ? IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: onLike,
                )
                : const Icon(Icons.chevron_right),
      ),
    );
  }

  /// Extended card for grid view
  Widget _buildExtendedCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar and like button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _getTierColor().withOpacity(0.2),
                    child: Text(
                      customer.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getTierColor(),
                      ),
                    ),
                  ),
                  if (onLike != null)
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: onLike,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Customer Name
              Text(
                customer.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Phone
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      customer.phone,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Email (if available)
              if (customer.email != null && customer.email!.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.email, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        customer.email!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const Spacer(),

              // Points and Tier Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getTierColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getTierColor(), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars, size: 18, color: _getTierColor()),
                    const SizedBox(width: 6),
                    Text(
                      '${customer.points} pts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getTierColor(),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '• ${_calculateTier()}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _getTierColor(),
                        fontSize: 12,
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
