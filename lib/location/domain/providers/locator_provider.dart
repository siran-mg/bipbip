import 'package:ndao/location/domain/entities/position_entity.dart';

abstract class LocatorProvider {
  /// Get the current position once
  Future<PositionEntity> getCurrentPosition();

  /// Get a human-readable address from a position
  Future<String?> getAddressFromPosition(PositionEntity position);

  /// Start tracking location in the background
  ///
  /// Returns a stream of position updates
  Future<Stream<PositionEntity>> startLocationTracking();

  /// Stop tracking location
  Future<void> stopLocationTracking();

  /// Check if location tracking is currently active
  Future<bool> isLocationTracking();

  /// Set whether location tracking should be enabled
  Future<void> setLocationTrackingEnabled(bool enabled);

  /// Check if location tracking is enabled in preferences
  Future<bool> isLocationTrackingEnabled();
}
