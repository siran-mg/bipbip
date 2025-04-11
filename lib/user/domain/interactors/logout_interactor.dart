import 'package:ndao/user/domain/repositories/auth_repository.dart';

/// Interactor for user logout
class LogoutInteractor {
  final AuthRepository _repository;

  /// Creates a new LogoutInteractor with the given repository
  LogoutInteractor(this._repository);

  /// Execute the logout operation
  ///
  /// Returns a Future that completes when the logout is successful
  /// Throws an exception if logout fails
  Future<void> execute() async {
    // Sign out and clear cache
    await _repository.signOut();
    await _repository.clearCurrentUserCache();
  }
}
