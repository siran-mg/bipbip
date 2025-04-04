import 'package:ndao/user/domain/entities/driver_entity.dart';
import 'package:ndao/user/domain/repositories/driver_repository.dart';

/// Interactor for saving a driver
class SaveDriverInteractor {
  final DriverRepository _repository;

  /// Creates a new SaveDriverInteractor with the given repository
  SaveDriverInteractor(this._repository);

  /// Execute the save driver operation
  ///
  /// [driver] The driver to save
  /// Returns the saved driver with any server-generated fields
  /// Throws an exception if the save operation fails
  Future<DriverEntity> execute(DriverEntity driver) async {
    // Validate driver data before saving
    _validateDriver(driver);

    // Save the driver using the repository
    return await _repository.saveDriver(driver);
  }

  /// Validate driver data
  ///
  /// Throws an exception if validation fails
  void _validateDriver(DriverEntity driver) {
    if (driver.givenName.isEmpty) {
      throw ArgumentError('Driver given name cannot be empty');
    }

    if (driver.familyName.isEmpty) {
      throw ArgumentError('Driver family name cannot be empty');
    }

    if (driver.email.isEmpty) {
      throw ArgumentError('Driver email cannot be empty');
    }

    if (!_isValidEmail(driver.email)) {
      throw ArgumentError('Invalid email format');
    }

    if (driver.phoneNumber.isEmpty) {
      throw ArgumentError('Driver phone number cannot be empty');
    }

    // Validate vehicle information
    _validateVehicleInfo(driver.vehicleInfo);
  }

  /// Validate vehicle information
  ///
  /// Throws an exception if validation fails
  void _validateVehicleInfo(VehicleInfo vehicleInfo) {
    if (vehicleInfo.licensePlate.isEmpty) {
      throw ArgumentError('Vehicle license plate cannot be empty');
    }

    if (vehicleInfo.model.isEmpty) {
      throw ArgumentError('Vehicle model cannot be empty');
    }

    if (vehicleInfo.color.isEmpty) {
      throw ArgumentError('Vehicle color cannot be empty');
    }
  }

  /// Check if an email is valid
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }
}
