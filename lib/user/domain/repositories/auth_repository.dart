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
  /// If [forceRefresh] is true, the cache will be ignored
  Future<UserEntity?> getCurrentUser({bool forceRefresh});

  /// Clear the current user cache
  Future<void> clearCurrentUserCache();

  /// Check if a user is currently authenticated
  ///
  /// Returns true if a user is authenticated, false otherwise
  Future<bool> isAuthenticated();

  /// Send a password reset email to the user
  ///
  /// [email] The email address of the user
  /// Returns a Future that completes when the email is sent
  /// Throws an exception if the operation fails
  Future<void> sendPasswordResetEmail(String email);
}
