import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Background message handler - MUST be a top-level function
/// This runs when app is in background or terminated
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 Background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
}

/// NotificationService - Handles Firebase Cloud Messaging (FCM)
///
/// Features:
/// - Request notification permissions
/// - Handle foreground, background, and terminated state notifications
/// - Display local notifications when app is in foreground
/// - Get FCM device token
/// - Subscribe to topics for targeted messaging
class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Stream controller for notification events
  final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get messageStream => _messageStreamController.stream;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // Notification settings
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // ============================================
  // INITIALIZATION
  // ============================================

  /// Initialize Firebase Cloud Messaging
  /// Call this once in main.dart
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ NotificationService already initialized');
      return;
    }

    try {
      debugPrint('🔔 Initializing NotificationService...');

      // 1. Request notification permissions
      final NotificationSettings settings = await requestPermission();
      debugPrint('✅ Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // 2. Initialize local notifications (for foreground display)
        await _initializeLocalNotifications();

        // 3. Get FCM token
        _fcmToken = await _messaging.getToken();
        debugPrint('✅ FCM Token: $_fcmToken');

        // 4. Setup message handlers
        _setupMessageHandlers();

        // 5. Handle notification that opened the app (if any)
        await _handleInitialMessage();

        _isInitialized = true;
        debugPrint('✅ NotificationService initialized successfully');
      } else {
        debugPrint('❌ Notification permissions denied');
      }
    } catch (e) {
      debugPrint('❌ Failed to initialize NotificationService: $e');
      rethrow;
    }
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    debugPrint('✅ Local notifications initialized');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // You can navigate to specific screen based on payload
  }

  // ============================================
  // PERMISSION MANAGEMENT
  // ============================================

  /// Request notification permissions from user
  Future<NotificationSettings> requestPermission() async {
    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');
    return settings;
  }

  /// Check current notification permission status
  Future<AuthorizationStatus> getPermissionStatus() async {
    final NotificationSettings settings =
        await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  // ============================================
  // MESSAGE HANDLERS
  // ============================================

  /// Setup handlers for different app states
  void _setupMessageHandlers() {
    // 1. FOREGROUND - App is open and in use
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 2. BACKGROUND - App is in background, user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  /// Handle message when app is in FOREGROUND
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📩 Foreground message received');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // Add to stream for listeners
    _messageStreamController.add(message);

    // Show local notification
    await _showLocalNotification(message);
  }

  /// Handle message when app is opened from BACKGROUND
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('📩 Background message opened app');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // Add to stream for listeners
    _messageStreamController.add(message);

    // Handle navigation or action based on message data
    _handleMessageAction(message);
  }

  /// Handle message that opened app from TERMINATED state
  Future<void> _handleInitialMessage() async {
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('📩 App opened from terminated state by notification');
      debugPrint('Title: ${initialMessage.notification?.title}');
      debugPrint('Body: ${initialMessage.notification?.body}');
      debugPrint('Data: ${initialMessage.data}');

      // Add to stream
      _messageStreamController.add(initialMessage);

      // Handle action
      _handleMessageAction(initialMessage);
    }
  }

  /// Handle notification action (navigation, etc.)
  void _handleMessageAction(RemoteMessage message) {
    // Example: Navigate based on notification data
    final String? type = message.data['type'];
    final String? id = message.data['id'];

    debugPrint('🔔 Notification action - Type: $type, ID: $id');

    // You can use Navigator or routing logic here
    // Example:
    // if (type == 'customer') {
    //   Navigator.push(context, CustomerDetailScreen(customerId: id));
    // }
  }

  // ============================================
  // LOCAL NOTIFICATION DISPLAY
  // ============================================

  /// Show local notification (for foreground messages)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel', // channel id
          'High Importance Notifications', // channel name
          channelDescription:
              'This channel is used for important notifications',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode, // notification id
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  // ============================================
  // TOKEN MANAGEMENT
  // ============================================

  /// Get current FCM token
  Future<String?> getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('✅ FCM Token: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      debugPrint('❌ Failed to get FCM token: $e');
      return null;
    }
  }

  /// Listen to token refresh
  void onTokenRefresh(Function(String) callback) {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 FCM Token refreshed: $newToken');
      _fcmToken = newToken;
      callback(newToken);
    });
  }

  // ============================================
  // TOPIC SUBSCRIPTION
  // ============================================

  /// Subscribe to a topic for targeted messaging
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Failed to unsubscribe from topic $topic: $e');
    }
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Send test notification (for debugging)
  /// Note: This requires backend/cloud function to send actual notification
  Future<void> sendTestNotification() async {
    debugPrint('📤 Test notification would be sent from backend');
    debugPrint('Use this token in Firebase Console or your backend:');
    debugPrint(_fcmToken ?? 'No token available');
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
    debugPrint('🧹 All notifications cleared');
  }

  /// Dispose resources
  void dispose() {
    _messageStreamController.close();
  }
}
