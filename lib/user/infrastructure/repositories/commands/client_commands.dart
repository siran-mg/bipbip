import 'package:appwrite/appwrite.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/infrastructure/repositories/queries/user_queries.dart';

/// Class responsible for operations related to client details
class ClientCommands {
  final Databases _databases;
  final UserQueries _userQueries;

  /// Database ID for users collection
  final String _databaseId;

  /// Collection ID for client details collection
  final String _clientDetailsCollectionId;

  /// Creates a new ClientCommands with the given database client
  ClientCommands(
    this._databases,
    this._userQueries, {
    String databaseId = 'ndao',
    String clientDetailsCollectionId = 'client_details',
  })  : _databaseId = databaseId,
        _clientDetailsCollectionId = clientDetailsCollectionId;

  /// Update client details for a user
  ///
  /// Returns the updated user
  Future<UserEntity> updateClientDetails(
      String userId, ClientDetails clientDetails) async {
    try {
      // Get the current user
      final user = await _userQueries.getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user is a client
      if (!user.isClient) {
        throw Exception('User is not a client');
      }

      // Update client details
      try {
        final now = DateTime.now().toIso8601String();
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _clientDetailsCollectionId,
          documentId: userId,
          data: {
            'rating': clientDetails.rating,
            'favorite_driver_ids': clientDetails.favoriteDriverIds.join(','),
            'updated_at': now
          },
        );
      } catch (e) {
        // Client details not found, create them
        final now = DateTime.now().toIso8601String();
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _clientDetailsCollectionId,
          documentId: userId,
          data: {
            'user_id': userId,
            'rating': clientDetails.rating,
            'favorite_driver_ids': clientDetails.favoriteDriverIds.join(','),
            'created_at': now,
            'updated_at': now
          },
        );
      }

      // Return the updated user
      return user.copyWith(clientDetails: clientDetails);
    } on AppwriteException catch (e) {
      throw Exception('Failed to update client details: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update client details: ${e.toString()}');
    }
  }

  /// Add a driver to the user's favorites
  ///
  /// Returns the updated user
  Future<UserEntity> addFavoriteDriver(String userId, String driverId) async {
    try {
      // Get the current user
      final user = await _userQueries.getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user is a client
      if (!user.isClient) {
        throw Exception('User is not a client');
      }

      // Check if the driver exists
      final driver = await _userQueries.getUserById(driverId);
      if (driver == null) {
        throw Exception('Driver not found');
      }

      // Check if the driver is actually a driver
      if (!driver.isDriver) {
        throw Exception('User is not a driver');
      }

      // Get current client details or create new ones
      final currentClientDetails = user.clientDetails ?? ClientDetails();

      // Add driver to favorites if not already there
      if (currentClientDetails.isDriverFavorite(driverId)) {
        return user; // Already a favorite, no need to update
      }

      // Add to favorites
      final updatedClientDetails =
          currentClientDetails.addFavoriteDriver(driverId);

      // Update in database
      return await updateClientDetails(userId, updatedClientDetails);
    } on AppwriteException catch (e) {
      throw Exception('Failed to add favorite driver: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add favorite driver: ${e.toString()}');
    }
  }

  /// Remove a driver from the user's favorites
  ///
  /// Returns the updated user
  Future<UserEntity> removeFavoriteDriver(
      String userId, String driverId) async {
    try {
      // Get the current user
      final user = await _userQueries.getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user is a client
      if (!user.isClient) {
        throw Exception('User is not a client');
      }

      // Get current client details
      final currentClientDetails = user.clientDetails;
      if (currentClientDetails == null ||
          !currentClientDetails.isDriverFavorite(driverId)) {
        return user; // Not a favorite or no client details, no need to update
      }

      // Remove from favorites
      final updatedClientDetails =
          currentClientDetails.removeFavoriteDriver(driverId);

      // Update in database
      return await updateClientDetails(userId, updatedClientDetails);
    } on AppwriteException catch (e) {
      throw Exception('Failed to remove favorite driver: ${e.message}');
    } catch (e) {
      throw Exception('Failed to remove favorite driver: ${e.toString()}');
    }
  }
}
