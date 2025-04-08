import 'package:ndao/location/domain/entities/position_entity.dart';

/// Service for tracking location in the background
abstract class LocationTrackingService {
  /// Start tracking location in the background
  /// 
  /// Returns a stream of position updates
  Future<Stream<PositionEntity>> startTracking();
  
  /// Stop tracking location
  Future<void> stopTracking();
  
  /// Check if location tracking is currently active
  Future<bool> isTracking();
  
  /// Set whether location tracking should be enabled
  Future<void> setTrackingEnabled(bool enabled);
  
  /// Check if location tracking is enabled in preferences
  Future<bool> isTrackingEnabled();
}
