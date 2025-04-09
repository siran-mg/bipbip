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
          data: {'rating': clientDetails.rating, 'updated_at': now},
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
}
