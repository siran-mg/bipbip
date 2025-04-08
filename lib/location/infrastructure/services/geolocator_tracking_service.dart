import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:ndao/location/domain/entities/position_entity.dart';
import 'package:ndao/location/domain/services/location_tracking_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementation of LocationTrackingService using Geolocator
class GeolocatorTrackingService implements LocationTrackingService {
  /// Stream controller for position updates
  StreamController<PositionEntity>? _positionStreamController;
  
  /// Stream subscription for position updates
  StreamSubscription<Position>? _positionStreamSubscription;
  
  /// Key for tracking preference
  static const String _trackingEnabledKey = 'driver_tracking_enabled';
  
  @override
  Future<Stream<PositionEntity>> startTracking() async {
    // Check if already tracking
    if (_positionStreamController != null) {
      return _positionStreamController!.stream;
    }
    
    // Request permission if not already granted
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }
    
    // Create stream controller
    _positionStreamController = StreamController<PositionEntity>.broadcast();
    
    // Set tracking enabled in preferences
    await setTrackingEnabled(true);
    
    // Start listening to position updates
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      // Convert to PositionEntity and add to stream
      final positionEntity = PositionEntity(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _positionStreamController?.add(positionEntity);
    });
    
    return _positionStreamController!.stream;
  }
  
  @override
  Future<void> stopTracking() async {
    // Cancel subscription
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    
    // Close stream controller
    await _positionStreamController?.close();
    _positionStreamController = null;
    
    // Set tracking disabled in preferences
    await setTrackingEnabled(false);
  }
  
  @override
  Future<bool> isTracking() async {
    return _positionStreamController != null && !_positionStreamController!.isClosed;
  }
  
  @override
  Future<void> setTrackingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trackingEnabledKey, enabled);
  }
  
  @override
  Future<bool> isTrackingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_trackingEnabledKey) ?? false;
  }
}
