import 'package:ndao/user/domain/entities/client_entity.dart';
import 'package:ndao/user/domain/repositories/client_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Implementation of ClientRepository using Supabase
class SupabaseClientRepository implements ClientRepository {
  final supabase.SupabaseClient _client;
  final String _tableName = 'clients';

  /// Creates a new SupabaseClientRepository with the given client
  SupabaseClientRepository(this._client);

  @override
  Future<ClientEntity> saveClient(ClientEntity client) async {
    try {
      // Check if the client already exists
      if (client.id.isNotEmpty) {
        return updateClient(client);
      }

      // Insert the client into the database
      final response = await _client
          .from(_tableName)
          .insert({
            'given_name': client.givenName,
            'family_name': client.familyName,
            'email': client.email,
            'phone_number': client.phoneNumber,
            'profile_picture_url': client.profilePictureUrl,
            'rating': client.rating,
          })
          .select()
          .single();

      // Return the client with the generated ID
      return ClientEntity(
        id: response['id'],
        givenName: response['given_name'],
        familyName: response['family_name'],
        email: response['email'],
        phoneNumber: response['phone_number'],
        profilePictureUrl: response['profile_picture_url'],
        rating: response['rating'],
      );
    } catch (e) {
      throw Exception('Failed to save client: ${e.toString()}');
    }
  }

  @override
  Future<ClientEntity?> getClientById(String id) async {
    try {
      final response =
          await _client.from(_tableName).select().eq('id', id).maybeSingle();

      if (response == null) {
        return null;
      }

      return ClientEntity(
        id: response['id'],
        givenName: response['given_name'],
        familyName: response['family_name'],
        email: response['email'],
        phoneNumber: response['phone_number'],
        profilePictureUrl: response['profile_picture_url'],
        rating: response['rating'],
      );
    } catch (e) {
      throw Exception('Failed to get client: ${e.toString()}');
    }
  }

  @override
  Future<ClientEntity> updateClient(ClientEntity client) async {
    try {
      await _client.from(_tableName).update({
        'given_name': client.givenName,
        'family_name': client.familyName,
        'email': client.email,
        'phone_number': client.phoneNumber,
        'profile_picture_url': client.profilePictureUrl,
        'rating': client.rating,
      }).eq('id', client.id);

      return client;
    } catch (e) {
      throw Exception('Failed to update client: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteClient(String id) async {
    try {
      await _client.from(_tableName).delete().eq('id', id);
      return true;
    } catch (e) {
      throw Exception('Failed to delete client: ${e.toString()}');
    }
  }
}
