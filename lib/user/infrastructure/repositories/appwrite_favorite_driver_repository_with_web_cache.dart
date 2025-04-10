import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:ndao/user/domain/repositories/favorite_driver_repository.dart';
import 'package:ndao/user/infrastructure/repositories/queries/user_queries.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Implementation of FavoriteDriverRepository using Appwrite with caching
/// that works on both mobile and web platforms
class AppwriteFavoriteDriverRepository implements FavoriteDriverRepository {
  final Databases _databases;
  final UserQueries _userQueries;
  SharedPreferences? _prefs;
  bool _prefsInitialized = false;

  /// Database ID
  final String _databaseId;

  /// Collection ID for favorite drivers
  final String _favoriteDriversCollectionId;

  /// Cache expiration time in minutes
  final int _cacheExpirationMinutes;

  /// Creates a new AppwriteFavoriteDriverRepository
  AppwriteFavoriteDriverRepository(
    this._databases,
    this._userQueries, {
    String databaseId = 'ndao',
    String favoriteDriversCollectionId = 'favorite_drivers',
    int cacheExpirationMinutes = 60, // Default to 1 hour
  })  : _databaseId = databaseId,
        _favoriteDriversCollectionId = favoriteDriversCollectionId,
        _cacheExpirationMinutes = cacheExpirationMinutes;

  /// Initialize shared preferences for caching
  Future<SharedPreferences> _getPrefs() async {
    if (!_prefsInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _prefsInitialized = true;
    }
    return _prefs!;
  }

  /// Get a cache key for favorite status
  String _getFavoriteStatusCacheKey(String clientId, String driverId) {
    return 'favorite_status:$clientId:$driverId';
  }

  /// Get a cache key for favorite drivers list
  String _getFavoriteDriversCacheKey(String clientId) {
    return 'favorite_drivers:$clientId';
  }

  /// Get a cache key for last update time
  String _getLastUpdateCacheKey(String clientId) {
    return 'last_update:$clientId';
  }

  /// Check if the cache is valid
  Future<bool> _isCacheValid(String clientId) async {
    final prefs = await _getPrefs();
    final lastUpdateKey = _getLastUpdateCacheKey(clientId);

    if (!prefs.containsKey(lastUpdateKey)) {
      return false;
    }

    final lastUpdate = DateTime.parse(prefs.getString(lastUpdateKey)!);
    final now = DateTime.now();
    return now.difference(lastUpdate).inMinutes <= _cacheExpirationMinutes;
  }

