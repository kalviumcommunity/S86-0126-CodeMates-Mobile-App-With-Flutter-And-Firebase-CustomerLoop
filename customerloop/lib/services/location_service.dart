import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// LocationService - Handles GPS location and permissions
/// Manages device location access, permission requests, and real-time tracking
/// Assignment 3.40: Google Maps Integration
class LocationService {
  // ============================================
  // PERMISSION HANDLING
  // ============================================

  /// Check if location services are enabled on device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission from user
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Check if app has location permission
  Future<bool> hasLocationPermission() async {
    final permission = await checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request permission with detailed error handling
  Future<PermissionStatus> requestLocationPermissionDetailed() async {
    // Check if location service is enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable location in device settings.',
      );
    }

    // Request permission
    final permission = await Permission.location.request();
    return permission;
  }

  /// Open app settings if permission permanently denied
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  // ============================================
  // GET CURRENT LOCATION
  // ============================================

  /// Get current device location
  /// Returns Position with latitude and longitude
  Future<Position> getCurrentLocation() async {
    // Check if location service is enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable location.',
      );
    }

    // Check permission
    LocationPermission permission = await checkPermission();

    // Request if denied
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    // Handle permanently denied
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable in settings.',
      );
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Get current location with custom accuracy
  Future<Position> getCurrentLocationWithAccuracy({
    required LocationAccuracy accuracy,
  }) async {
    final hasPermission = await hasLocationPermission();
    if (!hasPermission) {
      throw Exception('Location permission not granted');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
  }

  // ============================================
  // LOCATION STREAMING
  // ============================================

  /// Stream real-time location updates
  /// Listens to device location changes
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Stream location with custom settings
  Stream<Position> getLocationStreamCustom({
    required LocationAccuracy accuracy,
    required int distanceFilter,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  // ============================================
  // DISTANCE CALCULATION
  // ============================================

  /// Calculate distance between two coordinates (in meters)
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculate bearing between two coordinates (in degrees)
  double calculateBearing({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Convert distance to human-readable format
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }

  /// Get location accuracy description
  String getAccuracyDescription(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return 'Lowest (±3000m)';
      case LocationAccuracy.low:
        return 'Low (±1000m)';
      case LocationAccuracy.medium:
        return 'Medium (±100m)';
      case LocationAccuracy.high:
        return 'High (±10m)';
      case LocationAccuracy.best:
        return 'Best (±0m)';
      case LocationAccuracy.bestForNavigation:
        return 'Navigation (±0m)';
      default:
        return 'Unknown';
    }
  }

  /// Check if coordinates are valid
  bool isValidCoordinate({
    required double latitude,
    required double longitude,
  }) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  // ============================================
  // LOCATION INFO
  // ============================================

  /// Get detailed location info as string
  Future<String> getLocationInfo(Position position) async {
    return '''
Latitude: ${position.latitude.toStringAsFixed(6)}
Longitude: ${position.longitude.toStringAsFixed(6)}
Accuracy: ±${position.accuracy.toStringAsFixed(1)}m
Altitude: ${position.altitude.toStringAsFixed(1)}m
Speed: ${position.speed.toStringAsFixed(1)} m/s
Heading: ${position.heading.toStringAsFixed(0)}°
Timestamp: ${position.timestamp}
''';
  }
}
