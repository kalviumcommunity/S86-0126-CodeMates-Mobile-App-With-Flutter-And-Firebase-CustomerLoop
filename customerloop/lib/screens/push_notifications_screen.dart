import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';

/// Push Notifications Demo Screen
///
/// Demonstrates Firebase Cloud Messaging (FCM) integration:
/// - Display FCM device token
/// - Show notification permission status
/// - Subscribe/unsubscribe to topics
/// - Display received notifications in real-time
/// - Test notification handling for all app states
class PushNotificationsScreen extends StatefulWidget {
  const PushNotificationsScreen({super.key});

  @override
  State<PushNotificationsScreen> createState() =>
      _PushNotificationsScreenState();
}

class _PushNotificationsScreenState extends State<PushNotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final List<RemoteMessage> _receivedMessages = [];

  String? _fcmToken;
  AuthorizationStatus? _permissionStatus;
  bool _isLoading = true;

  // Topic subscription state
  final Set<String> _subscribedTopics = {};
  final List<String> _availableTopics = [
    'all_users',
    'promotions',
    'rewards',
    'updates',
    'vip_customers',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotificationInfo();
    _listenToMessages();
  }

  /// Load FCM token and permission status
  Future<void> _loadNotificationInfo() async {
    setState(() => _isLoading = true);

    try {
      // Get FCM token
      _fcmToken = await _notificationService.getFCMToken();

      // Get permission status
      _permissionStatus = await _notificationService.getPermissionStatus();

      debugPrint('✅ FCM Token: $_fcmToken');
      debugPrint('✅ Permission: $_permissionStatus');
    } catch (e) {
      debugPrint('❌ Error loading notification info: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    setState(() => _isLoading = false);
  }

  /// Listen to incoming messages
  void _listenToMessages() {
    _notificationService.messageStream.listen((RemoteMessage message) {
      debugPrint('🔔 Message received in UI: ${message.messageId}');

      setState(() {
        _receivedMessages.insert(0, message);
      });

      // Show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.notification?.title ?? 'New Notification',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  /// Copy token to clipboard
  Future<void> _copyTokenToClipboard() async {
    if (_fcmToken != null) {
      await Clipboard.setData(ClipboardData(text: _fcmToken!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Token copied to clipboard'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      final settings = await _notificationService.requestPermission();
      setState(() {
        _permissionStatus = settings.authorizationStatus;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission: ${settings.authorizationStatus}'),
            backgroundColor:
                settings.authorizationStatus == AuthorizationStatus.authorized
                    ? Colors.green
                    : Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
    }
  }

  /// Subscribe to a topic
  Future<void> _subscribeToTopic(String topic) async {
    try {
      await _notificationService.subscribeToTopic(topic);
      setState(() {
        _subscribedTopics.add(topic);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Subscribed to "$topic"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> _unsubscribeFromTopic(String topic) async {
    try {
      await _notificationService.unsubscribeFromTopic(topic);
      setState(() {
        _subscribedTopics.remove(topic);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Unsubscribed from "$topic"'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔔 Push Notifications'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotificationInfo,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Card
                    _buildStatusCard(),
                    const SizedBox(height: 16),

                    // FCM Token Card
                    _buildTokenCard(),
                    const SizedBox(height: 16),

                    // Topic Subscription Card
                    _buildTopicSubscriptionCard(),
                    const SizedBox(height: 16),

                    // Received Messages
                    _buildReceivedMessagesCard(),
                    const SizedBox(height: 16),

                    // Testing Instructions
                    _buildInstructionsCard(),
                  ],
                ),
              ),
    );
  }

  /// Status Card
  Widget _buildStatusCard() {
    final bool isAuthorized =
        _permissionStatus == AuthorizationStatus.authorized ||
        _permissionStatus == AuthorizationStatus.provisional;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Notification Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              'Service Initialized',
              _notificationService.isInitialized,
            ),
            _buildStatusRow('Permission Granted', isAuthorized),
            _buildStatusRow('FCM Token Available', _fcmToken != null),
            const SizedBox(height: 12),
            if (!isAuthorized)
              ElevatedButton.icon(
                onPressed: _requestPermissions,
                icon: const Icon(Icons.notifications_active),
                label: const Text('Request Permissions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  /// FCM Token Card
  Widget _buildTokenCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔑 FCM Device Token',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Use this token to send test notifications from Firebase Console or your backend:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                _fcmToken ?? 'No token available',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _fcmToken != null ? _copyTokenToClipboard : null,
              icon: const Icon(Icons.copy),
              label: const Text('Copy Token'),
            ),
          ],
        ),
      ),
    );
  }

  /// Topic Subscription Card
  Widget _buildTopicSubscriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📢 Topic Subscriptions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Subscribe to topics to receive targeted notifications:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _availableTopics.map((topic) {
                    final isSubscribed = _subscribedTopics.contains(topic);
                    return FilterChip(
                      label: Text(topic),
                      selected: isSubscribed,
                      onSelected: (selected) {
                        if (selected) {
                          _subscribeToTopic(topic);
                        } else {
                          _unsubscribeFromTopic(topic);
                        }
                      },
                      selectedColor: Colors.deepPurple.withOpacity(0.3),
                      checkmarkColor: Colors.deepPurple,
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Received Messages Card
  Widget _buildReceivedMessagesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📬 Received Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_receivedMessages.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _receivedMessages.clear();
                      });
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_receivedMessages.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No notifications received yet.\nSend a test notification to see it here!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _receivedMessages.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final message = _receivedMessages[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      message.notification?.title ?? 'No Title',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.notification?.body != null)
                          Text(message.notification!.body!),
                        if (message.data.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Data: ${message.data}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: Text(
                      TimeOfDay.now().format(context),
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Instructions Card
  Widget _buildInstructionsCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'How to Test Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(
              '1',
              'Copy your FCM token using the button above',
            ),
            _buildInstructionStep(
              '2',
              'Go to Firebase Console → Cloud Messaging',
            ),
            _buildInstructionStep('3', 'Click "Send your first message"'),
            _buildInstructionStep('4', 'Enter notification title and body'),
            _buildInstructionStep(
              '5',
              'Select "Single device" and paste your FCM token',
            ),
            _buildInstructionStep('6', 'Click "Test" to send the notification'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Test all 3 states: Foreground (app open), Background (app minimized), and Terminated (app closed)',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blue,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
