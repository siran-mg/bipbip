import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

/// Interactor for updating a driver's rating
class UpdateDriverRatingInteractor {
  /// The user repository
  final UserRepository _userRepository;

  /// Creates a new UpdateDriverRatingInteractor
  UpdateDriverRatingInteractor(this._userRepository);

  /// Update a driver's rating
  /// 
  /// Returns the updated user
  Future<UserEntity> execute(String driverId, double rating) async {
    // Get the current user
    final driver = await _userRepository.getUserById(driverId);
    if (driver == null) {
      throw Exception('Driver not found');
    }
    
    // Check if the user is a driver
    if (!driver.isDriver) {
      throw Exception('User is not a driver');
    }
    
    // Create updated driver details with the new rating
    final updatedDriverDetails = driver.driverDetails?.copyWith(
      rating: rating,
    ) ?? DriverDetails(
      rating: rating,
      vehicles: [],
    );
    
    // Update the driver details
    return await _userRepository.updateDriverDetails(
      driverId, 
      updatedDriverDetails,
    );
  }
}
