import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// StorageService - Handles all Firebase Storage operations
/// Manages file uploads, downloads, and deletions for media content
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // ============================================
  // FILE PICKING METHODS
  // ============================================

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  /// Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to capture image from camera: $e');
    }
  }

  /// Pick video from gallery
  Future<XFile?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      return video;
    } catch (e) {
      throw Exception('Failed to pick video: $e');
    }
  }

  // ============================================
  // UPLOAD METHODS
  // ============================================

  /// Upload image to Firebase Storage
  /// Returns the download URL
  Future<String> uploadImage({
    required XFile file,
    required String folder,
    String? fileName,
    Function(double)? onProgress,
  }) async {
    try {
      // Generate unique filename if not provided
      final String uploadFileName =
          fileName ?? DateTime.now().millisecondsSinceEpoch.toString();

      // Create storage reference
      final Reference storageRef = _storage.ref().child(
        '$folder/$uploadFileName.jpg',
      );

      // Read file as bytes (works on all platforms including web)
      final Uint8List bytes = await file.readAsBytes();

      // Create upload task using bytes
      final UploadTask uploadTask = storageRef.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadURL = await snapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload profile picture for user
  Future<String> uploadProfilePicture({
    required XFile file,
    required String userId,
    Function(double)? onProgress,
  }) async {
    return await uploadImage(
      file: file,
      folder: 'profiles',
      fileName: userId,
      onProgress: onProgress,
    );
  }

  /// Upload customer photo
  Future<String> uploadCustomerPhoto({
    required XFile file,
    required String customerId,
    Function(double)? onProgress,
  }) async {
    return await uploadImage(
      file: file,
      folder: 'customers',
      fileName: customerId,
      onProgress: onProgress,
    );
  }

  /// Upload reward image
  Future<String> uploadRewardImage({
    required XFile file,
    required String rewardId,
    Function(double)? onProgress,
  }) async {
    return await uploadImage(
      file: file,
      folder: 'rewards',
      fileName: rewardId,
      onProgress: onProgress,
    );
  }

  /// Upload business logo
  Future<String> uploadBusinessLogo({
    required XFile file,
    required String businessId,
    Function(double)? onProgress,
  }) async {
    return await uploadImage(
      file: file,
      folder: 'logos',
      fileName: businessId,
      onProgress: onProgress,
    );
  }

  // ============================================
  // DOWNLOAD/RETRIEVAL METHODS
  // ============================================

  /// Get download URL for an existing file
  Future<String> getDownloadURL(String filePath) async {
    try {
      final Reference ref = _storage.ref().child(filePath);
      final String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  /// Get file metadata
  Future<FullMetadata> getFileMetadata(String filePath) async {
    try {
      final Reference ref = _storage.ref().child(filePath);
      final FullMetadata metadata = await ref.getMetadata();
      return metadata;
    } catch (e) {
      throw Exception('Failed to get file metadata: $e');
    }
  }

  // ============================================
  // DELETE METHODS
  // ============================================

  /// Delete file from Firebase Storage
  Future<void> deleteFile(String filePath) async {
    try {
      final Reference ref = _storage.ref().child(filePath);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Delete profile picture
  Future<void> deleteProfilePicture(String userId) async {
    await deleteFile('profiles/$userId.jpg');
  }

  /// Delete customer photo
  Future<void> deleteCustomerPhoto(String customerId) async {
    await deleteFile('customers/$customerId.jpg');
  }

  /// Delete reward image
  Future<void> deleteRewardImage(String rewardId) async {
    await deleteFile('rewards/$rewardId.jpg');
  }

  /// Delete business logo
  Future<void> deleteBusinessLogo(String businessId) async {
    await deleteFile('logos/$businessId.jpg');
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Get file size in a human-readable format
  String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      await _storage.ref().child(filePath).getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// List all files in a folder
  Future<List<String>> listFilesInFolder(String folder) async {
    try {
      final ListResult result = await _storage.ref().child(folder).listAll();
      final List<String> urls = [];

      for (var ref in result.items) {
        final String url = await ref.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }
}
