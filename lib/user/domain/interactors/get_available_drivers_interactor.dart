import 'package:ndao/user/domain/entities/driver_entity.dart';
import 'package:ndao/user/domain/repositories/driver_repository.dart';

/// Interactor for getting available drivers
class GetAvailableDriversInteractor {
  final DriverRepository _repository;

  /// Creates a new GetAvailableDriversInteractor with the given repository
  GetAvailableDriversInteractor(this._repository);

  /// Execute the get available drivers operation
  /// 
  /// Returns a list of available drivers
  /// Throws an exception if the operation fails
  Future<List<DriverEntity>> execute() async {
    try {
      return await _repository.getAvailableDrivers();
    } catch (e) {
      throw Exception('Failed to get available drivers: ${e.toString()}');
    }
  }
}
