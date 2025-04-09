import 'package:appwrite/appwrite.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/infrastructure/repositories/queries/user_queries.dart';

/// Class responsible for operations related to user roles
class UserRoleCommands {
  final Databases _databases;
  final UserQueries _userQueries;

  /// Database ID for users collection
  final String _databaseId;

  /// Collection ID for user roles collection
  final String _userRolesCollectionId;

  /// Collection ID for driver details collection
  final String _driverDetailsCollectionId;

  /// Collection ID for client details collection
  final String _clientDetailsCollectionId;

  /// Creates a new UserRoleCommands with the given database client
  UserRoleCommands(
    this._databases,
    this._userQueries, {
    String databaseId = 'ndao',
    String userRolesCollectionId = 'user_roles',
    String driverDetailsCollectionId = 'driver_details',
    String clientDetailsCollectionId = 'client_details',
  })  : _databaseId = databaseId,
        _userRolesCollectionId = userRolesCollectionId,
        _driverDetailsCollectionId = driverDetailsCollectionId,
        _clientDetailsCollectionId = clientDetailsCollectionId;

  /// Add a role to a user
  /// 
  /// Returns the updated user
  Future<UserEntity> addRole(String userId, String role) async {
    try {
      // Get the current user
      final user = await _userQueries.getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user already has the role
      if (user.roles.contains(role)) {
        return user;
      }

      // Add the role
      await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _userRolesCollectionId,
        documentId: ID.unique(),
        data: {
          'user_id': userId,
          'role': role,
          'is_active': true,
        },
      );

      // If adding driver role, add placeholder driver details
      if (role == 'driver' && user.driverDetails == null) {
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: userId,
          data: {
            'user_id': userId,
            'is_available': false,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
      }

      // If adding client role, add placeholder client details
      if (role == 'client' && user.clientDetails == null) {
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _clientDetailsCollectionId,
          documentId: userId,
          data: {
            'user_id': userId,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
      }

      // Return the updated user
      return user.addRole(role);
    } on AppwriteException catch (e) {
      throw Exception('Failed to add role: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add role: ${e.toString()}');
    }
  }

  /// Remove a role from a user
  /// 
  /// Returns the updated user
  Future<UserEntity> removeRole(String userId, String role) async {
    try {
      // Get the current user
      final user = await _userQueries.getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user has the role
      if (!user.roles.contains(role)) {
        return user;
      }

      // Find and update the role document
      final rolesResponse = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _userRolesCollectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.equal('role', role),
          Query.equal('is_active', true),
        ],
      );

      for (final roleDoc in rolesResponse.documents) {
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _userRolesCollectionId,
          documentId: roleDoc.$id,
          data: {
            'is_active': false,
          },
        );
      }

      // Return the updated user
      return user.removeRole(role);
    } on AppwriteException catch (e) {
      throw Exception('Failed to remove role: ${e.message}');
    } catch (e) {
      throw Exception('Failed to remove role: ${e.toString()}');
    }
  }
}
