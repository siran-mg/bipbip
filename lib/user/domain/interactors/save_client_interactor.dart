import 'package:ndao/user/domain/entities/client_entity.dart';
import 'package:ndao/user/domain/repositories/client_repository.dart';

/// Interactor for saving a client
class SaveClientInteractor {
  final ClientRepository _repository;

  /// Creates a new SaveClientInteractor with the given repository
  SaveClientInteractor(this._repository);

  /// Execute the save client operation
  ///
  /// [client] The client to save
  /// Returns the saved client with any server-generated fields
  /// Throws an exception if the save operation fails
  Future<ClientEntity> execute(ClientEntity client) async {
    // Validate client data before saving
    _validateClient(client);

    // Save the client using the repository
    return await _repository.saveClient(client);
  }

  /// Validate client data
  ///
  /// Throws an exception if validation fails
  void _validateClient(ClientEntity client) {
    if (client.givenName.isEmpty) {
      throw ArgumentError('Client given name cannot be empty');
    }

    if (client.familyName.isEmpty) {
      throw ArgumentError('Client family name cannot be empty');
    }

    if (client.email.isEmpty) {
      throw ArgumentError('Client email cannot be empty');
    }

    if (!_isValidEmail(client.email)) {
      throw ArgumentError('Invalid email format');
    }

    if (client.phoneNumber.isEmpty) {
      throw ArgumentError('Client phone number cannot be empty');
    }
  }

  /// Check if an email is valid
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }
}
