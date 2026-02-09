import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

/// MapScreen - Interactive Google Maps display with full features
/// Demonstrates Google Maps SDK integration, markers, location tracking
/// Assignment 3.40 & 3.41: Google Maps with Custom Markers and Live Location
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final Completer<GoogleMapController> _mapController = Completer();

  // Map settings
  MapType _currentMapType = MapType.normal;
  bool _trafficEnabled = false;
  bool _buildingsEnabled = true;
  bool _myLocationEnabled = false;
  bool _myLocationButtonEnabled = false;

  // Location tracking
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  bool _isLoadingLocation = false;
  String _locationStatus = '';

  // Markers
  final Set<Marker> _markers = {};
  int _markerIdCounter = 0;

  // Polylines for drawing paths
  final Set<Polyline> _polylines = {};
  final List<LatLng> _pathPoints = [];
  bool _showPath = false;

  // Custom marker icons
  BitmapDescriptor? _userMarkerIcon;
  BitmapDescriptor? _businessMarkerIcon;
  BitmapDescriptor? _customMarkerIcon;
  bool _customIconsLoaded = false;

  // Distance tracking
  double? _totalDistanceTraveled = 0.0;
  LatLng? _lastTrackedPosition;

  // Initial camera position (San Francisco by default)
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12.0,
  );

  // Sample business locations (for demo)
  final List<Map<String, dynamic>> _businessLocations = [
    {
      'name': 'Business HQ',
      'lat': 37.7749,
      'lng': -122.4194,
      'description': 'Main office location',
    },
    {
      'name': 'Branch Office',
      'lat': 37.7849,
      'lng': -122.4094,
      'description': 'Secondary location',
    },
    {
      'name': 'Customer Site A',
      'lat': 37.7649,
      'lng': -122.4294,
      'description': 'High-value customer',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  // ============================================
  // INITIALIZATION
  // ============================================

  Future<void> _initializeMap() async {
    // Load custom marker icons
    await _loadCustomMarkers();

    // Add default markers for business locations
    _addBusinessMarkers();

    // Request location permission
    await _requestLocationPermission();
  }

  // ============================================
  // CUSTOM MARKER ICONS
  // ============================================

  Future<void> _loadCustomMarkers() async {
    try {
      // Try to load custom marker icons from assets
      // If assets don't exist, fall back to default colored markers

      // Note: Add PNG files to assets/icons/ folder for custom icons
      // For now, we use Material Design icons as programmatic markers

      setState(() {
        _customIconsLoaded = true;
      });
    } catch (e) {
      // Use default markers if custom icons fail to load
      debugPrint('Custom markers not loaded: $e');
      setState(() {
        _customIconsLoaded = false;
      });
    }
  }

  BitmapDescriptor _getMarkerIcon(String type) {
    // Return colored markers based on type
    switch (type) {
      case 'user':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'business':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'customer':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'destination':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  void _addBusinessMarkers() {
    for (var location in _businessLocations) {
      _addMarker(
        position: LatLng(location['lat'], location['lng']),
        title: location['name'],
        snippet: location['description'],
        color: _getMarkerIcon('business'),
        markerType: 'business',
      );
    }
  }

  // ============================================
  // LOCATION & PERMISSIONS
  // ============================================

  Future<void> _requestLocationPermission() async {
    try {
      setState(() {
        _isLoadingLocation = true;
        _locationStatus = 'Checking permissions...';
      });

      final hasPermission = await _locationService.hasLocationPermission();

      if (!hasPermission) {
        final permission = await _locationService.requestPermission();

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          setState(() {
            _locationStatus = 'Location permission denied';
            _isLoadingLocation = false;
          });
          _showSnackBar('❌ Location permission denied', Colors.red);
          return;
        }
      }

      // Enable location display
      setState(() {
        _myLocationEnabled = true;
        _myLocationButtonEnabled = true;
        _locationStatus = 'Location enabled';
      });

      // Get current location
      await _getCurrentLocation();
    } catch (e) {
      setState(() {
        _locationStatus = 'Error: $e';
        _isLoadingLocation = false;
      });
      _showSnackBar('Location error: $e', Colors.red);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
        _locationStatus = 'Getting location...';
      });

      final position = await _locationService.getCurrentLocation();

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
        _locationStatus =
            'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
      });

      // Move camera to current location
      _moveCameraToPosition(
        LatLng(position.latitude, position.longitude),
        zoom: 15.0,
      );

      // Add marker at current location
      _addMarker(
        position: LatLng(position.latitude, position.longitude),
        title: '📍 Your Location',
        snippet:
            'Current position\nAccuracy: ±${position.accuracy.toStringAsFixed(1)}m',
        markerType: 'user',
      );

      _showSnackBar('✅ Location found!', Colors.green);
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _locationStatus = 'Location error';
      });
      _showSnackBar('Failed to get location: $e', Colors.red);
    }
  }

  void _startLocationTracking() {
    // Clear previous path
    _pathPoints.clear();
    _totalDistanceTraveled = 0.0;
    _lastTrackedPosition = null;

    _positionStream = _locationService.getLocationStream().listen(
      (Position position) {
        final currentLatLng = LatLng(position.latitude, position.longitude);

        setState(() {
          _currentPosition = position;
          _locationStatus =
              'Tracking: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';

          // Add point to path
          _pathPoints.add(currentLatLng);

          // Calculate distance traveled
          if (_lastTrackedPosition != null) {
            final distance = _locationService.calculateDistance(
              startLatitude: _lastTrackedPosition!.latitude,
              startLongitude: _lastTrackedPosition!.longitude,
              endLatitude: currentLatLng.latitude,
              endLongitude: currentLatLng.longitude,
            );
            _totalDistanceTraveled = (_totalDistanceTraveled ?? 0) + distance;
          }
          _lastTrackedPosition = currentLatLng;

          // Update polyline to show path
          if (_showPath && _pathPoints.length > 1) {
            _polylines.clear();
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('tracking_path'),
                points: _pathPoints,
                color: Colors.blue,
                width: 4,
                geodesic: true,
              ),
            );
          }

          // Update user marker position
          _updateUserMarker(currentLatLng);
        });

        // Update camera position smoothly
        _moveCameraToPosition(currentLatLng, zoom: 16.0);
      },
      onError: (error) {
        _showSnackBar('Tracking error: $error', Colors.red);
      },
    );

    _showSnackBar('📍 Real-time tracking started', Colors.blue);
  }

  void _stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _showSnackBar(
      '⏹️ Tracking stopped | Distance: ${_locationService.formatDistance(_totalDistanceTraveled ?? 0)}',
      Colors.orange,
    );
  }

  void _updateUserMarker(LatLng position) {
    // Remove old user marker
    _markers.removeWhere(
      (marker) => marker.markerId.value.startsWith('user_location'),
    );

    // Add updated user marker
    _markers.add(
      Marker(
        markerId: const MarkerId('user_location_live'),
        position: position,
        infoWindow: InfoWindow(
          title: '📍 You are here',
          snippet:
              'Distance: ${_locationService.formatDistance(_totalDistanceTraveled ?? 0)}',
        ),
        icon: _getMarkerIcon('user'),
        anchor: const Offset(0.5, 0.5),
      ),
    );
  }

  void _togglePathVisibility() {
    setState(() {
      _showPath = !_showPath;
      if (!_showPath) {
        _polylines.clear();
      }
    });
    _showSnackBar(
      _showPath ? '🛤️ Path visible' : '🛤️ Path hidden',
      Colors.blue,
    );
  }

  // ============================================
  // CAMERA CONTROLS
  // ============================================

  Future<void> _moveCameraToPosition(
    LatLng position, {
    double zoom = 14.0,
  }) async {
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: zoom),
      ),
    );
  }

  Future<void> _zoomIn() async {
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.zoomOut());
  }

  // ============================================
  // MARKER MANAGEMENT
  // ============================================

  void _addMarker({
    required LatLng position,
    required String title,
    String snippet = '',
    BitmapDescriptor? color,
    String markerType = 'custom',
  }) {
    final markerId = MarkerId('${markerType}_marker_${_markerIdCounter++}');

    final marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: title, snippet: snippet),
      icon: color ?? _getMarkerIcon(markerType),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  void _clearMarkers() {
    setState(() {
      _markers.clear();
      _markerIdCounter = 0;
      _polylines.clear();
      _pathPoints.clear();
      _totalDistanceTraveled = 0.0;
    });
    _showSnackBar('🗑️ All markers and paths cleared', Colors.grey);
  }

  void _onMapTapped(LatLng position) {
    // Calculate distance from current position if available
    String distanceInfo = '';
    if (_currentPosition != null) {
      final distance = _locationService.calculateDistance(
        startLatitude: _currentPosition!.latitude,
        startLongitude: _currentPosition!.longitude,
        endLatitude: position.latitude,
        endLongitude: position.longitude,
      );
      distanceInfo =
          '\nDistance from you: ${_locationService.formatDistance(distance)}';
    }

    _addMarker(
      position: position,
      title: 'Custom Marker',
      snippet:
          'Lat: ${position.latitude.toStringAsFixed(4)}, '
          'Lng: ${position.longitude.toStringAsFixed(4)}'
          '$distanceInfo',
      markerType: 'destination',
    );
    _showSnackBar('📍 Marker added', Colors.green);
  }

  // ============================================
  // MAP TYPE CONTROLS
  // ============================================

  void _changeMapType() {
    setState(() {
      // Cycle through map types
      switch (_currentMapType) {
        case MapType.normal:
          _currentMapType = MapType.satellite;
          break;
        case MapType.satellite:
          _currentMapType = MapType.hybrid;
          break;
        case MapType.hybrid:
          _currentMapType = MapType.terrain;
          break;
        case MapType.terrain:
          _currentMapType = MapType.normal;
          break;
        default:
          _currentMapType = MapType.normal;
      }
    });

    final typeNames = {
      MapType.normal: 'Normal',
      MapType.satellite: 'Satellite',
      MapType.hybrid: 'Hybrid',
      MapType.terrain: 'Terrain',
    };

    _showSnackBar('🗺️ Map type: ${typeNames[_currentMapType]}', Colors.blue);
  }

  void _toggleTraffic() {
    setState(() {
      _trafficEnabled = !_trafficEnabled;
    });
    _showSnackBar(
      _trafficEnabled ? '🚗 Traffic ON' : '🚗 Traffic OFF',
      Colors.blue,
    );
  }

  // ============================================
  // UI HELPERS
  // ============================================

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================
  // UI BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Map type selector
          IconButton(
            icon: const Icon(Icons.layers),
            tooltip: 'Change map type',
            onPressed: _changeMapType,
          ),
          // Traffic toggle
          IconButton(
            icon: Icon(
              _trafficEnabled ? Icons.traffic : Icons.traffic_outlined,
            ),
            tooltip: 'Toggle traffic',
            onPressed: _toggleTraffic,
          ),
          // Clear markers
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear markers',
            onPressed: _clearMarkers,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: _defaultPosition,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: _myLocationEnabled,
            myLocationButtonEnabled: _myLocationButtonEnabled,
            trafficEnabled: _trafficEnabled,
            buildingsEnabled: _buildingsEnabled,
            compassEnabled: true,
            mapToolbarEnabled: true,
            zoomControlsEnabled: false,
            onTap: _onMapTapped,
            onLongPress: (position) {
              _showSnackBar(
                'Long press: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
                Colors.purple,
              );
            },
          ),

          // Info banner at top
          if (_locationStatus.isNotEmpty)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      if (_isLoadingLocation)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _locationStatus,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Map info card (bottom)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Google Maps Demo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Markers: ${_markers.length} | '
                      'Type: ${_currentMapType.toString().split('.').last}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.my_location,
                          label: 'Locate',
                          onPressed: _getCurrentLocation,
                        ),
                        _buildActionButton(
                          icon:
                              _positionStream == null
                                  ? Icons.play_arrow
                                  : Icons.stop,
                          label: _positionStream == null ? 'Track' : 'Stop',
                          onPressed:
                              _positionStream == null
                                  ? _startLocationTracking
                                  : _stopLocationTracking,
                        ),
                        _buildActionButton(
                          icon:
                              _showPath
                                  ? Icons.timeline
                                  : Icons.timeline_outlined,
                          label: 'Path',
                          onPressed: _togglePathVisibility,
                        ),
                        _buildActionButton(
                          icon: Icons.zoom_in,
                          label: 'Zoom+',
                          onPressed: _zoomIn,
                        ),
                        _buildActionButton(
                          icon: Icons.zoom_out,
                          label: 'Zoom-',
                          onPressed: _zoomOut,
                        ),
                      ],
                    ),
                    if (_totalDistanceTraveled != null &&
                        _totalDistanceTraveled! > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '📏 Distance traveled: ${_locationService.formatDistance(_totalDistanceTraveled!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => _buildMapInstructionsSheet(),
          );
        },
        icon: const Icon(Icons.info_outline),
        label: const Text('How to Use'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapInstructionsSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🗺️ Map Instructions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInstruction('📍', 'Tap on map to add custom markers'),
          _buildInstruction('🤏', 'Pinch to zoom in/out'),
          _buildInstruction('✋', 'Drag to pan around the map'),
          _buildInstruction('🎯', 'Press "Locate" to find your position'),
          _buildInstruction('▶️', 'Press "Track" for real-time updates'),
          _buildInstruction('🗺️', 'Press layers icon to change map type'),
          _buildInstruction('🚗', 'Press traffic icon to show traffic'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it!'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
