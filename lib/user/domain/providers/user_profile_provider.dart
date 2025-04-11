import 'package:flutter/foundation.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:ndao/user/domain/interactors/update_user_interactor.dart';

/// Provider for managing user profile data
class UserProfileProvider extends ChangeNotifier {
  final GetCurrentUserInteractor _getCurrentUserInteractor;
  final UpdateUserInteractor _updateUserInteractor;

  // State
  bool _isLoading = false;
  String? _error;
  UserEntity? _user;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserEntity? get user => _user;

  /// Creates a new UserProfileProvider
  UserProfileProvider({
    required GetCurrentUserInteractor getCurrentUserInteractor,
    required UpdateUserInteractor updateUserInteractor,
  })  : _getCurrentUserInteractor = getCurrentUserInteractor,
        _updateUserInteractor = updateUserInteractor;

  /// Load the current user profile
  ///
  /// If [forceRefresh] is true, the cache will be ignored
  Future<void> loadUserProfile({bool forceRefresh = false}) async {
    // If we already have a user and this is not a forced refresh, don't show loading state
    final hasExistingUser = !forceRefresh && _user != null;

    // Only show loading state if we don't have a user or this is a forced refresh
    if (!hasExistingUser) {
      _isLoading = true;
      notifyListeners();
    }

    _error = null;

    try {
      // Get the current user
      final user =
          await _getCurrentUserInteractor.execute(forceRefresh: forceRefresh);

      // Update state
      _user = user;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load user profile: $e';
      notifyListeners();
    }
  }

  /// Update the user profile
  Future<void> updateUserProfile(UserEntity updatedUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update the user
      final user = await _updateUserInteractor.execute(updatedUser);

      // Clear the cache to ensure we get the latest data
      await _getCurrentUserInteractor.clearCache();

      // Update state
      _user = user;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update user profile: $e';
      notifyListeners();
    }
  }

  /// Refresh the user profile
  Future<void> refresh() async {
    await loadUserProfile(forceRefresh: true);
  }

  /// Clear the user profile cache
  Future<void> clearCache() async {
    await _getCurrentUserInteractor.clearCache();
    _user = null;
    notifyListeners();
  }
}
