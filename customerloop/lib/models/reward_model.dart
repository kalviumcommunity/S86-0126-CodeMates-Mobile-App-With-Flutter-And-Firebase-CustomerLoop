import 'package:cloud_firestore/cloud_firestore.dart';

class RewardModel {
  final String id;
  final String title;
  final String? imageUrl;
  final int pointsRequired;
  final int availableQuantity; // Number of rewards available (-1 = unlimited)

  RewardModel({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.pointsRequired,
    this.availableQuantity = -1, // Default: unlimited
  });

  /// Check if reward is available for redemption
  bool get isAvailable => availableQuantity == -1 || availableQuantity > 0;

  /// Returns the displayable image URL.
  /// If it's an external URL (not Firebase), it wraps it with a CORS proxy (weserv.nl)
  /// to avoid CORS issues on Flutter Web.
  String? get displayImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;

    // If it's a Firebase Storage URL or already a proxy/data URL, return as is
    if (imageUrl!.contains('firebasestorage.googleapis.com') ||
        imageUrl!.startsWith('data:') ||
        imageUrl!.contains('images.weserv.nl')) {
      return imageUrl;
    }

    // Wrap external URL with weserv.nl proxy to bypass CORS
    // It also handles SSL and optimization.
    final encodedUrl = Uri.encodeComponent(imageUrl!);
    return 'https://images.weserv.nl/?url=$encodedUrl';
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'pointsRequired': pointsRequired,
      'availableQuantity': availableQuantity,
    };
  }

  // Create from Firestore document
  factory RewardModel.fromMap(String id, Map<String, dynamic> map) {
    return RewardModel(
      id: id,
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'],
      pointsRequired: map['pointsRequired'] ?? 0,
      availableQuantity: map['availableQuantity'] ?? -1,
    );
  }

  // Create from Firestore DocumentSnapshot
  factory RewardModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RewardModel.fromMap(doc.id, data);
  }

  // Create a copy with updated fields
  RewardModel copyWith({
    String? title,
    String? imageUrl,
    int? pointsRequired,
    int? availableQuantity,
  }) {
    return RewardModel(
      id: id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      availableQuantity: availableQuantity ?? this.availableQuantity,
    );
  }
}
