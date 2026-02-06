import 'package:cloud_functions/cloud_functions.dart';

/// Service class for interacting with Firebase Cloud Functions
///
/// This class provides methods to call both callable functions and
/// demonstrates how Cloud Functions integrate with the Flutter app.
class CloudFunctionsService {
  // Initialize Cloud Functions instance
  final FirebaseFunctions functions = FirebaseFunctions.instance;

  /// Call the sayHello Cloud Function
  ///
  /// This demonstrates a callable function that:
  /// - Receives data from the client
  /// - Processes it serverside
  /// - Returns a formatted response
  ///
  /// Example usage:
  /// ```dart
  /// final service = CloudFunctionsService();
  /// final result = await service.callSayHello('John');
  /// print(result['message']); // Hello, John! Welcome to CustomerLoop 🎉
  /// ```
  Future<Map<String, dynamic>> callSayHello(String name) async {
    try {
      // Create a reference to the callable function
      final HttpsCallable callable = functions.httpsCallable('sayHello');

      // Call the function with parameters
      final HttpsCallableResult result = await callable.call({'name': name});

      // Return the data from the function
      return {
        'success': true,
        'data': result.data,
        'message': result.data['message'] ?? 'No message received',
        'timestamp': result.data['timestamp'],
      };
    } catch (e) {
      // Handle errors
      print('Error calling sayHello function: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to call function: $e',
      };
    }
  }

  /// Call the calculatePoints Cloud Function
  ///
  /// This demonstrates a business logic function that:
  /// - Calculates loyalty points based on purchase amount
  /// - Applies business rules on the server
  /// - Prevents client-side manipulation
  ///
  /// Business Rule: 1 point per $10, 2x bonus for purchases over $100
  ///
  /// Example usage:
  /// ```dart
  /// final service = CloudFunctionsService();
  /// final result = await service.calculatePoints(150.0);
  /// print(result['points']); // 30 (150/10 = 15, then 15*2 = 30)
  /// ```
  Future<Map<String, dynamic>> calculatePoints(double amount) async {
    try {
      final HttpsCallable callable = functions.httpsCallable('calculatePoints');

      final HttpsCallableResult result = await callable.call({
        'amount': amount,
      });

      return {
        'success': true,
        'points': result.data['points'],
        'bonusApplied': result.data['bonusApplied'],
        'message': result.data['message'],
        'purchaseAmount': result.data['purchaseAmount'],
      };
    } catch (e) {
      print('Error calling calculatePoints function: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to calculate points: $e',
      };
    }
  }

  /// Health check for Cloud Functions
  ///
  /// Verifies that Cloud Functions are deployed and accessible
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final HttpsCallable callable = functions.httpsCallable('healthCheck');
      final HttpsCallableResult result = await callable.call();

      return {
        'success': true,
        'status': result.data['status'],
        'message': result.data['message'],
        'functions': result.data['functions'],
      };
    } catch (e) {
      print('Error calling healthCheck function: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Health check failed: $e',
      };
    }
  }

  /// Test all Cloud Functions
  ///
  /// Demonstrates calling multiple functions sequentially
  /// Useful for testing and verification
  Future<Map<String, dynamic>> testAllFunctions() async {
    final results = <String, dynamic>{};

    // Test sayHello
    print('Testing sayHello function...');
    final helloResult = await callSayHello('Test User');
    results['sayHello'] = helloResult;

    // Test calculatePoints
    print('Testing calculatePoints function...');
    final pointsResult = await calculatePoints(150.0);
    results['calculatePoints'] = pointsResult;

    // Test health check
    print('Testing healthCheck function...');
    final healthResult = await healthCheck();
    results['healthCheck'] = healthResult;

    return results;
  }
}

/// Example of how the event-based Firestore trigger works
///
/// The onNewCustomer function in Cloud Functions automatically runs when:
/// - A new document is created in the 'customers' collection
/// - No Flutter code needed - it's completely serverless!
///
/// What it does:
/// 1. Detects new customer creation
/// 2. Auto-assigns loyalty tier (Bronze)
/// 3. Gives 10 welcome bonus points
/// 4. Updates shop owner's customer count
/// 5. Logs everything for monitoring
///
/// To trigger it, simply create a customer in Firestore:
/// ```dart
/// await FirebaseFirestore.instance.collection('customers').add({
///   'name': 'John Doe',
///   'phone': '1234567890',
///   'shopOwnerId': 'ownerId123',
/// });
/// // The Cloud Function runs automatically!
/// ```
class CloudFunctionsTriggerExample {
  static const String info = '''
Firebase Cloud Functions - Firestore Triggers

The following functions run automatically when Firestore data changes:

1. onNewCustomer (onCreate trigger)
   - Triggers: When a new customer document is created
   - Actions:
     * Assigns default loyalty tier: "Bronze"
     * Adds 10 welcome bonus points
     * Sets account creation timestamp
     * Increments shop owner's customer count
   - No Flutter code needed!

2. onCustomerVisit (onCreate trigger)
   - Triggers: When a new visit document is created
   - Actions:
     * Increments customer's visit count
     * Checks for milestone achievements (5th, 10th, 25th visit)
     * Awards bonus points for milestones
     * Updates last visit timestamp
   - Completely serverless!

These functions run on Firebase's servers, reducing app complexity
and ensuring consistent business logic execution.
''';
}
