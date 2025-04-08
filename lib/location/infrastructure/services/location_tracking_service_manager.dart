import 'package:flutter/foundation.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/user/domain/interactors/driver_location_tracking_interactor.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';

/// Manager for location tracking service
///
/// This class is responsible for starting and stopping the location tracking service
/// based on the user's preferences and role
class LocationTrackingServiceManager {
  final LocatorProvider _locatorProvider;
  final GetCurrentUserInteractor _getCurrentUserInteractor;
  final DriverLocationTrackingInteractor _driverLocationTrackingInteractor;

  /// Creates a new LocationTrackingServiceManager
  LocationTrackingServiceManager(
    this._locatorProvider,
    this._getCurrentUserInteractor,
    this._driverLocationTrackingInteractor,
  );

  /// Initialize the location tracking service
  ///
  /// This method should be called when the app starts
  Future<void> initialize() async {
    try {
      // Check if the current user is a driver
      final user = await _getCurrentUserInteractor.execute();

      // If no user is logged in or user is not a driver, do nothing
      if (user == null || !user.isDriver) {
        return;
      }

      // Check if location tracking is enabled
      final isTrackingEnabled =
          await _locatorProvider.isLocationTrackingEnabled();

      if (isTrackingEnabled) {
        // Start tracking
        await _driverLocationTrackingInteractor.startTracking(user.id);
      }
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error initializing location tracking: $e');
    }
  }
}
