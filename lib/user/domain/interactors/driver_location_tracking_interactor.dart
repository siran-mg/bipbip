import 'dart:async';

import 'package:ndao/location/domain/entities/position_entity.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

/// Interactor for tracking driver location
class DriverLocationTrackingInteractor {
  /// The location provider
  final LocatorProvider _locatorProvider;

  /// The user repository
  final UserRepository _userRepository;

  /// Stream subscription for position updates
  StreamSubscription<PositionEntity>? _positionSubscription;

  /// Creates a new DriverLocationTrackingInteractor
  DriverLocationTrackingInteractor(this._locatorProvider, this._userRepository);

  /// Start tracking driver location
  ///
  /// Updates the driver's position in the database when it changes
  Future<void> startTracking(String driverId) async {
    // Stop any existing tracking
    await stopTracking();

    // Start location tracking
    final positionStream = await _locatorProvider.startLocationTracking();

    // Subscribe to position updates
    _positionSubscription = positionStream.listen((position) async {
      try {
        // Update driver position in database
        await _userRepository.updateDriverPosition(
          driverId,
          position.latitude,
          position.longitude,
        );
      } catch (e) {
        // Handle error (could log it or show a notification)
      }
    });
  }

  /// Stop tracking driver location
  Future<void> stopTracking() async {
    // Cancel subscription
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    // Stop location tracking
    await _locatorProvider.stopLocationTracking();
  }

  /// Check if location tracking is currently active
  Future<bool> isTracking() {
    return _locatorProvider.isLocationTracking();
  }

  /// Set whether location tracking should be enabled
  Future<void> setTrackingEnabled(bool enabled) {
    return _locatorProvider.setLocationTrackingEnabled(enabled);
  }

  /// Check if location tracking is enabled in preferences
  Future<bool> isTrackingEnabled() {
    return _locatorProvider.isLocationTrackingEnabled();
  }

  /// Toggle tracking for a driver
  ///
  /// If tracking is enabled, starts tracking
  /// If tracking is disabled, stops tracking
  Future<void> toggleTracking(String driverId, bool enabled) async {
    if (enabled) {
      await startTracking(driverId);
    } else {
      await stopTracking();
    }

    await setTrackingEnabled(enabled);
  }
}
