import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

/// Interactor for updating user information
class UpdateUserInteractor {
  /// The user repository
  final UserRepository _userRepository;

  /// Creates a new UpdateUserInteractor
  UpdateUserInteractor(this._userRepository);

  /// Update user information
  /// 
  /// Returns the updated user
  Future<UserEntity> execute(UserEntity user) async {
    return await _userRepository.updateUser(user);
  }
}
