import 'package:ndao/user/domain/entities/driver_entity.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';
import 'package:ndao/user/domain/repositories/client_repository.dart';
import 'package:ndao/user/domain/repositories/driver_repository.dart';

/// Interactor for driver registration
class RegisterDriverInteractor {
  final AuthRepository _authRepository;
  final DriverRepository _driverRepository;
  final ClientRepository _clientRepository;

  /// Creates a new RegisterDriverInteractor with the given repositories
  RegisterDriverInteractor(
    this._authRepository,
    this._driverRepository,
    this._clientRepository,
  );

  /// Execute the driver registration operation
  ///
  /// [givenName] The driver's first name
  /// [familyName] The driver's last name
  /// [email] The driver's email
  /// [phoneNumber] The driver's phone number
  /// [password] The driver's password
  /// [vehicleInfo] The driver's vehicle information
  /// Returns the driver ID if registration is successful
  /// Throws an exception if registration fails
  Future<String> execute(
    String givenName,
    String familyName,
    String email,
    String phoneNumber,
    String password,
    VehicleInfo vehicleInfo,
  ) async {
    // Validate inputs
    _validateInputs(
        givenName, familyName, email, phoneNumber, password, vehicleInfo);

    try {
      // Register the user with auth repository as a driver
      final userId = await _authRepository.signUpDriverWithEmailAndPassword(
        givenName,
        familyName,
        email,
        phoneNumber,
        password,
      );

      // Create a driver entity
      final driver = DriverEntity(
        id: userId,
        givenName: givenName,
        familyName: familyName,
        email: email,
        phoneNumber: phoneNumber,
        vehicleInfo: vehicleInfo,
        isAvailable: false,
      );

      // Save the driver to the repository
      await _driverRepository.saveDriver(driver);

      // Try to delete the automatically created client record
      // This is optional and won't fail the registration if it doesn't succeed
      try {
        await _clientRepository.deleteClient(userId);
      } catch (e) {
        print('Warning: Could not delete client record for driver: $e');
        // We don't rethrow this error as it's not critical
      }

      return userId;
    } catch (e) {
      throw Exception('Driver registration failed: ${e.toString()}');
    }
  }

  /// Validate registration inputs
  ///
  /// Throws an exception if validation fails
  void _validateInputs(
    String givenName,
    String familyName,
    String email,
    String phoneNumber,
    String password,
    VehicleInfo vehicleInfo,
  ) {
    if (givenName.isEmpty) {
      throw ArgumentError('Given name cannot be empty');
    }

    if (familyName.isEmpty) {
      throw ArgumentError('Family name cannot be empty');
    }

    if (email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }

    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format');
    }

    if (phoneNumber.isEmpty) {
      throw ArgumentError('Phone number cannot be empty');
    }

    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }

    // Validate vehicle information
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
