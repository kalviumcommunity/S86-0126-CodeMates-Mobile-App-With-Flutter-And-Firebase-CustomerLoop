import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firestore_security_service.dart';
import '../services/auth_service.dart';

/// Firestore Security Demo Screen
///
/// Demonstrates:
/// - Firebase Authentication integration
/// - Secure Firestore operations
/// - Security rules testing
/// - Permission handling
/// - Role-based access control
class FirestoreSecurityScreen extends StatefulWidget {
  const FirestoreSecurityScreen({super.key});

  @override
  State<FirestoreSecurityScreen> createState() =>
      _FirestoreSecurityScreenState();
}

class _FirestoreSecurityScreenState extends State<FirestoreSecurityScreen> {
  final FirestoreSecurityService _securityService = FirestoreSecurityService();
  final AuthService _authService = AuthService();

  Map<String, bool>? _testResults;
  bool _isRunningTests = false;
  bool _isLoadingProfile = false;
  Map<String, dynamic>? _userProfile;
  String? _rulesInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoadingProfile = true);

    try {
      _userProfile = await _securityService.getUserProfile();
      _rulesInfo = await _securityService.getRulesInfo();
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }

    setState(() => _isLoadingProfile = false);
  }

  Future<void> _runSecurityTests() async {
    setState(() {
      _isRunningTests = true;
      _testResults = null;
    });

    try {
      final results = await _securityService.runAllSecurityTests();
      setState(() {
        _testResults = results;
      });

      // Show summary
      final passed = results.values.where((v) => v).length;
      final total = results.length;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Security Tests Complete: $passed/$total passed'),
            backgroundColor: passed == total ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error running tests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isRunningTests = false);
  }

  Future<void> _updateProfile() async {
    final nameController = TextEditingController(
      text: _userProfile?['name'] ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Profile'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Update'),
              ),
            ],
          ),
    );

    if (result == true && mounted) {
      try {
        await _securityService.updateUserProfile(
          name: nameController.text,
          email: _authService.currentUser?.email ?? '',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        _loadUserInfo();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔒 Firestore Security'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showSecurityInfo,
            tooltip: 'Security Info',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Authentication Status Card
            _buildAuthStatusCard(user),
            const SizedBox(height: 16),

            // Security Rules Info Card
            _buildRulesInfoCard(),
            const SizedBox(height: 16),

            // User Profile Card
            _buildProfileCard(),
            const SizedBox(height: 16),

            // Security Tests Card
            _buildSecurityTestsCard(),
            const SizedBox(height: 16),

            // Test Results Card
            if (_testResults != null) _buildTestResultsCard(),
            if (_testResults != null) const SizedBox(height: 16),

            // Security Rules Preview Card
            _buildRulesPreviewCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthStatusCard(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.verified_user, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Authentication Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Status',
              user != null ? 'Authenticated ✅' : 'Not Authenticated ❌',
            ),
            if (user != null) ...[
              _buildInfoRow('User ID', user.uid),
              _buildInfoRow('Email', user.email ?? 'N/A'),
              _buildInfoRow(
                'Email Verified',
                user.emailVerified ? 'Yes ✅' : 'No ❌',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRulesInfoCard() {
    return Card(
      color: Colors.purple[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.security, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Security Rules Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _rulesInfo ?? 'Loading...',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '🔒 Secure Mode: Only authenticated users can access data',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '👤 Owner-Only: Users can only access their own data',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    if (_isLoadingProfile) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

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
                  '👤 Your Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _updateProfile,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Update'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_userProfile != null) ...[
              _buildInfoRow('Name', _userProfile!['name'] ?? 'Not set'),
              _buildInfoRow('Email', _userProfile!['email'] ?? 'Not set'),
              if (_userProfile!['updatedAt'] != null)
                _buildInfoRow(
                  'Last Updated',
                  _userProfile!['updatedAt'].toDate().toString().substring(
                    0,
                    16,
                  ),
                ),
            ] else
              const Text(
                'No profile data found. Click Update to create your profile.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTestsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧪 Security Tests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test Firestore security rules to ensure proper access control',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRunningTests ? null : _runSecurityTests,
                icon:
                    _isRunningTests
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.play_arrow),
                label: Text(
                  _isRunningTests ? 'Running Tests...' : 'Run Security Tests',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultsCard() {
    final passed = _testResults!.values.where((v) => v).length;
    final total = _testResults!.length;
    final allPassed = passed == total;

    return Card(
      color: allPassed ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  allPassed ? Icons.check_circle : Icons.warning,
                  color: allPassed ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Test Results: $passed/$total Passed',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._testResults!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      entry.value ? Icons.check_circle : Icons.cancel,
                      color: entry.value ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesPreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.code, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Security Rules Preview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '// Users Collection',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'match /users/{userId} {',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                  Text(
                    '  allow read: if isOwner(userId);',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                  Text(
                    '  allow write: if isOwner(userId);',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                  Text(
                    '}',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '// Customers Collection',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'match /customers/{customerId} {',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                  Text(
                    '  allow read, write: if',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                  Text(
                    '    resource.data.businessId == request.auth.uid;',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                  Text(
                    '}',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _copyRulesSnippet,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy Rules'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _viewFullRules,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('View Full'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(
            child: SelectableText(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _copyRulesSnippet() {
    const rules = '''
match /users/{userId} {
  allow read: if isOwner(userId);
  allow write: if isOwner(userId);
}

match /customers/{customerId} {
  allow read, write: if resource.data.businessId == request.auth.uid;
}
''';

    Clipboard.setData(const ClipboardData(text: rules));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Rules snippet copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewFullRules() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Full Security Rules'),
            content: const SingleChildScrollView(
              child: Text(
                'Full rules are in firestore.rules file.\n\n'
                'Key Rules:\n'
                '✅ Users can only read/write their own data\n'
                '✅ Customers linked to businessId\n'
                '✅ Authentication required for all operations\n'
                '✅ Field validation enforced\n'
                '✅ Admin operations restricted\n\n'
                'Deploy with:\n'
                'firebase deploy --only firestore:rules',
                style: TextStyle(fontSize: 13),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showSecurityInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('🔒 Firestore Security'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Why Security Matters:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Protects user data from unauthorized access'),
                  Text('• Prevents malicious writes and data tampering'),
                  Text('• Ensures users can only access their own data'),
                  Text('• Enforces role-based permissions'),
                  SizedBox(height: 16),
                  Text(
                    'How It Works:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. User must be authenticated (logged in)'),
                  Text('2. Firestore rules check request.auth.uid'),
                  Text('3. Rules compare with document owner'),
                  Text('4. Access granted only if rules pass'),
                  SizedBox(height: 16),
                  Text(
                    'Testing:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Run tests to verify rules work correctly'),
                  Text('• Tests check allowed and denied operations'),
                  Text('• Green = test passed, Red = test failed'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got It'),
              ),
            ],
          ),
    );
  }
}
