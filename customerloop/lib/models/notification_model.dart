import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // 'reward_earned', 'reward_redeemed', 'points_added', etc.
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.timestamp,
    this.isRead = false,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  // Create from Firestore document
  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? '',
      data: map['data'] as Map<String, dynamic>?,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
    );
  }

  // Create from Firestore DocumentSnapshot
  factory NotificationModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromMap(doc.id, data);
  }

  // Create a copy with updated fields
  NotificationModel copyWith({
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
