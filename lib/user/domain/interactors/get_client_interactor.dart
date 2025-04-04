import 'package:ndao/user/domain/entities/client_entity.dart';
import 'package:ndao/user/domain/repositories/client_repository.dart';

/// Interactor for getting a client by ID
class GetClientInteractor {
  final ClientRepository _repository;

  /// Creates a new GetClientInteractor with the given repository
  GetClientInteractor(this._repository);

  /// Execute the get client operation
  /// 
  /// [id] The ID of the client to get
  /// Returns the client if found, null otherwise
  /// Throws an exception if the operation fails
  Future<ClientEntity?> execute(String id) async {
    try {
      return await _repository.getClientById(id);
    } catch (e) {
      throw Exception('Failed to get client: ${e.toString()}');
    }
  }
}
