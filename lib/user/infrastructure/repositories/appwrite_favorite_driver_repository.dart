import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/favorite_driver_repository.dart';
import 'package:ndao/user/infrastructure/repositories/cache/favorite_drivers_cache_repository.dart';
import 'package:ndao/user/infrastructure/repositories/queries/user_queries.dart';

/// Implementation of FavoriteDriverRepository using Appwrite with SQLite caching
class AppwriteFavoriteDriverRepository implements FavoriteDriverRepository {
  final Databases _databases;
  final UserQueries _userQueries;
  final FavoriteDriversCacheRepository _cacheRepository;

  /// Database ID
  final String _databaseId;

  /// Collection ID for favorite drivers
  final String _favoriteDriversCollectionId;

  /// Creates a new AppwriteFavoriteDriverRepository
  AppwriteFavoriteDriverRepository(
    this._databases,
    this._userQueries, {
    String databaseId = 'ndao',
    String favoriteDriversCollectionId = 'favorite_drivers',
    FavoriteDriversCacheRepository? cacheRepository,
  })  : _databaseId = databaseId,
        _favoriteDriversCollectionId = favoriteDriversCollectionId,
        _cacheRepository = cacheRepository ?? FavoriteDriversCacheRepository();

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
      await _cacheRepository.cacheFavoriteStatus(clientId, driverId, true);
      await _cacheRepository.cacheDriver(clientId, driver);

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
        await _cacheRepository.cacheFavoriteStatus(clientId, driverId, false);
        await _cacheRepository.removeDriverFromCache(clientId, driverId);
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
      await _cacheRepository.cacheFavoriteStatus(clientId, driverId, false);
      await _cacheRepository.removeDriverFromCache(clientId, driverId);

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
      final cachedStatus =
          await _cacheRepository.getCachedFavoriteStatus(clientId, driverId);
      if (cachedStatus != null) {
        return cachedStatus;
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
      await _cacheRepository.cacheFavoriteStatus(
          clientId, driverId, isFavorite);

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
      final cachedDrivers =
          await _cacheRepository.getCachedFavoriteDrivers(clientId);
      if (cachedDrivers.isNotEmpty) {
        return cachedDrivers;
      }

      // Cache miss, query the database
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _favoriteDriversCollectionId,
        queries: [
          Query.equal('client_id', clientId),
        ],
      );

      if (response.documents.isEmpty) {
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
      await _cacheRepository.cacheDrivers(clientId, drivers);

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

  /// Clear all caches
  Future<void> clearCache(String clientId) async {
    await _cacheRepository.clearClientCache(clientId);
  }
}
