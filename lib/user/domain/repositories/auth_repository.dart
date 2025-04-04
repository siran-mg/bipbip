import 'package:ndao/user/domain/entities/user_entity.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  ///
  /// Returns the user ID if successful
  /// Throws an exception if authentication fails
  Future<String> signInWithEmailAndPassword(String email, String password);

  /// Sign up with email and password
  ///
  /// Returns the user ID if successful
  /// Throws an exception if registration fails
  Future<String> signUpWithEmailAndPassword(
    String givenName,
    String familyName,
    String email,
    String phoneNumber,
    String password,
  );

  /// Sign up a driver with email and password
  ///
  /// Returns the user ID if successful
  /// Throws an exception if registration fails
  Future<String> signUpDriverWithEmailAndPassword(
    String givenName,
    String familyName,
    String email,
    String phoneNumber,
    String password,
  );

  /// Sign out the current user
  Future<void> signOut();

  /// Get the current authenticated user
  ///
  /// Returns the user if authenticated, null otherwise
  Future<UserEntity?> getCurrentUser();

  /// Check if a user is currently authenticated
  ///
  /// Returns true if a user is authenticated, false otherwise
  Future<bool> isAuthenticated();
}
