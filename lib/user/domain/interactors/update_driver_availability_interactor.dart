import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

/// Interactor for updating a driver's availability status
class UpdateDriverAvailabilityInteractor {
  /// The user repository
  final UserRepository _userRepository;

  /// Creates a new UpdateDriverAvailabilityInteractor
  UpdateDriverAvailabilityInteractor(this._userRepository);

  /// Update a driver's availability status
  /// 
  /// Returns the updated user
  Future<UserEntity> execute(String userId, bool isAvailable) async {
    return await _userRepository.updateDriverAvailability(userId, isAvailable);
  }
}
