import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/supabase_schema.dart';

class GeofencingService extends ChangeNotifier {
  static final GeofencingService _instance = GeofencingService._internal();

  factory GeofencingService() {
    return _instance;
  }

  GeofencingService._internal();

  static const double _geofenceRadiusMeters = 50.0;
  static const int _checkIntervalSeconds = 10;

  StreamSubscription<Position>? _positionStream;
  bool _isMonitoring = false;
  Position? _lastPosition;

  bool get isMonitoring => _isMonitoring;
  Position? get lastPosition => _lastPosition;

  final List<GeofenceCallback> _callbacks = [];

  /// Register a callback for geofence events
  void onGeofenceEvent(GeofenceCallback callback) {
    _callbacks.add(callback);
  }

  /// Remove a callback
  void removeCallback(GeofenceCallback callback) {
    _callbacks.remove(callback);
  }

  /// Start monitoring location for geofencing
  Future<void> startMonitoring({
    required double targetLatitude,
    required double targetLongitude,
    required String geofenceName,
  }) async {
    try {
      // Check location permissions
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied ||
            result == LocationPermission.deniedForever) {
          _notifyCallbacks(
            GeofenceEvent(
              name: geofenceName,
              type: GeofenceEventType.permissionDenied,
              message: 'Location permission denied',
            ),
          );
          return;
        }
      }

      _isMonitoring = true;
      notifyListeners();

      // Save geofence data locally
      await _saveGeofenceData(
        targetLatitude,
        targetLongitude,
        geofenceName,
      );

      // Start listening to location updates
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5, // Update every 5 meters
        ),
      ).listen((Position position) {
        _lastPosition = position;
        _checkGeofence(
          position,
          targetLatitude,
          targetLongitude,
          geofenceName,
        );
      });

      _notifyCallbacks(
        GeofenceEvent(
          name: geofenceName,
          type: GeofenceEventType.monitoringStarted,
          message: 'Started monitoring $geofenceName',
        ),
      );
    } catch (e) {
      debugPrint('Error starting geofencing: $e');
      _notifyCallbacks(
        GeofenceEvent(
          name: geofenceName,
          type: GeofenceEventType.error,
          message: 'Error starting monitoring: $e',
        ),
      );
    }
  }

  /// Stop monitoring location
  Future<void> stopMonitoring() async {
    try {
      await _positionStream?.cancel();
      _positionStream = null;
      _isMonitoring = false;
      _lastPosition = null;

      // Clear saved geofence data
      await _clearGeofenceData();

      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping geofencing: $e');
    }
  }

  /// Check if current position is within geofence
  void _checkGeofence(
    Position currentPosition,
    double targetLatitude,
    double targetLongitude,
    String geofenceName,
  ) {
    final distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      targetLatitude,
      targetLongitude,
    );

    if (distance <= _geofenceRadiusMeters) {
      _notifyCallbacks(
        GeofenceEvent(
          name: geofenceName,
          type: GeofenceEventType.entered,
          message: 'Arrived at $geofenceName',
          distance: distance,
        ),
      );

      // Stop monitoring after entering geofence
      stopMonitoring();
    } else if (distance < _geofenceRadiusMeters * 2) {
      // Approaching geofence
      _notifyCallbacks(
        GeofenceEvent(
          name: geofenceName,
          type: GeofenceEventType.approaching,
          message: 'Approaching $geofenceName (${distance.toStringAsFixed(1)}m away)',
          distance: distance,
        ),
      );
    }
  }

  /// Notify all registered callbacks
  void _notifyCallbacks(GeofenceEvent event) {
    for (final callback in _callbacks) {
      callback(event);
    }
    notifyListeners();
  }

  /// Save geofence data to local storage
  Future<void> _saveGeofenceData(
    double latitude,
    double longitude,
    String name,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('geofence_lat', latitude);
      await prefs.setDouble('geofence_lng', longitude);
      await prefs.setString('geofence_name', name);
      await prefs.setBool('geofence_active', true);
    } catch (e) {
      debugPrint('Error saving geofence data: $e');
    }
  }

  /// Load geofence data from local storage
  Future<Map<String, dynamic>?> loadGeofenceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isActive = prefs.getBool('geofence_active') ?? false;

      if (!isActive) return null;

      return {
        'latitude': prefs.getDouble('geofence_lat'),
        'longitude': prefs.getDouble('geofence_lng'),
        'name': prefs.getString('geofence_name'),
      };
    } catch (e) {
      debugPrint('Error loading geofence data: $e');
      return null;
    }
  }

  /// Clear saved geofence data
  Future<void> _clearGeofenceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('geofence_lat');
      await prefs.remove('geofence_lng');
      await prefs.remove('geofence_name');
      await prefs.setBool('geofence_active', false);
    } catch (e) {
      debugPrint('Error clearing geofence data: $e');
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}

enum GeofenceEventType {
  monitoringStarted,
  approaching,
  entered,
  exited,
  permissionDenied,
  error,
}

class GeofenceEvent {
  final String name;
  final GeofenceEventType type;
  final String message;
  final double? distance;
  final DateTime timestamp;

  GeofenceEvent({
    required this.name,
    required this.type,
    required this.message,
    this.distance,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'GeofenceEvent($name, $type, ${distance?.toStringAsFixed(1)}m)';
}

typedef GeofenceCallback = void Function(GeofenceEvent event);
