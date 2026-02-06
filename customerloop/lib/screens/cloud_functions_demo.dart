import 'package:flutter/material.dart';
import 'package:customerloop/services/cloud_functions_service.dart';

/// Demo screen for testing Firebase Cloud Functions
///
/// This screen demonstrates:
/// 1. Callable functions (sayHello, calculatePoints)
/// 2. How to invoke functions from Flutter
/// 3. Handling function responses and errors
/// 4. Real-time function execution feedback
class CloudFunctionsDemo extends StatefulWidget {
  const CloudFunctionsDemo({super.key});

  @override
  State<CloudFunctionsDemo> createState() => _CloudFunctionsDemoState();
}

class _CloudFunctionsDemoState extends State<CloudFunctionsDemo> {
  final CloudFunctionsService _functionsService = CloudFunctionsService();
  final TextEditingController _nameController = TextEditingController(
    text: 'Alex',
  );
  final TextEditingController _amountController = TextEditingController(
    text: '150',
  );

  String _statusMessage = 'Ready to test Cloud Functions';
  bool _isLoading = false;
  Map<String, dynamic>? _lastResult;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _testSayHello() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Calling sayHello function...';
      _lastResult = null;
    });

    try {
      final result = await _functionsService.callSayHello(_nameController.text);

      setState(() {
        _isLoading = false;
        _lastResult = result;
        if (result['success']) {
          _statusMessage = '✅ Function called successfully!';
        } else {
          _statusMessage = '❌ Function call failed';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error: $e';
      });
    }
  }

  Future<void> _testCalculatePoints() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Calculating points...';
      _lastResult = null;
    });

    try {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final result = await _functionsService.calculatePoints(amount);

      setState(() {
        _isLoading = false;
        _lastResult = result;
        if (result['success']) {
          _statusMessage = '✅ Points calculated successfully!';
        } else {
          _statusMessage = '❌ Calculation failed';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error: $e';
      });
    }
  }

  Future<void> _testHealthCheck() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking Cloud Functions health...';
      _lastResult = null;
    });

    try {
      final result = await _functionsService.healthCheck();

      setState(() {
        _isLoading = false;
        _lastResult = result;
        if (result['success']) {
          _statusMessage = '✅ All functions are healthy!';
        } else {
          _statusMessage = '❌ Health check failed';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error: $e';
      });
    }
  }

  Future<void> _testAllFunctions() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing all functions...';
      _lastResult = null;
    });

    try {
      final result = await _functionsService.testAllFunctions();

      setState(() {
        _isLoading = false;
        _lastResult = result;
        _statusMessage = '✅ All function tests completed!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Functions Demo'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🚀 Firebase Cloud Functions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Test serverless functions running on Firebase',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Status Message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isLoading ? Colors.blue.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isLoading ? Colors.blue : Colors.green,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.info, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _statusMessage,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Test 1: sayHello Function
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1️⃣ Say Hello (Callable Function)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tests a simple callable function that returns a personalized greeting.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testSayHello,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Call sayHello'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test 2: calculatePoints Function
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '2️⃣ Calculate Points (Business Logic)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Calculates loyalty points: 1 pt/\$10, 2x bonus over \$100',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Amount (\$)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testCalculatePoints,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate Points'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test 3: Health Check
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '3️⃣ Health Check',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verify that all Cloud Functions are deployed and running.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testHealthCheck,
                      icon: const Icon(Icons.health_and_safety),
                      label: const Text('Check Health'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test All Functions Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testAllFunctions,
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Test All Functions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 24),

            // Results Display
            if (_lastResult != null)
              Card(
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.code, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text(
                            'Function Response',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatJson(_lastResult!),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.greenAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Info Card about Firestore Triggers
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bolt, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'Firestore Triggers (Auto-Run)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      CloudFunctionsTriggerExample.info,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatJson(Map<String, dynamic> json) {
    final buffer = StringBuffer();
    buffer.writeln('{');
    json.forEach((key, value) {
      if (value is Map) {
        buffer.writeln('  "$key": {');
        (value).forEach((k, v) {
          buffer.writeln('    "$k": "$v",');
        });
        buffer.writeln('  },');
      } else {
        buffer.writeln('  "$key": "$value",');
      }
    });
    buffer.writeln('}');
    return buffer.toString();
  }
}
