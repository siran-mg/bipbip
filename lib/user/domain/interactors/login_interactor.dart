import 'package:ndao/user/domain/repositories/auth_repository.dart';

/// Interactor for user login
class LoginInteractor {
  final AuthRepository _repository;

  /// Creates a new LoginInteractor with the given repository
  LoginInteractor(this._repository);

  /// Execute the login operation
  /// 
  /// [email] The user's email
  /// [password] The user's password
  /// Returns the user ID if login is successful
  /// Throws an exception if login fails
  Future<String> execute(String email, String password) async {
    // Validate inputs
    _validateInputs(email, password);
    
    // Perform login
    return await _repository.signInWithEmailAndPassword(email, password);
  }
  
  /// Validate login inputs
  /// 
  /// Throws an exception if validation fails
  void _validateInputs(String email, String password) {
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
  
  /// Check if an email is valid
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }
}
