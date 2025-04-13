import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:ndao/core/infrastructure/storage/session_storage.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

/// Class responsible for write operations related to authentication
class AuthCommands {
  final Account _account;
  final UserRepository _userRepository;
  final SessionStorage _sessionStorage;

  /// Creates a new AuthCommands with the given account client
  AuthCommands(this._account, this._userRepository, this._sessionStorage);

  /// Sign in with email and password
  ///
  /// Returns the user ID if successful
  /// Throws an exception if authentication fails
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

      // Create a session for the new user
      final session = await _account.createEmailSession(
        email: email,
        password: password,
      );

      // Store the session
      await _sessionStorage.saveSession(session.$id, session.userId);

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

      // Create a session for the new user
      final session = await _account.createEmailSession(
        email: email,
        password: password,
      );

      // Store the session
      await _sessionStorage.saveSession(session.$id, session.userId);

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

  /// Sign out the current user
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

  /// Send a password reset email to the user
  ///
  /// [email] The email address of the user
  /// Returns a Future that completes when the email is sent
  /// Throws an exception if the operation fails
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

  /// Sign in with phone number
  ///
  /// Returns the user ID if successful
  /// Throws an exception if authentication fails
  Future<String> signInWithPhoneNumber(String phoneNumber) async {
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

      // Format phone number to ensure it has the + prefix
      final formattedPhoneNumber =
          phoneNumber.startsWith('+') ? phoneNumber : '+$phoneNumber';

      // Create a phone token (sends OTP to the phone number)
      final token = await _account.createPhoneSession(
        userId: ID.unique(),
        phone: formattedPhoneNumber,
      );

      debugPrint('Phone token created for user ID: ${token.userId}');

      // Return the user ID which will be used for verification
      return token.userId;
    } on AppwriteException catch (e) {
      throw Exception('Phone authentication failed: ${e.message}');
    } catch (e) {
      throw Exception('Phone authentication failed: ${e.toString()}');
    }
  }

  /// Verify phone number OTP
  ///
  /// Returns the user ID if successful
  /// Throws an exception if verification fails
  Future<String> verifyPhoneOTP(String userId, String otp) async {
    try {
      // Create a session using the user ID and OTP
      final session = await _account.updatePhoneSession(
        userId: userId,
        secret: otp,
      );

      // Store the session
      await _sessionStorage.saveSession(session.$id, session.userId);

      return session.userId;
    } on AppwriteException catch (e) {
      throw Exception('OTP verification failed: ${e.message}');
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  /// Sign up with phone number
  ///
  /// Returns the user ID if successful
  /// Throws an exception if registration fails
  Future<String> signUpWithPhoneNumber(
    String givenName,
    String familyName,
    String phoneNumber,
    String? email,
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

      // Format phone number to ensure it has the + prefix
      final formattedPhoneNumber =
          phoneNumber.startsWith('+') ? phoneNumber : '+$phoneNumber';

      // Create a phone token (sends OTP to the phone number)
      final token = await _account.createPhoneSession(
        userId: ID.unique(),
        phone: formattedPhoneNumber,
      );

      // Store user information to be saved after verification
      // We'll need to save this information temporarily until the user verifies their phone number
      // This could be done using shared preferences or another storage mechanism
      final userEntity = UserEntity(
        id: token.userId,
        givenName: givenName,
        familyName: familyName,
        email: email,
        phoneNumber: formattedPhoneNumber,
        roles: ['client'],
      );

      // Save the user entity
      await _userRepository.saveUser(userEntity);

      return token.userId;
    } on AppwriteException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Sign up a driver with phone number
  ///
  /// Returns the user ID if successful
  /// Throws an exception if registration fails
  Future<String> signUpDriverWithPhoneNumber(
    String givenName,
    String familyName,
    String phoneNumber,
    String? email,
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

      // Format phone number to ensure it has the + prefix
      final formattedPhoneNumber =
          phoneNumber.startsWith('+') ? phoneNumber : '+$phoneNumber';

      // Create a phone token (sends OTP to the phone number)
      final token = await _account.createPhoneSession(
        userId: ID.unique(),
        phone: formattedPhoneNumber,
      );

      // Store user information to be saved after verification
      final userEntity = UserEntity(
        id: token.userId,
        givenName: givenName,
        familyName: familyName,
        email: email,
        phoneNumber: formattedPhoneNumber,
        roles: ['driver'],
        driverDetails: DriverDetails(),
      );

      // Save the user entity
      await _userRepository.saveUser(userEntity);

      return token.userId;
    } on AppwriteException catch (e) {
      throw Exception('Driver registration failed: ${e.message}');
    } catch (e) {
      throw Exception('Driver registration failed: ${e.toString()}');
    }
  }
}
