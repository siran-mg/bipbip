import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ndao/core/infrastructure/database/database_helper.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:sqflite/sqflite.dart';

/// Repository for caching favorite drivers data in SQLite
class FavoriteDriversCacheRepository {
  final DatabaseHelper _databaseHelper;

  /// Cache expiration time in minutes
  final int _cacheExpirationMinutes;

  /// Creates a new FavoriteDriversCacheRepository
  FavoriteDriversCacheRepository({
    DatabaseHelper? databaseHelper,
    int cacheExpirationMinutes = 60, // Default to 1 hour
  })  : _databaseHelper = databaseHelper ?? DatabaseHelper(),
        _cacheExpirationMinutes = cacheExpirationMinutes;

  /// Save a driver to the favorites cache
  Future<void> cacheDriver(String clientId, UserEntity driver) async {
    try {
      final db = await _databaseHelper.database;
      final now = DateTime.now().toIso8601String();

      // Convert driver entity to JSON
      final driverJson = jsonEncode({
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
      });

      // Insert or replace in the cache
      await db.insert(
        'favorite_drivers_cache',
        {
          'client_id': clientId,
          'driver_id': driver.id,
          'driver_data': driverJson,
          'created_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error caching driver: $e');
    }
  }

  /// Save multiple drivers to the favorites cache
  Future<void> cacheDrivers(String clientId, List<UserEntity> drivers) async {
    try {
      final db = await _databaseHelper.database;
      final now = DateTime.now().toIso8601String();
      final batch = db.batch();

      for (final driver in drivers) {
        // Convert driver entity to JSON
        final driverJson = jsonEncode({
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
        });

        // Add to batch
        batch.insert(
          'favorite_drivers_cache',
          {
            'client_id': clientId,
            'driver_id': driver.id,
            'driver_data': driverJson,
            'created_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Update cache metadata
      batch.insert(
        'cache_metadata',
        {
          'cache_key': 'favorite_drivers:$clientId',
          'last_updated': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Execute batch
      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Error caching drivers: $e');
    }
  }

  /// Get all favorite drivers from cache
  Future<List<UserEntity>> getCachedFavoriteDrivers(String clientId) async {
    try {
      final db = await _databaseHelper.database;

      // Check if cache is valid
      if (!await _isCacheValid(clientId, 'favorite_drivers:$clientId')) {
        return [];
      }

      // Get all drivers for this client
      final results = await db.query(
        'favorite_drivers_cache',
        where: 'client_id = ?',
        whereArgs: [clientId],
      );

      if (results.isEmpty) {
        return [];
      }

      // Convert to driver entities
      final drivers = <UserEntity>[];

      for (final row in results) {
        try {
          final driverData = jsonDecode(row['driver_data'] as String);

          // Parse vehicles if available
          List<VehicleEntity> vehicles = [];
          if (driverData['driver_details'] != null &&
              driverData['driver_details']['vehicles'] != null) {
            final vehiclesJson =
                driverData['driver_details']['vehicles'] as List;
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
          if (driverData['driver_details'] != null) {
            driverDetails = DriverDetails(
              rating: driverData['driver_details']['rating']?.toDouble(),
              isAvailable:
                  driverData['driver_details']['is_available'] ?? false,
              currentLatitude:
                  driverData['driver_details']['current_latitude']?.toDouble(),
              currentLongitude:
                  driverData['driver_details']['current_longitude']?.toDouble(),
              vehicles: vehicles,
            );
          }

          // Create user entity
          final driver = UserEntity(
            id: driverData['id'],
            email: driverData['email'],
            givenName: driverData['given_name'],
            familyName: driverData['family_name'],
            phoneNumber: driverData['phone_number'] ?? '',
            profilePictureUrl: driverData['profile_picture_url'],
            roles: List<String>.from(driverData['roles'] ?? []),
            driverDetails: driverDetails,
          );

          drivers.add(driver);
        } catch (e) {
          debugPrint('Error parsing driver data: $e');
        }
      }

      return drivers;
    } catch (e) {
      debugPrint('Error getting cached favorite drivers: $e');
      return [];
    }
  }

  /// Remove a driver from the favorites cache
  Future<void> removeDriverFromCache(String clientId, String driverId) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'favorite_drivers_cache',
        where: 'client_id = ? AND driver_id = ?',
        whereArgs: [clientId, driverId],
      );
    } catch (e) {
      debugPrint('Error removing driver from cache: $e');
    }
  }

  /// Cache the favorite status of a driver
  Future<void> cacheFavoriteStatus(
      String clientId, String driverId, bool isFavorite) async {
    try {
      final db = await _databaseHelper.database;
      final now = DateTime.now().toIso8601String();

      await db.insert(
        'favorite_status_cache',
        {
          'client_id': clientId,
          'driver_id': driverId,
          'is_favorite': isFavorite ? 1 : 0,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error caching favorite status: $e');
    }
  }

  /// Get the cached favorite status of a driver
  Future<bool?> getCachedFavoriteStatus(
      String clientId, String driverId) async {
    try {
      final db = await _databaseHelper.database;

      final results = await db.query(
        'favorite_status_cache',
        where: 'client_id = ? AND driver_id = ?',
        whereArgs: [clientId, driverId],
      );

      if (results.isEmpty) {
        return null; // No cached status
      }

      // Check if cache is valid
      final updatedAt = DateTime.parse(results.first['updated_at'] as String);
      final now = DateTime.now();
      if (now.difference(updatedAt).inMinutes > _cacheExpirationMinutes) {
        return null; // Cache expired
      }

      return results.first['is_favorite'] == 1;
    } catch (e) {
      debugPrint('Error getting cached favorite status: $e');
      return null;
    }
  }

  /// Clear all favorite drivers cache for a client
  Future<void> clearClientCache(String clientId) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'favorite_drivers_cache',
        where: 'client_id = ?',
        whereArgs: [clientId],
      );
      await db.delete(
        'favorite_status_cache',
        where: 'client_id = ?',
        whereArgs: [clientId],
      );
      await db.delete(
        'cache_metadata',
        where: 'cache_key = ?',
        whereArgs: ['favorite_drivers:$clientId'],
      );
    } catch (e) {
      debugPrint('Error clearing client cache: $e');
    }
  }

  /// Check if the cache is valid
  Future<bool> _isCacheValid(String clientId, String cacheKey) async {
    try {
      final db = await _databaseHelper.database;
      final results = await db.query(
        'cache_metadata',
        where: 'cache_key = ?',
        whereArgs: [cacheKey],
      );

      if (results.isEmpty) {
        return false;
      }

      final lastUpdated =
          DateTime.parse(results.first['last_updated'] as String);
      final now = DateTime.now();
      return now.difference(lastUpdated).inMinutes <= _cacheExpirationMinutes;
    } catch (e) {
      debugPrint('Error checking cache validity: $e');
      return false;
    }
  }
}
