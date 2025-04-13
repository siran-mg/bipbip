import 'package:ndao/user/domain/repositories/auth_repository.dart';

/// Interactor for user login
class LoginInteractor {
  final AuthRepository _repository;

  /// Creates a new LoginInteractor with the given repository
  LoginInteractor(this._repository);

  /// Execute the login operation with phone number
  ///
  /// [phoneNumber] The user's phone number
  /// Returns the user ID if login initiation is successful
  /// Throws an exception if login fails
  Future<String> executeWithPhone(String phoneNumber) async {
    // Validate inputs
    _validatePhoneNumber(phoneNumber);

    // Initiate phone login (sends OTP)
    return await _repository.signInWithPhoneNumber(phoneNumber);
  }

  /// Verify the OTP for phone login
  ///
  /// [userId] The user ID returned from executeWithPhone
  /// [otp] The OTP received by the user
  /// Returns the user ID if verification is successful
  /// Throws an exception if verification fails
  Future<String> verifyOTP(String userId, String otp) async {
    // Validate inputs
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    if (otp.isEmpty) {
      throw ArgumentError('OTP cannot be empty');
    }

    // Verify OTP
    return await _repository.verifyPhoneOTP(userId, otp);
  }

  /// Execute the login operation with email and password (legacy method)
  ///
  /// [email] The user's email
  /// [password] The user's password
  /// Returns the user ID if login is successful
  /// Throws an exception if login fails
  Future<String> execute(String email, String password) async {
    // Validate inputs
    _validateEmailAndPassword(email, password);

    // Perform login
    return await _repository.signInWithEmailAndPassword(email, password);
  }

  /// Validate email and password inputs
  ///
  /// Throws an exception if validation fails
  void _validateEmailAndPassword(String email, String password) {
    if (email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }

    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format');
    }

    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }

    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }
  }

  /// Validate phone number input
  ///
  /// Throws an exception if validation fails
  void _validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      throw ArgumentError('Phone number cannot be empty');
    }

    // Remove any non-digit characters for validation
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 10) {
      throw ArgumentError('Phone number must have at least 10 digits');
    }
  }

  /// Check if an email is valid
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }
}
