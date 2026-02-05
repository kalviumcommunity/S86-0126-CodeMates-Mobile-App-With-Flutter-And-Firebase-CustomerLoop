import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Profile & Media Upload Screen
/// Demonstrates Firebase Storage integration for file uploads
/// Assignment 3.36: Uploading and Managing Media Files
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  String? _profileImageUrl;
  String? _businessLogoUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  @override
  void initState() {
    super.initState();
    _loadUserImages();
  }

  Future<void> _loadUserImages() async {
    final user = _authService.currentUser;
    if (user != null) {
      // Check if profile picture exists
      final profileExists = await _storageService.fileExists(
        'profiles/${user.uid}.jpg',
      );
      if (profileExists) {
        _profileImageUrl = await _storageService.getDownloadURL(
          'profiles/${user.uid}.jpg',
        );
      }

      // Check if business logo exists
      final logoExists = await _storageService.fileExists(
        'logos/${user.uid}.jpg',
      );
      if (logoExists) {
        _businessLogoUrl = await _storageService.getDownloadURL(
          'logos/${user.uid}.jpg',
        );
      }

      setState(() {});
    }
  }

  Future<void> _uploadProfilePicture(ImageSource source) async {
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _uploadStatus = 'Selecting image...';
      });

      // Pick image
      XFile? image;
      if (source == ImageSource.gallery) {
        image = await _storageService.pickImageFromGallery();
      } else {
        image = await _storageService.pickImageFromCamera();
      }

      if (image == null) {
        setState(() {
          _isUploading = false;
          _uploadStatus = 'No image selected';
        });
        return;
      }

      setState(() => _uploadStatus = 'Uploading image...');

      final user = _authService.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Upload to Firebase Storage
      final String downloadURL = await _storageService.uploadProfilePicture(
        file: image,
        userId: user.uid,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
            _uploadStatus =
                'Uploading: ${(progress * 100).toStringAsFixed(0)}%';
          });
        },
      );

      setState(() {
        _profileImageUrl = downloadURL;
        _isUploading = false;
        _uploadStatus = 'Upload complete!';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile picture uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadStatus = 'Upload failed: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Upload failed: $e')));
      }
    }
  }

  Future<void> _uploadBusinessLogo() async {
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _uploadStatus = 'Selecting logo...';
      });

      final image = await _storageService.pickImageFromGallery();
      if (image == null) {
        setState(() {
          _isUploading = false;
          _uploadStatus = 'No image selected';
        });
        return;
      }

      setState(() => _uploadStatus = 'Uploading logo...');

      final user = _authService.currentUser;
      if (user == null) throw Exception('User not logged in');

      final String downloadURL = await _storageService.uploadBusinessLogo(
        file: image,
        businessId: user.uid,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
            _uploadStatus =
                'Uploading: ${(progress * 100).toStringAsFixed(0)}%';
          });
        },
      );

      setState(() {
        _businessLogoUrl = downloadURL;
        _isUploading = false;
        _uploadStatus = 'Upload complete!';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Business logo uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadStatus = 'Upload failed: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Upload failed: $e')));
      }
    }
  }

  Future<void> _deleteProfilePicture() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      await _storageService.deleteProfilePicture(user.uid);

      setState(() {
        _profileImageUrl = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile picture deleted'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  Future<void> _deleteBusinessLogo() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      await _storageService.deleteBusinessLogo(user.uid);

      setState(() {
        _businessLogoUrl = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Business logo deleted'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choose Image Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Colors.purple,
                  ),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _uploadProfilePicture(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _uploadProfilePicture(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Media Upload'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Firebase Storage Demo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Upload images to Firebase Storage and display them in real-time. '
                      'Files are securely stored and accessible via download URLs.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Profile Picture Section
            _buildImageSection(
              title: '👤 Profile Picture',
              description: 'Upload your profile photo',
              imageUrl: _profileImageUrl,
              onUpload: _showImageSourceDialog,
              onDelete: _profileImageUrl != null ? _deleteProfilePicture : null,
              icon: Icons.person,
            ),

            const SizedBox(height: 24),

            // Business Logo Section
            _buildImageSection(
              title: '🏢 Business Logo',
              description: 'Upload your company logo',
              imageUrl: _businessLogoUrl,
              onUpload: _uploadBusinessLogo,
              onDelete: _businessLogoUrl != null ? _deleteBusinessLogo : null,
              icon: Icons.business,
            ),

            // Upload Progress Indicator
            if (_isUploading) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _uploadStatus,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: _uploadProgress,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Storage Info Card
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_done, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Storage Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('User ID', user?.uid ?? 'Not logged in'),
                    _buildInfoRow(
                      'Profile Path',
                      _profileImageUrl != null
                          ? 'profiles/${user?.uid}.jpg'
                          : 'Not uploaded',
                    ),
                    _buildInfoRow(
                      'Logo Path',
                      _businessLogoUrl != null
                          ? 'logos/${user?.uid}.jpg'
                          : 'Not uploaded',
                    ),
                    _buildInfoRow('Image Quality', '85%'),
                    _buildInfoRow('Max Resolution', '1920x1080'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection({
    required String title,
    required String description,
    required String? imageUrl,
    required VoidCallback onUpload,
    required VoidCallback? onDelete,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Image Display
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child:
                    imageUrl != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('Failed to load image'),
                                ],
                              );
                            },
                          ),
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            const Text('No image uploaded'),
                          ],
                        ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : onUpload,
                    icon: const Icon(Icons.upload),
                    label: Text(imageUrl != null ? 'Change' : 'Upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (imageUrl != null) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : onDelete,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}
