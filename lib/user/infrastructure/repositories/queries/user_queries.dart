import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:ndao/user/domain/repositories/vehicle_repository.dart';

/// Class responsible for read-only operations related to users
class UserQueries {
  final Databases _databases;
  final VehicleRepository _vehicleRepository;

  /// Database ID for users collection
  final String _databaseId;

  /// Collection ID for users collection
  final String _usersCollectionId;

  /// Collection ID for driver details collection
  final String _driverDetailsCollectionId;

  /// Collection ID for client details collection
  final String _clientDetailsCollectionId;

  /// Collection ID for user roles collection
  final String _userRolesCollectionId;

  /// Cache for available drivers
  List<UserEntity>? _availableDriversCache;

  /// Timestamp of the last cache update
  DateTime? _lastCacheUpdate;

  /// Cache expiration duration (5 minutes)
  static const Duration _cacheExpiration = Duration(minutes: 5);

  /// Creates a new UserQueries with the given database client
  UserQueries(
    this._databases,
    this._vehicleRepository, {
    String databaseId = 'ndao',
    String usersCollectionId = 'users',
    String driverDetailsCollectionId = 'driver_details',
    String clientDetailsCollectionId = 'client_details',
    String userRolesCollectionId = 'user_roles',
  })  : _databaseId = databaseId,
        _usersCollectionId = usersCollectionId,
        _driverDetailsCollectionId = driverDetailsCollectionId,
        _clientDetailsCollectionId = clientDetailsCollectionId,
        _userRolesCollectionId = userRolesCollectionId;

  /// Get a user by ID
  ///
  /// Returns the user if found, null otherwise
  Future<UserEntity?> getUserById(String id) async {
    try {
      // Start all database calls in parallel
      final userFuture = _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _usersCollectionId,
        documentId: id,
      );

      final rolesFuture = _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _userRolesCollectionId,
        queries: [Query.equal('user_id', id), Query.equal('is_active', true)],
      );

      // Wait for the user and roles data in parallel
      final results = await Future.wait([userFuture, rolesFuture]);
      final userDoc = results[0] as Document;
      final rolesResponse = results[1] as DocumentList;

      // Extract roles
      final roles = rolesResponse.documents
          .map((doc) => doc.data['role'] as String)
          .toList();

      // Start fetching driver and client details in parallel if needed
      Future<Document>? driverDocFuture;
      Future<List<VehicleEntity>>? vehiclesFuture;
      Future<Document>? clientDocFuture;

      if (roles.contains('driver')) {
        driverDocFuture = _databases.getDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: id,
        );
        vehiclesFuture = _vehicleRepository.getVehiclesForDriver(id);
      }

      if (roles.contains('client')) {
        clientDocFuture = _databases.getDocument(
          databaseId: _databaseId,
          collectionId: _clientDetailsCollectionId,
          documentId: id,
        );
      }

      // Process driver details
      DriverDetails? driverDetails;
      if (driverDocFuture != null && vehiclesFuture != null) {
        try {
          // Wait for both driver document and vehicles in parallel
          final results = await Future.wait([driverDocFuture, vehiclesFuture]);
          final driverDoc = results[0] as Document;
          final vehicles = results[1] as List<VehicleEntity>;

          driverDetails = DriverDetails(
            isAvailable: driverDoc.data['is_available'] ?? false,
            rating: driverDoc.data['rating']?.toDouble(),
            currentLatitude: driverDoc.data['current_latitude']?.toDouble(),
            currentLongitude: driverDoc.data['current_longitude']?.toDouble(),
            vehicles: vehicles,
          );
        } catch (e) {
          // Driver details not found, create empty driver details
          driverDetails = DriverDetails(vehicles: []);
        }
      }

      // Process client details
      ClientDetails? clientDetails;
      if (clientDocFuture != null) {
        try {
          final clientDoc = await clientDocFuture;
          clientDetails = ClientDetails(
            rating: clientDoc.data['rating']?.toDouble(),
          );
        } catch (e) {
          // Client details not found, create empty client details
          clientDetails = ClientDetails();
        }
      }

      // Create and return the user entity
      return UserEntity(
        id: userDoc.$id,
        givenName: userDoc.data['given_name'],
        familyName: userDoc.data['family_name'],
        email: userDoc.data['email'],
        phoneNumber: userDoc.data['phone_number'],
        profilePictureUrl: userDoc.data['profile_picture_url'],
        roles: roles,
        driverDetails: driverDetails,
        clientDetails: clientDetails,
      );
    } on AppwriteException catch (e) {
      throw Exception('Failed to get user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  /// Get all available drivers
  ///
  /// Returns a list of all users that are drivers and currently available
  /// If [forceRefresh] is true, the cache will be ignored
  Future<List<UserEntity>> getAvailableDrivers(
      {bool forceRefresh = false}) async {
    try {
      // Check if we have a valid cache and forceRefresh is false
      if (!forceRefresh &&
          _availableDriversCache != null &&
          _lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!) < _cacheExpiration) {
        // Return cached data
        return _availableDriversCache!;
      }

      // Get all available drivers
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _driverDetailsCollectionId,
        queries: [Query.equal('is_available', true)],
      );

      if (response.documents.isEmpty) {
        // Update cache with empty list
        _availableDriversCache = [];
        _lastCacheUpdate = DateTime.now();
        return [];
      }

      // Extract all user IDs
      final userIds = response.documents
          .map((doc) => doc.data['user_id']['\$id'] as String)
          .toList();

      // Create a list of futures for getting all users in parallel
      final userFutures = userIds.map((id) => getUserById(id));

      // Wait for all user futures to complete in parallel
      final userResults = await Future.wait(userFutures);

      // Filter out null results and get the list of drivers
      final drivers = userResults.whereType<UserEntity>().toList();

      // Update cache
      _availableDriversCache = drivers;
      _lastCacheUpdate = DateTime.now();

      return drivers;
    } on AppwriteException catch (e) {
      throw Exception('Failed to get available drivers: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get available drivers: ${e.toString()}');
    }
  }

  /// Clear the available drivers cache
  void clearAvailableDriversCache() {
    _availableDriversCache = null;
    _lastCacheUpdate = null;
  }
}
