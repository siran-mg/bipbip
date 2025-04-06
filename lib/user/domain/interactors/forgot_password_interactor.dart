import 'package:ndao/user/domain/repositories/auth_repository.dart';

/// Interactor for password reset
class ForgotPasswordInteractor {
  final AuthRepository _repository;

  /// Creates a new ForgotPasswordInteractor with the given repository
  ForgotPasswordInteractor(this._repository);

  /// Execute the password reset operation
  /// 
  /// [email] The user's email
  /// Returns a Future that completes when the reset email is sent
  /// Throws an exception if the operation fails
  Future<void> execute(String email) async {
    // Validate input
    _validateInput(email);
    
    // Send password reset email
    await _repository.sendPasswordResetEmail(email);
  }

  /// Validate email input
  /// 
  /// Throws an exception if validation fails
  void _validateInput(String email) {
    if (email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }

    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format');
    }
  }

  /// Check if an email is valid
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }
}
