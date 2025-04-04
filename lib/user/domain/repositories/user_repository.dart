import 'package:ndao/user/domain/entities/user_entity.dart';

/// Repository interface for user-related operations
abstract class UserRepository {
  /// Save a user to the data source
  /// 
  /// Returns the saved user with any server-generated fields
  /// Throws an exception if the save operation fails
  Future<UserEntity> saveUser(UserEntity user);
  
  /// Get a user by ID
  /// 
  /// Returns the user if found, null otherwise
  Future<UserEntity?> getUserById(String id);
  
  /// Update an existing user
  /// 
  /// Returns the updated user
  /// Throws an exception if the update operation fails or the user doesn't exist
  Future<UserEntity> updateUser(UserEntity user);
  
  /// Delete a user by ID
  /// 
  /// Returns true if the user was successfully deleted, false otherwise
  Future<bool> deleteUser(String id);
  
  /// Add a role to a user
  /// 
  /// Returns the updated user
  Future<UserEntity> addRole(String userId, String role);
  
  /// Remove a role from a user
  /// 
  /// Returns the updated user
  Future<UserEntity> removeRole(String userId, String role);
  
  /// Update driver details for a user
  /// 
  /// Returns the updated user
  Future<UserEntity> updateDriverDetails(String userId, DriverDetails driverDetails);
  
  /// Update client details for a user
  /// 
  /// Returns the updated user
  Future<UserEntity> updateClientDetails(String userId, ClientDetails clientDetails);
  
  /// Update a driver's current position
  /// 
  /// Returns the updated user
  Future<UserEntity> updateDriverPosition(String userId, double latitude, double longitude);
  
  /// Update a driver's availability status
  /// 
  /// Returns the updated user
  Future<UserEntity> updateDriverAvailability(String userId, bool isAvailable);
  
  /// Get all available drivers
  /// 
  /// Returns a list of all users that are drivers and currently available
  Future<List<UserEntity>> getAvailableDrivers();
}
