import 'dart:io';
import 'package:ndao/user/domain/interactors/vehicle_interactor.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

/// Interactor for user registration
class RegisterUserInteractor {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final VehicleInteractor _vehicleInteractor;

  /// Creates a new RegisterUserInteractor with the given repositories
  RegisterUserInteractor(
    this._authRepository,
    this._userRepository,
    this._vehicleInteractor,
  );

  /// Execute the client registration operation
  ///
  /// [givenName] The user's first name
  /// [familyName] The user's last name
  /// [email] The user's email
  /// [phoneNumber] The user's phone number
  /// [password] The user's password
  /// Returns the user ID if registration is successful
  /// Throws an exception if registration fails
  Future<String> registerClient(
    String givenName,
    String familyName,
    String email,
    String phoneNumber,
    String password,
  ) async {
    // Validate inputs
    _validateInputs(givenName, familyName, email, phoneNumber, password);

    try {
      // Register the user with auth repository
      final userId = await _authRepository.signUpWithEmailAndPassword(
        givenName,
        familyName,
        email,
        phoneNumber,
        password,
      );

      // The database trigger should create the user and client records
      // But we can verify that the user exists
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        throw Exception('User was not created properly');
      }

      return userId;
    } catch (e) {
      throw Exception('Client registration failed: ${e.toString()}');
    }
  }

  /// Execute the driver registration operation
  ///
  /// [givenName] The user's first name
  /// [familyName] The user's last name
  /// [email] The user's email
  /// [phoneNumber] The user's phone number
  /// [password] The user's password
  /// [licensePlate] The driver's vehicle license plate
  /// [vehicleModel] The driver's vehicle model
  /// [vehicleBrand] The driver's vehicle brand
  /// [vehicleType] The driver's vehicle type
  /// [profilePhoto] Optional profile photo
  /// [vehiclePhoto] Optional vehicle photo
  /// Returns the user ID if registration is successful
  /// Throws an exception if registration fails
  Future<String> registerDriver(
    String givenName,
    String familyName,
    String email,
    String phoneNumber,
    String password,
    String licensePlate,
    String vehicleModel,
    String vehicleBrand,
    String vehicleType,
    File? profilePhoto,
    File? vehiclePhoto,
  ) async {
    // Validate inputs
    _validateInputs(givenName, familyName, email, phoneNumber, password);
    _validateVehicleInfo(licensePlate, vehicleModel, vehicleBrand);

    try {
      // Register the user with auth repository as a driver
      final userId = await _authRepository.signUpDriverWithEmailAndPassword(
        givenName,
        familyName,
        email,
        phoneNumber,
        password,
      );

      // The database trigger should create the user and driver records
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        throw Exception('User was not created properly');
      }

      // Create the vehicle
      await _vehicleInteractor.createVehicle(
        driverId: userId,
        licensePlate: licensePlate,
        brand: vehicleBrand,
        model: vehicleModel,
        type: vehicleType,
        isPrimary: true,
        photo: vehiclePhoto,
      );

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
  }

  /// Validate vehicle information
  ///
  /// Throws an exception if validation fails
  void _validateVehicleInfo(
    String licensePlate,
    String vehicleModel,
    String vehicleBrand,
  ) {
    if (licensePlate.isEmpty) {
      throw ArgumentError('Vehicle license plate cannot be empty');
    }

    if (vehicleModel.isEmpty) {
      throw ArgumentError('Vehicle model cannot be empty');
    }

    if (vehicleBrand.isEmpty) {
      throw ArgumentError('Vehicle brand cannot be empty');
    }
  }

  /// Check if an email is valid
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }
}
