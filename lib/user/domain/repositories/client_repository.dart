import 'package:ndao/user/domain/entities/client_entity.dart';

/// Repository interface for client-related operations
abstract class ClientRepository {
  /// Save a client to the data source
  /// 
  /// Returns the saved client with any server-generated fields (like ID)
  /// Throws an exception if the save operation fails
  Future<ClientEntity> saveClient(ClientEntity client);
  
  /// Get a client by ID
  /// 
  /// Returns the client if found, null otherwise
  Future<ClientEntity?> getClientById(String id);
  
  /// Update an existing client
  /// 
  /// Returns the updated client
  /// Throws an exception if the update operation fails or the client doesn't exist
  Future<ClientEntity> updateClient(ClientEntity client);
  
  /// Delete a client by ID
  /// 
  /// Returns true if the client was successfully deleted, false otherwise
  Future<bool> deleteClient(String id);
}
