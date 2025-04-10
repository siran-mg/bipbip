import 'package:flutter/foundation.dart';
import 'package:ndao/location/domain/entities/position_entity.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/location/domain/utils/location_utils.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

/// Provider for managing driver data
class DriverProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  final LocatorProvider _locatorProvider;

  // State
  bool _isLoading = false;
  String? _error;
  List<UserEntity> _availableDrivers = [];
  PositionEntity? _userPosition;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserEntity> get availableDrivers => _availableDrivers;
  PositionEntity? get userPosition => _userPosition;

  /// Creates a new DriverProvider
  DriverProvider({
    required UserRepository userRepository,
    required LocatorProvider locatorProvider,
  })  : _userRepository = userRepository,
        _locatorProvider = locatorProvider;

  /// Load available drivers
  ///
  /// If [forceRefresh] is true, the cache will be ignored
  Future<void> loadAvailableDrivers({bool forceRefresh = false}) async {
    if (_isLoading) return;

    // Check if we already have drivers in the cache and this is not a forced refresh
    // If so, don't show loading state to prevent UI flicker
    final hasExistingDrivers = !forceRefresh && _availableDrivers.isNotEmpty;

    // Only show loading state if we don't have drivers or this is a forced refresh
    if (!hasExistingDrivers) {
      _isLoading = true;
      notifyListeners();
    }

    _error = null;

    try {
      // Load user position in parallel with drivers
      final positionFuture = _loadUserPosition();

      // Load available drivers
      final drivers =
          await _userRepository.getAvailableDrivers(forceRefresh: forceRefresh);

      // Wait for position to complete
      await positionFuture;

      // Update drivers list
      _availableDrivers = drivers;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load drivers: $e';
      notifyListeners();
    }
  }

  /// Load user position
  Future<void> _loadUserPosition() async {
    try {
      _userPosition = await _locatorProvider.getCurrentPosition();
    } catch (e) {
      // Use a default position for Madagascar if we can't get the user's location
      _userPosition = PositionEntity(latitude: -18.8792, longitude: 47.5079);
    }
  }

  /// Sort drivers by distance from user
  void sortDriversByDistance() {
    if (_userPosition == null) return;

    _availableDrivers.sort((a, b) {
      final distanceA = _getDistanceToDriver(a);
      final distanceB = _getDistanceToDriver(b);
      return distanceA.compareTo(distanceB);
    });

    notifyListeners();
  }

  /// Get the distance between the user and a driver
  double _getDistanceToDriver(UserEntity driver) {
    if (_userPosition == null ||
        driver.driverDetails?.currentLatitude == null ||
        driver.driverDetails?.currentLongitude == null) {
      return double.infinity;
    }

    return LocationUtils.calculateDistance(
      _userPosition!.latitude,
      _userPosition!.longitude,
      driver.driverDetails!.currentLatitude!,
      driver.driverDetails!.currentLongitude!,
    );
  }

  /// Refresh driver data
  /// Always shows loading state and forces a refresh
  Future<void> refresh() async {
    if (_isLoading) return;

    // Always show loading state for explicit refresh actions
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load user position in parallel with drivers
      final positionFuture = _loadUserPosition();

      // Force refresh of available drivers
      final drivers =
          await _userRepository.getAvailableDrivers(forceRefresh: true);

      // Wait for position to complete
      await positionFuture;

      // Update drivers list
      _availableDrivers = drivers;

      // Sort drivers by distance
      sortDriversByDistance();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to refresh drivers: $e';
      notifyListeners();
    }
  }

  /// Clear the cache
  void clearCache() {
    _userRepository.clearAvailableDriversCache();
  }
}