  @override
  Future<bool> addFavoriteDriver(String clientId, String driverId) async {
    try {
      // Check if the client and driver exist
      final client = await _userQueries.getUserById(clientId);
      if (client == null) {
        throw Exception('Client not found');
      }

      final driver = await _userQueries.getUserById(driverId);
      if (driver == null) {
        throw Exception('Driver not found');
      }

      // Check if the client is actually a client
      if (!client.isClient) {
        throw Exception('User is not a client');
      }

      // Check if the driver is actually a driver
      if (!driver.isDriver) {
        throw Exception('User is not a driver');
      }

      // Check if the favorite already exists
      final isAlreadyFavorite = await isDriverFavorite(clientId, driverId);
      if (isAlreadyFavorite) {
        return true; // Already a favorite, consider it a success
      }

      // Add to favorites in Appwrite
      final now = DateTime.now().toIso8601String();
      await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _favoriteDriversCollectionId,
        documentId: ID.unique(),
        data: {
          'client_id': clientId,
          'driver_id': driverId,
          'created_at': now,
          'updated_at': now,
        },
      );

      // Update cache
      final prefs = await _getPrefs();

      // Cache favorite status
      prefs.setBool(_getFavoriteStatusCacheKey(clientId, driverId), true);

      // Update favorite drivers list in cache if it exists
      if (prefs.containsKey(_getFavoriteDriversCacheKey(clientId))) {
        final cachedDriversJson =
            prefs.getString(_getFavoriteDriversCacheKey(clientId));
        if (cachedDriversJson != null) {
          final List<dynamic> cachedDrivers = jsonDecode(cachedDriversJson);

          // Add the new driver to the list
          final driverJson = {
            'id': driver.id,
            'email': driver.email,
            'given_name': driver.givenName,
            'family_name': driver.familyName,
            'profile_picture_url': driver.profilePictureUrl,
            'phone_number': driver.phoneNumber,
            'roles': driver.roles,
            'driver_details': driver.driverDetails != null
                ? {
                    'rating': driver.driverDetails!.rating,
                    'is_available': driver.driverDetails!.isAvailable,
                    'current_latitude': driver.driverDetails!.currentLatitude,
                    'current_longitude': driver.driverDetails!.currentLongitude,
                    'vehicles': driver.driverDetails!.vehicles
                        .map((v) => {
                              'id': v.id,
                              'brand': v.brand,
                              'model': v.model,
                              'type': v.type,
                              'is_primary': v.isPrimary,
                            })
                        .toList(),
                  }
                : null,
          };

          cachedDrivers.add(driverJson);
          prefs.setString(
              _getFavoriteDriversCacheKey(clientId), jsonEncode(cachedDrivers));
        }
      }

      return true;
    } on AppwriteException catch (e) {
      debugPrint('Failed to add favorite driver: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Failed to add favorite driver: $e');
      return false;
    }
  }

  @override
  Future<bool> removeFavoriteDriver(String clientId, String driverId) async {
    try {
      // Find the favorite document
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _favoriteDriversCollectionId,
        queries: [
          Query.equal('client_id', clientId),
          Query.equal('driver_id', driverId),
        ],
      );

      // If no document found, consider it a success (already removed)
      if (response.documents.isEmpty) {
        // Update cache
        final prefs = await _getPrefs();
        prefs.setBool(_getFavoriteStatusCacheKey(clientId, driverId), false);
        return true;
      }

      // Delete the document
      final documentId = response.documents.first.$id;
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: _favoriteDriversCollectionId,
        documentId: documentId,
      );

      // Update cache
      final prefs = await _getPrefs();

      // Cache favorite status
      prefs.setBool(_getFavoriteStatusCacheKey(clientId, driverId), false);

      // Update favorite drivers list in cache if it exists
      if (prefs.containsKey(_getFavoriteDriversCacheKey(clientId))) {
        final cachedDriversJson =
            prefs.getString(_getFavoriteDriversCacheKey(clientId));
        if (cachedDriversJson != null) {
          final List<dynamic> cachedDrivers = jsonDecode(cachedDriversJson);

          // Remove the driver from the list
          final updatedDrivers = cachedDrivers
              .where((driver) => driver['id'] != driverId)
              .toList();
          prefs.setString(_getFavoriteDriversCacheKey(clientId),
              jsonEncode(updatedDrivers));
        }
      }

      return true;
    } on AppwriteException catch (e) {
      debugPrint('Failed to remove favorite driver: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Failed to remove favorite driver: $e');
      return false;
    }
  }

  @override
  Future<bool> isDriverFavorite(String clientId, String driverId) async {
    try {
      // Check cache first
      final prefs = await _getPrefs();
      final cacheKey = _getFavoriteStatusCacheKey(clientId, driverId);

      if (prefs.containsKey(cacheKey)) {
        return prefs.getBool(cacheKey) ?? false;
      }

      // Cache miss, query the database
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _favoriteDriversCollectionId,
        queries: [
          Query.equal('client_id', clientId),
          Query.equal('driver_id', driverId),
        ],
      );

      // Update cache with the result
      final isFavorite = response.documents.isNotEmpty;
      prefs.setBool(cacheKey, isFavorite);

      return isFavorite;
    } on AppwriteException catch (e) {
      debugPrint('Failed to check if driver is favorite: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Failed to check if driver is favorite: $e');
      return false;
    }
  }

  @override
  Future<List<UserEntity>> getFavoriteDrivers(String clientId) async {
    try {
      // Check cache first
      if (await _isCacheValid(clientId)) {
        final prefs = await _getPrefs();
        final cacheKey = _getFavoriteDriversCacheKey(clientId);

        if (prefs.containsKey(cacheKey)) {
          final cachedDriversJson = prefs.getString(cacheKey);
          if (cachedDriversJson != null) {
            final List<dynamic> cachedDrivers = jsonDecode(cachedDriversJson);

            // Convert to UserEntity objects
            final drivers = <UserEntity>[];

            for (final driverJson in cachedDrivers) {
              try {
                // Parse vehicles if available
                List<VehicleEntity> vehicles = [];
                if (driverJson['driver_details'] != null &&
                    driverJson['driver_details']['vehicles'] != null) {
                  final vehiclesJson =
                      driverJson['driver_details']['vehicles'] as List;
                  vehicles = vehiclesJson
                      .map((v) => VehicleEntity(
                            id: v['id'],
                            brand: v['brand'],
                            model: v['model'],
                            type: v['type'],
                            isPrimary: v['is_primary'] ?? false,
                            licensePlate: v['license_plate'] ?? '',
                          ))
                      .toList();
                }

                // Create driver details if available
                DriverDetails? driverDetails;
                if (driverJson['driver_details'] != null) {
                  driverDetails = DriverDetails(
                    rating: driverJson['driver_details']['rating']?.toDouble(),
                    isAvailable:
                        driverJson['driver_details']['is_available'] ?? false,
                    currentLatitude: driverJson['driver_details']
                            ['current_latitude']
                        ?.toDouble(),
                    currentLongitude: driverJson['driver_details']
                            ['current_longitude']
                        ?.toDouble(),
                    vehicles: vehicles,
                  );
                }

                // Create user entity
                final driver = UserEntity(
                  id: driverJson['id'],
                  email: driverJson['email'],
                  givenName: driverJson['given_name'],
                  familyName: driverJson['family_name'],
                  phoneNumber: driverJson['phone_number'] ?? '',
                  profilePictureUrl: driverJson['profile_picture_url'],
                  roles: List<String>.from(driverJson['roles'] ?? []),
                  driverDetails: driverDetails,
                );

                drivers.add(driver);
              } catch (e) {
                debugPrint('Error parsing driver data: $e');
              }
            }

            return drivers;
          }
        }
      }

      // Cache miss or expired, query the database
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _favoriteDriversCollectionId,
        queries: [
          Query.equal('client_id', clientId),
        ],
      );

      if (response.documents.isEmpty) {
        // Update cache with empty list
        final prefs = await _getPrefs();
        prefs.setString(_getFavoriteDriversCacheKey(clientId), jsonEncode([]));
        prefs.setString(
            _getLastUpdateCacheKey(clientId), DateTime.now().toIso8601String());
        return [];
      }

      // Extract driver IDs
      final driverIds = response.documents
          .map((doc) => doc.data['driver_id']['\$id'] as String)
          .toList();

      // Get driver entities in parallel
      final driverFutures = driverIds.map((id) => _userQueries.getUserById(id));
      final driverResults = await Future.wait(driverFutures);

      // Filter out null results and get the list of drivers
      final drivers = driverResults.whereType<UserEntity>().toList();

      // Update cache
      final prefs = await _getPrefs();

      // Convert drivers to JSON
      final driversJson = drivers
          .map((driver) => {
                'id': driver.id,
                'email': driver.email,
                'given_name': driver.givenName,
                'family_name': driver.familyName,
                'profile_picture_url': driver.profilePictureUrl,
                'phone_number': driver.phoneNumber,
                'roles': driver.roles,
                'driver_details': driver.driverDetails != null
                    ? {
                        'rating': driver.driverDetails!.rating,
                        'is_available': driver.driverDetails!.isAvailable,
                        'current_latitude':
                            driver.driverDetails!.currentLatitude,
                        'current_longitude':
                            driver.driverDetails!.currentLongitude,
                        'vehicles': driver.driverDetails!.vehicles
                            .map((v) => {
                                  'id': v.id,
                                  'license_plate': v.licensePlate,
                                  'brand': v.brand,
                                  'model': v.model,
                                  'type': v.type,
                                  'is_primary': v.isPrimary,
                                })
                            .toList(),
                      }
                    : null,
              })
          .toList();

      // Save to cache
      prefs.setString(
          _getFavoriteDriversCacheKey(clientId), jsonEncode(driversJson));
      prefs.setString(
          _getLastUpdateCacheKey(clientId), DateTime.now().toIso8601String());

      // Also update the favorite status cache
      for (final driver in drivers) {
        prefs.setBool(_getFavoriteStatusCacheKey(clientId, driver.id), true);
      }

      return drivers;
    } on AppwriteException catch (e) {
      debugPrint('Failed to get favorite drivers: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Failed to get favorite drivers: $e');
      return [];
    }
  }

  @override
  Future<List<UserEntity>> getFavoriteClients(String driverId) async {
    try {
      // Get all clients who have marked this driver as favorite
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _favoriteDriversCollectionId,
        queries: [
          Query.equal('driver_id', driverId),
        ],
      );

      if (response.documents.isEmpty) {
        return [];
      }

      // Extract client IDs
      final clientIds = response.documents
          .map((doc) => doc.data['client_id'] as String)
          .toList();

      // Get client entities in parallel
      final clientFutures = clientIds.map((id) => _userQueries.getUserById(id));
      final clientResults = await Future.wait(clientFutures);

      // Filter out null results and return the list of clients
      return clientResults.whereType<UserEntity>().toList();
    } on AppwriteException catch (e) {
      debugPrint('Failed to get favorite clients: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Failed to get favorite clients: $e');
      return [];
    }
  }

  /// Clear all caches for a client
  Future<void> clearCache(String clientId) async {
    try {
      final prefs = await _getPrefs();

      // Get all keys for this client
      final allKeys = prefs.getKeys().where(
          (key) => key.contains(':$clientId:') || key.endsWith(':$clientId'));

      // Remove all matching keys
      for (final key in allKeys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Failed to clear cache: $e');
    }
  }
}
