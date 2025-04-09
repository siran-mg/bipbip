import 'package:appwrite/appwrite.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/infrastructure/repositories/queries/user_queries.dart';

/// Class responsible for operations related to driver details
class DriverCommands {
  final Databases _databases;
  final UserQueries _userQueries;

  /// Database ID for users collection
  final String _databaseId;

  /// Collection ID for driver details collection
  final String _driverDetailsCollectionId;

  /// Creates a new DriverCommands with the given database client
  DriverCommands(
    this._databases,
    this._userQueries, {
    String databaseId = 'ndao',
    String driverDetailsCollectionId = 'driver_details',
  })  : _databaseId = databaseId,
        _driverDetailsCollectionId = driverDetailsCollectionId;

  /// Update driver details for a user
  /// 
  /// Returns the updated user
  Future<UserEntity> updateDriverDetails(
      String userId, DriverDetails driverDetails) async {
    try {
      // Get the current user
      final user = await _userQueries.getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user is a driver
      if (!user.isDriver) {
        throw Exception('User is not a driver');
      }

      // Update driver details
      try {
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: userId,
          data: {
            'is_available': driverDetails.isAvailable,
            'current_latitude': driverDetails.currentLatitude,
            'current_longitude': driverDetails.currentLongitude,
            'rating': driverDetails.rating,
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
      } catch (e) {
        // Driver details not found, create them
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: userId,
          data: {
            'user_id': userId,
            'is_available': driverDetails.isAvailable,
            'current_latitude': driverDetails.currentLatitude,
            'current_longitude': driverDetails.currentLongitude,
            'rating': driverDetails.rating,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
      }

      // Return the updated user
      return user.copyWith(driverDetails: driverDetails);
    } on AppwriteException catch (e) {
      throw Exception('Failed to update driver details: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update driver details: ${e.toString()}');
    }
  }

  /// Update a driver's current position
  /// 
  /// Returns the updated user
  Future<UserEntity> updateDriverPosition(
      String userId, double latitude, double longitude) async {
    try {
      // Get the current user
      final user = await _userQueries.getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user is a driver
      if (!user.isDriver) {
        throw Exception('User is not a driver');
      }

      // Update driver position
      try {
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: userId,
          data: {
            'current_latitude': latitude,
            'current_longitude': longitude,
          },
        );
      } catch (e) {
        // Driver details not found, create them with default values
        final driverDetails = DriverDetails(
          isAvailable: false,
          currentLatitude: latitude,
          currentLongitude: longitude,
          vehicles: [],
        );

        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: userId,
          data: {
            'user_id': userId,
            'is_available': driverDetails.isAvailable,
            'current_latitude': driverDetails.currentLatitude,
            'current_longitude': driverDetails.currentLongitude,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
      }

      // Return the updated user
      final updatedDriverDetails = user.driverDetails?.copyWith(
            currentLatitude: latitude,
            currentLongitude: longitude,
          ) ??
          DriverDetails(
            isAvailable: false,
            currentLatitude: latitude,
            currentLongitude: longitude,
            vehicles: [],
          );

      return user.copyWith(driverDetails: updatedDriverDetails);
    } on AppwriteException catch (e) {
      throw Exception('Failed to update driver position: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update driver position: ${e.toString()}');
    }
  }

  /// Update a driver's availability status
  /// 
  /// Returns the updated user
  Future<UserEntity> updateDriverAvailability(
      String userId, bool isAvailable) async {
    try {
      // Get the current user
      final user = await _userQueries.getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user is a driver
      if (!user.isDriver) {
        throw Exception('User is not a driver');
      }

      // Update driver availability
      try {
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: userId,
          data: {
            'is_available': isAvailable,
          },
        );
      } catch (e) {
        // Driver details not found, create them with default values
        final driverDetails = DriverDetails(
          isAvailable: isAvailable,
          vehicles: [],
        );

        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: userId,
          data: {
            'user_id': userId,
            'is_available': driverDetails.isAvailable,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
      }

      // Return the updated user
      final updatedDriverDetails = user.driverDetails?.copyWith(
            isAvailable: isAvailable,
          ) ??
          DriverDetails(
            isAvailable: isAvailable,
            vehicles: [],
          );

      return user.copyWith(driverDetails: updatedDriverDetails);
    } on AppwriteException catch (e) {
      throw Exception('Failed to update driver availability: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update driver availability: ${e.toString()}');
    }
  }
}
