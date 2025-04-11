import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:ndao/core/infrastructure/storage/session_storage.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:ndao/user/infrastructure/repositories/cache/user_cache_repository.dart';

/// Class responsible for read-only operations related to authentication
class AuthQueries {
  final Account _account;
  final UserRepository _userRepository;
  final SessionStorage _sessionStorage;
  final UserCacheRepository _userCacheRepository;

  /// Creates a new AuthQueries with the given account client
  AuthQueries(this._account, this._userRepository, this._sessionStorage)
      : _userCacheRepository = UserCacheRepository(cacheExpirationMinutes: 30);

  /// Get the current authenticated user
  ///
  /// Returns the user if authenticated, null otherwise
  /// If [forceRefresh] is true, the cache will be ignored
  Future<UserEntity?> getCurrentUser({bool forceRefresh = false}) async {
    try {
      // Check if we can use the cache
      if (!forceRefresh) {
        // Try to get user from cache
        final cachedUser = await _userCacheRepository.getCachedCurrentUser();
        if (cachedUser != null) {
          debugPrint('Returning cached user: ${cachedUser.id}');
          return cachedUser;
        }
      }

      // Check if we have a stored user ID
      final userId = await _sessionStorage.getUserId();

      if (userId == null) {
        // Clear cache since there's no user ID
        await _userCacheRepository.clearCache();
        return null;
      }

      // Get the user entity from the repository using the stored ID
      final user = await _userRepository.getUserById(userId);

      // Update cache if user is not null
      if (user != null) {
        await _userCacheRepository.cacheCurrentUser(user);
        debugPrint('User cached: ${user.id}');
      }

      return user;
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        // User is not authenticated, clear session data and cache
        await _sessionStorage.clearSession();
        await _userCacheRepository.clearCache();
        return null;
      }
      throw Exception('Failed to get current user: ${e.message}');
    } catch (e) {
      debugPrint('Error getting current user: $e');
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
  Future<void> clearCurrentUserCache() async {
    await _userCacheRepository.clearCache();
    debugPrint('Current user cache cleared');
  }
}
