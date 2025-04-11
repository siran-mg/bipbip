import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';

/// Interactor for getting the current authenticated user
class GetCurrentUserInteractor {
  final AuthRepository _repository;

  /// Creates a new GetCurrentUserInteractor with the given repository
  GetCurrentUserInteractor(this._repository);

  /// Execute the get current user operation
  ///
  /// Returns the current user if authenticated, null otherwise
  /// If [forceRefresh] is true, the cache will be ignored
  Future<UserEntity?> execute({bool forceRefresh = false}) async {
    return await _repository.getCurrentUser(forceRefresh: forceRefresh);
  }

  /// Clear the current user cache
  Future<void> clearCache() async {
    await _repository.clearCurrentUserCache();
  }
}
