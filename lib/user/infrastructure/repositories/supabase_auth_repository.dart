import 'package:ndao/user/domain/entities/client_entity.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Implementation of AuthRepository using Supabase
class SupabaseAuthRepository implements AuthRepository {
  final supabase.SupabaseClient _client;

  /// Creates a new SupabaseAuthRepository with the given client
  SupabaseAuthRepository(this._client);

  @override
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Authentication failed');
      }

      return response.user!.id;
    } catch (e) {
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  @override
  Future<String> signUpWithEmailAndPassword(
    String givenName,
    String familyName,
    String email,
    String phoneNumber,
    String password,
  ) async {
    try {
      // Sign up the user
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'given_name': givenName,
          'family_name': familyName,
          'phone_number': phoneNumber,
        },
      );

      if (response.user == null) {
        throw Exception('Registration failed');
      }

      return response.user!.id;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<ClientEntity?> getCurrentUser() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return null;
    }

    // Get user metadata from Supabase
    final userData = user.userMetadata;

    return ClientEntity(
      id: user.id,
      givenName: userData?['given_name'] ?? '',
      familyName: userData?['family_name'] ?? '',
      email: user.email ?? '',
      phoneNumber: userData?['phone_number'] ?? '',
    );
  }

  @override
  Future<bool> isAuthenticated() async {
    return _client.auth.currentUser != null;
  }
}
