import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../screens/notifications_screen.dart';

class NotificationBellWidget extends StatelessWidget {
  final String shopId;
  final String userId;

  const NotificationBellWidget({
    super.key,
    required this.shopId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List>(
      stream: NotificationService().getNotificationsStream(
        shopId: shopId,
        userId: userId,
      ),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        final unreadCount = notifications.where((n) => !n.isRead).length;

        return IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        NotificationsScreen(shopId: shopId, userId: userId),
              ),
            );
          },
        );
      },
    );
  }
}
