import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for caching user data in SharedPreferences
class UserCacheRepository {
  /// Cache key for the current user
  static const String _currentUserKey = 'current_user';

  /// Cache key for the last update time
  static const String _lastUpdateKey = 'current_user_last_update';

  /// Cache expiration time in minutes
  final int _cacheExpirationMinutes;

  /// SharedPreferences instance
  SharedPreferences? _prefs;

  /// Flag to track if SharedPreferences is initialized
  bool _prefsInitialized = false;

  /// Creates a new UserCacheRepository
  UserCacheRepository({
    int cacheExpirationMinutes = 60, // Default to 1 hour
  }) : _cacheExpirationMinutes = cacheExpirationMinutes;

  /// Initialize SharedPreferences
  Future<SharedPreferences> _getPrefs() async {
    if (!_prefsInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _prefsInitialized = true;
    }
    return _prefs!;
  }

  /// Cache the current user
  Future<void> cacheCurrentUser(UserEntity user) async {
    try {
      final prefs = await _getPrefs();
      final now = DateTime.now().toIso8601String();

      // Convert user entity to JSON
      final userJson = jsonEncode({
        'id': user.id,
        'email': user.email,
        'given_name': user.givenName,
        'family_name': user.familyName,
        'profile_picture_url': user.profilePictureUrl,
        'phone_number': user.phoneNumber,
        'roles': user.roles,
        'driver_details': user.driverDetails != null
            ? {
                'rating': user.driverDetails!.rating,
                'is_available': user.driverDetails!.isAvailable,
                'current_latitude': user.driverDetails!.currentLatitude,
                'current_longitude': user.driverDetails!.currentLongitude,
                'vehicles': user.driverDetails!.vehicles
                    .map(
                      (v) => {
                        'id': v.id,
                        'license_plate': v.licensePlate,
                        'brand': v.brand,
                        'model': v.model,
                        'type': v.type,
                        'photo_url': v.photoUrl,
                        'is_primary': v.isPrimary,
                      },
                    )
                    .toList(),
              }
            : null,
        'client_details': user.clientDetails != null
            ? {
                'rating': user.clientDetails!.rating,
                'favorite_driver_ids': user.clientDetails!.favoriteDriverIds,
              }
            : null,
      });

      // Save to cache
      await prefs.setString(_currentUserKey, userJson);
      await prefs.setString(_lastUpdateKey, now);

      debugPrint('User cached successfully: ${user.id}');
    } catch (e) {
      debugPrint('Error caching user: $e');
    }
  }

  /// Get the cached current user
  Future<UserEntity?> getCachedCurrentUser() async {
    try {
      final prefs = await _getPrefs();

      // Check if cache is valid
      if (!_isCacheValid(prefs)) {
        return null;
      }

      final userJson = prefs.getString(_currentUserKey);
      if (userJson == null) {
        return null;
      }

      final userData = jsonDecode(userJson);

      // Parse vehicles if available
      List<VehicleEntity> vehicles = [];
      if (userData['driver_details'] != null &&
          userData['driver_details']['vehicles'] != null) {
        final vehiclesJson = userData['driver_details']['vehicles'] as List;
        vehicles = vehiclesJson
            .map((v) => VehicleEntity(
                  id: v['id'],
                  licensePlate: v['license_plate'] ?? 'Unknown',
                  brand: v['brand'],
                  model: v['model'],
                  type: v['type'],
                  photoUrl: v['photo_url'],
                  isPrimary: v['is_primary'] ?? false,
                ))
            .toList();
      }

      // Create driver details if available
      DriverDetails? driverDetails;
      if (userData['driver_details'] != null) {
        driverDetails = DriverDetails(
          rating: userData['driver_details']['rating']?.toDouble(),
          isAvailable: userData['driver_details']['is_available'] ?? false,
          currentLatitude:
              userData['driver_details']['current_latitude']?.toDouble(),
          currentLongitude:
              userData['driver_details']['current_longitude']?.toDouble(),
          vehicles: vehicles,
        );
      }

      // Parse client details if available
      ClientDetails? clientDetails;
      if (userData['client_details'] != null) {
        final clientData = userData['client_details'];
        List<String> favoriteDriverIds = [];

        // Extract favorite driver IDs
        if (clientData['favorite_driver_ids'] != null) {
          if (clientData['favorite_driver_ids'] is List) {
            favoriteDriverIds =
                List<String>.from(clientData['favorite_driver_ids']);
          } else if (clientData['favorite_driver_ids'] is String) {
            final favoriteDriverIdsStr =
                clientData['favorite_driver_ids'].toString();
            if (favoriteDriverIdsStr.isNotEmpty) {
              favoriteDriverIds = favoriteDriverIdsStr.split(',');
            }
          }
        }

        clientDetails = ClientDetails(
          rating: clientData['rating']?.toDouble(),
          favoriteDriverIds: favoriteDriverIds,
        );
      }

      // Create user entity
      return UserEntity(
        id: userData['id'],
        email: userData['email'],
        givenName: userData['given_name'],
        familyName: userData['family_name'],
        phoneNumber: userData['phone_number'] ?? '',
        profilePictureUrl: userData['profile_picture_url'],
        roles: List<String>.from(userData['roles'] ?? []),
        driverDetails: driverDetails,
        clientDetails: clientDetails,
      );
    } catch (e) {
      debugPrint('Error getting cached user: $e');
      return null;
    }
  }

  /// Clear the user cache
  Future<void> clearCache() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_currentUserKey);
      await prefs.remove(_lastUpdateKey);

      debugPrint('User cache cleared');
    } catch (e) {
      debugPrint('Error clearing user cache: $e');
    }
  }

  /// Check if the cache is valid
  bool _isCacheValid(SharedPreferences prefs) {
    if (!prefs.containsKey(_lastUpdateKey)) {
      return false;
    }

    final lastUpdate = DateTime.parse(prefs.getString(_lastUpdateKey)!);
    final now = DateTime.now();
    return now.difference(lastUpdate).inMinutes <= _cacheExpirationMinutes;
  }
}
