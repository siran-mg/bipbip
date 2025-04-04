import 'package:ndao/user/domain/repositories/auth_repository.dart';

/// Interactor for user registration
class RegisterInteractor {
  final AuthRepository _repository;

  /// Creates a new RegisterInteractor with the given repository
  RegisterInteractor(this._repository);

  /// Execute the registration operation
  ///
  /// [givenName] The user's first name
  /// [familyName] The user's last name
  /// [email] The user's email
  /// [phoneNumber] The user's phone number
  /// [password] The user's password
  /// Returns the user ID if registration is successful
  /// Throws an exception if registration fails
  Future<String> execute(
    String givenName,
    String familyName,
    String email,
    String phoneNumber,
    String password,
  ) async {
    // Validate inputs
    _validateInputs(givenName, familyName, email, phoneNumber, password);

    // Perform registration
    return await _repository.signUpWithEmailAndPassword(
      givenName,
      familyName,
      email,
      phoneNumber,
      password,
    );
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

  /// Check if an email is valid
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }
}
