import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:ndao/core/infrastructure/storage/session_storage.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

/// Class responsible for read-only operations related to authentication
class AuthQueries {
  final Account _account;
  final UserRepository _userRepository;
  final SessionStorage _sessionStorage;

  /// Cache for the current user
  UserEntity? _currentUserCache;

  /// Timestamp of the last cache update
  DateTime? _lastCacheUpdate;

  /// Cache expiration duration (5 minutes)
  static const Duration _cacheExpiration = Duration(minutes: 5);

  /// Creates a new AuthQueries with the given account client
  AuthQueries(this._account, this._userRepository, this._sessionStorage);

  /// Get the current authenticated user
  ///
  /// Returns the user if authenticated, null otherwise
  /// If [forceRefresh] is true, the cache will be ignored
  Future<UserEntity?> getCurrentUser({bool forceRefresh = false}) async {
    try {
      // Check if we have a valid cache and forceRefresh is false
      if (!forceRefresh &&
          _currentUserCache != null &&
          _lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!) < _cacheExpiration) {
        // Return cached user
        return _currentUserCache;
      }

      // Check if we have a stored user ID
      final userId = await _sessionStorage.getUserId();

      if (userId == null) {
        // Clear cache since there's no user ID
        _currentUserCache = null;
        _lastCacheUpdate = null;
        return null;
      }

      // Get the user entity from the repository using the stored ID
      final user = await _userRepository.getUserById(userId);

      // Update cache
      _currentUserCache = user;
      _lastCacheUpdate = DateTime.now();

      return user;
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        // User is not authenticated, clear session data and cache
        await _sessionStorage.clearSession();
        _currentUserCache = null;
        _lastCacheUpdate = null;
        return null;
      }
      throw Exception('Failed to get current user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  /// Check if a user is currently authenticated
  ///
  /// Returns true if a user is authenticated, false otherwise
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

  /// Clear the current user cache
  void clearCurrentUserCache() {
    _currentUserCache = null;
    _lastCacheUpdate = null;
  }
}
