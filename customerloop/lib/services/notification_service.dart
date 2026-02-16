import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

// Top-level function for background message handling
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize local notifications first
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

      // Request permission for Android 13+ (API 33+)
      final androidImplementation =
          _localNotifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        final bool? granted =
            await androidImplementation.requestNotificationsPermission();
        print('Android notification permission granted: $granted');
      }

      // Request permission for iOS and set up FCM
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional notification permission');
      } else {
        print('User declined or has not accepted notification permission');
      }

      // Create notification channel for Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // Setup message handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Get FCM token
      String? token = await _messaging.getToken();
      print('FCM Token: $token');

      // Save FCM token to user document
      if (token != null) {
        await _saveFcmTokenToUser(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed: $newToken');
        _saveFcmTokenToUser(newToken);
      });

      _initialized = true;
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      _showLocalNotification(
        title: message.notification!.title ?? 'Notification',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle when app is opened from a notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message clicked!');
    print('Message data: ${message.data}');
  }

  /// Handle when a local notification is tapped
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  /// Show a local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
    print('Local notification shown: $title');
  }

  /// Create and save a notification to Firestore
  Future<void> createNotification({
    required String shopId,
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      print(
        'Creating notification: shopId=$shopId, userId=$userId, title=$title',
      );

      final docRef =
          _firestore
              .collection('shops')
              .doc(shopId)
              .collection('notifications')
              .doc();

      final notification = NotificationModel(
        id: docRef.id,
        userId: userId,
        title: title,
        body: body,
        type: type,
        data: data,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await docRef.set(notification.toMap());
      print('Notification created successfully: ${docRef.id}');

      // Show local notification
      await _showLocalNotification(
        title: title,
        body: body,
        payload: notification.id,
      );
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  /// Get notifications stream for a user
  Stream<List<NotificationModel>> getNotificationsStream({
    required String shopId,
    required String userId,
  }) {
    print('Getting notification stream for shopId=$shopId, userId=$userId');
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print('Received ${snapshot.docs.length} notifications');
          final notifications =
              snapshot.docs
                  .map((doc) => NotificationModel.fromSnapshot(doc))
                  .toList();
          // Sort in memory to avoid requiring a composite index
          notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return notifications.take(50).toList();
        });
  }

  /// Mark notification as read
  Future<void> markAsRead({
    required String shopId,
    required String notificationId,
  }) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead({
    required String shopId,
    required String userId,
  }) async {
    try {
      final batch = _firestore.batch();
      final snapshot =
          await _firestore
              .collection('shops')
              .doc(shopId)
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount({
    required String shopId,
    required String userId,
  }) async {
    try {
      final snapshot =
          await _firestore
              .collection('shops')
              .doc(shopId)
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification({
    required String shopId,
    required String notificationId,
  }) async {
    try {
      print(
        'Deleting notification: shopId=$shopId, notificationId=$notificationId',
      );
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
      print('Notification deleted successfully');
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  /// Delete all notifications for a user
  Future<void> deleteAllNotifications({
    required String shopId,
    required String userId,
  }) async {
    try {
      print('Deleting all notifications for userId=$userId');
      final batch = _firestore.batch();
      final snapshot =
          await _firestore
              .collection('shops')
              .doc(shopId)
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('All notifications deleted successfully');
    } catch (e) {
      print('Error deleting all notifications: $e');
      rethrow;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  /// Get FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Save FCM token to user document
  Future<void> _saveFcmTokenToUser(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('FCM token saved to user document: ${user.uid}');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }
}
