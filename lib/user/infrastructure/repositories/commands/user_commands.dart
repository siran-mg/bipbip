import 'package:appwrite/appwrite.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';

/// Class responsible for write operations related to users
class UserCommands {
  final Databases _databases;

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

  /// Creates a new UserCommands with the given database client
  UserCommands(
    this._databases, {
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

  /// Save a user to the data source
  /// 
  /// Returns the saved user with any server-generated fields
  /// Throws an exception if the save operation fails
  Future<UserEntity> saveUser(UserEntity user) async {
    try {
      final now = DateTime.now().toIso8601String();
      // Save the user
      await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _usersCollectionId,
        documentId: user.id,
        data: {
          'given_name': user.givenName,
          'family_name': user.familyName,
          'email': user.email,
          'phone_number': user.phoneNumber,
          'profile_picture_url': user.profilePictureUrl,
          'created_at': now,
          'updated_at': now,
        },
      );

      // Save user roles
      for (final role in user.roles) {
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _userRolesCollectionId,
          documentId: ID.unique(),
          data: {
            'user_id': user.id,
            'role': role,
            'is_active': true,
            'created_at': now,
            'updated_at': now,
          },
        );
      }

      // Save driver details if the user is a driver
      if (user.isDriver && user.driverDetails != null) {
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: user.id,
          data: {
            'user_id': user.id,
            'is_available': user.driverDetails!.isAvailable,
            'current_latitude': user.driverDetails!.currentLatitude,
            'current_longitude': user.driverDetails!.currentLongitude,
            'rating': user.driverDetails!.rating,
            'created_at': now,
            'updated_at': now,
          },
        );
      }

      // Save client details if the user is a client
      if (user.isClient && user.clientDetails != null) {
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _clientDetailsCollectionId,
          documentId: user.id,
          data: {
            'user_id': user.id,
            'rating': user.clientDetails!.rating,
            'created_at': now,
            'updated_at': now,
          },
        );
      }

      return user;
    } on AppwriteException catch (e) {
      throw Exception('Failed to save user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to save user: ${e.toString()}');
    }
  }

  /// Update an existing user
  /// 
  /// Returns the updated user
  /// Throws an exception if the update operation fails or the user doesn't exist
  Future<UserEntity> updateUser(UserEntity user) async {
    try {
      // Update the user
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _usersCollectionId,
        documentId: user.id,
        data: {
          'given_name': user.givenName,
          'family_name': user.familyName,
          'email': user.email,
          'phone_number': user.phoneNumber,
          'profile_picture_url': user.profilePictureUrl,
        },
      );

      // Update driver details if the user is a driver
      if (user.isDriver && user.driverDetails != null) {
        try {
          await _databases.updateDocument(
            databaseId: _databaseId,
            collectionId: _driverDetailsCollectionId,
            documentId: user.id,
            data: {
              'is_available': user.driverDetails!.isAvailable,
              'current_latitude': user.driverDetails!.currentLatitude,
              'current_longitude': user.driverDetails!.currentLongitude,
              'rating': user.driverDetails!.rating,
              'updated_at': DateTime.now().toIso8601String(),
            },
          );
        } catch (e) {
          // Driver details not found, create them
          await _databases.createDocument(
            databaseId: _databaseId,
            collectionId: _driverDetailsCollectionId,
            documentId: user.id,
            data: {
              'user_id': user.id,
              'is_available': user.driverDetails!.isAvailable,
              'current_latitude': user.driverDetails!.currentLatitude,
              'current_longitude': user.driverDetails!.currentLongitude,
              'rating': user.driverDetails!.rating,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            },
          );
        }
      }

      // Update client details if the user is a client
      if (user.isClient && user.clientDetails != null) {
        try {
          await _databases.updateDocument(
            databaseId: _databaseId,
            collectionId: _clientDetailsCollectionId,
            documentId: user.id,
            data: {
              'rating': user.clientDetails!.rating,
              'updated_at': DateTime.now().toIso8601String(),
            },
          );
        } catch (e) {
          // Client details not found, create them
          final now = DateTime.now().toIso8601String();
          await _databases.createDocument(
            databaseId: _databaseId,
            collectionId: _clientDetailsCollectionId,
            documentId: user.id,
            data: {
              'user_id': user.id,
              'rating': user.clientDetails!.rating,
              'created_at': now,
              'updated_at': now
            },
          );
        }
      }

      return user;
    } on AppwriteException catch (e) {
      throw Exception('Failed to update user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  /// Delete a user by ID
  /// 
  /// Returns true if the user was successfully deleted, false otherwise
  Future<bool> deleteUser(String id) async {
    try {
      // Delete the user
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: _usersCollectionId,
        documentId: id,
      );

      // Delete user roles
      final rolesResponse = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _userRolesCollectionId,
        queries: [Query.equal('user_id', id)],
      );

      for (final role in rolesResponse.documents) {
        await _databases.deleteDocument(
          databaseId: _databaseId,
          collectionId: _userRolesCollectionId,
          documentId: role.$id,
        );
      }

      // Delete driver details
      try {
        await _databases.deleteDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: id,
        );
      } catch (e) {
        // Ignore if driver details don't exist
      }

      // Delete client details
      try {
        await _databases.deleteDocument(
          databaseId: _databaseId,
          collectionId: _clientDetailsCollectionId,
          documentId: id,
        );
      } catch (e) {
        // Ignore if client details don't exist
      }

      return true;
    } on AppwriteException catch (e) {
      throw Exception('Failed to delete user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }
}
