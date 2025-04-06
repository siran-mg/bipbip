import 'package:appwrite/appwrite.dart';
import 'package:ndao/core/infrastructure/storage/session_storage.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

/// Implementation of AuthRepository using Appwrite
class AppwriteAuthRepository implements AuthRepository {
  final Account _account;
  final UserRepository _userRepository;
  final SessionStorage _sessionStorage;

  /// Creates a new AppwriteAuthRepository with the given account client
  AppwriteAuthRepository(
      this._account, this._userRepository, this._sessionStorage);

  @override
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Check if there's an existing session
      final hasSession = await _sessionStorage.hasSession();

      if (hasSession) {
        try {
          // Try to get the stored session ID
          final sessionId = await _sessionStorage.getSessionId();
          final userId = await _sessionStorage.getUserId();

          if (sessionId != null) {
            // Try to delete the existing session
            await _account.deleteSession(sessionId: sessionId);
          }

          // If we have a userId and the session deletion was successful,
          // we can try to verify if this is the same user trying to log in again
          if (userId != null) {
            try {
              final user = await _userRepository.getUserById(userId);
              if (user != null && user.email == email) {
                // This is the same user, we can create a new session
                final newSession = await _account.createEmailSession(
                  email: email,
                  password: password,
                );

                // Store the new session data
                await _sessionStorage.saveSession(
                    newSession.$id, newSession.userId);
                return newSession.userId;
              }
            } catch (e) {
              // If we can't get the user or there's any other error, continue with normal login flow
              // Just make sure to clear the session storage
              await _sessionStorage.clearSession();
            }
          }
        } catch (e) {
          // If we can't delete the session or there's any other error, clear the session storage
          await _sessionStorage.clearSession();
        }
      }

      // Normal login flow (no existing session or we've cleared it)
      final session = await _account.createEmailSession(
        email: email,
        password: password,
      );

      // Store session data
      await _sessionStorage.saveSession(session.$id, session.userId);

      return session.userId;
    } on AppwriteException catch (e) {
      // If there's an error about active session, try to clear it and retry once
      if (e.message?.contains('session is active') == true) {
        try {
          // Clear any stored session data
          await _sessionStorage.clearSession();

          // Try to get all sessions and delete them
          try {
            final sessions = await _account.listSessions();
            for (final session in sessions.sessions) {
              await _account.deleteSession(sessionId: session.$id);
            }
          } catch (e) {
            // Ignore errors when trying to list/delete sessions
          }

          // Retry login after clearing sessions
          final session = await _account.createEmailSession(
            email: email,
            password: password,
          );

          // Store session data
          await _sessionStorage.saveSession(session.$id, session.userId);

          return session.userId;
        } catch (retryError) {
          throw Exception('Login failed after retry: ${retryError.toString()}');
        }
      }
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
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
      // Check if there's an existing session and clear it
      final hasSession = await _sessionStorage.hasSession();
      if (hasSession) {
        try {
          final sessionId = await _sessionStorage.getSessionId();
          if (sessionId != null) {
            await _account.deleteSession(sessionId: sessionId);
          }
          await _sessionStorage.clearSession();
        } catch (e) {
          // Ignore errors when trying to clear session
          await _sessionStorage.clearSession();
        }
      }

      // Create a new account
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: '$givenName $familyName',
      );

      // Create a user entity
      final userEntity = UserEntity(
        id: user.$id,
        givenName: givenName,
        familyName: familyName,
        email: email,
        phoneNumber: phoneNumber,
        roles: ['client'],
      );

      // Save the user entity
      await _userRepository.saveUser(userEntity);

      return user.$id;
    } on AppwriteException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<String> signUpDriverWithEmailAndPassword(
    String givenName,
    String familyName,
    String email,
    String phoneNumber,
    String password,
  ) async {
    try {
      // Check if there's an existing session and clear it
      final hasSession = await _sessionStorage.hasSession();
      if (hasSession) {
        try {
          final sessionId = await _sessionStorage.getSessionId();
          if (sessionId != null) {
            await _account.deleteSession(sessionId: sessionId);
          }
          await _sessionStorage.clearSession();
        } catch (e) {
          // Ignore errors when trying to clear session
          await _sessionStorage.clearSession();
        }
      }

      // Create a new account
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: '$givenName $familyName',
      );

      // Create a user entity with driver role
      final userEntity = UserEntity(
        id: user.$id,
        givenName: givenName,
        familyName: familyName,
        email: email,
        phoneNumber: phoneNumber,
        roles: ['driver'],
        driverDetails: DriverDetails(),
      );

      // Save the user entity
      await _userRepository.saveUser(userEntity);

      return user.$id;
    } on AppwriteException catch (e) {
      throw Exception('Driver registration failed: ${e.message}');
    } catch (e) {
      throw Exception('Driver registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Get the stored session ID
      final sessionId = await _sessionStorage.getSessionId();

      if (sessionId != null) {
        // Delete the session
        await _account.deleteSession(sessionId: sessionId);
      }

      // Clear stored session data
      await _sessionStorage.clearSession();
    } on AppwriteException catch (e) {
      // Clear session data even if the API call fails
      await _sessionStorage.clearSession();
      throw Exception('Sign out failed: ${e.message}');
    } catch (e) {
      // Clear session data even if the API call fails
      await _sessionStorage.clearSession();
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      // Check if we have a stored user ID
      final userId = await _sessionStorage.getUserId();

      if (userId == null) {
        return null;
      }

      // Get the user entity from the repository using the stored ID
      return await _userRepository.getUserById(userId);
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        // User is not authenticated, clear session data
        await _sessionStorage.clearSession();
        return null;
      }
      throw Exception('Failed to get current user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      // Check if we have a stored session
      final hasSession = await _sessionStorage.hasSession();
      if (!hasSession) {
        return false;
      }

      // Verify that the session is still valid by trying to get the current session
      try {
        final sessionId = await _sessionStorage.getSessionId();
        if (sessionId != null) {
          await _account.getSession(sessionId: sessionId);
          return true;
        }
        return false;
      } catch (e) {
        // If there's an error getting the session, it's likely invalid
        // Clear the stored session data
        await _sessionStorage.clearSession();
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Send password recovery email
      await _account.createRecovery(
        email: email,
        url:
            'https://ndao.app/reset-password', // This URL should be configured in your Appwrite console
      );
    } on AppwriteException catch (e) {
      throw Exception('Failed to send password reset email: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }
}
