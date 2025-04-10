import 'package:ndao/user/domain/entities/user_entity.dart';

/// Repository interface for favorite driver operations
abstract class FavoriteDriverRepository {
  /// Add a driver to a client's favorites
  ///
  /// Returns true if the operation was successful
  Future<bool> addFavoriteDriver(String clientId, String driverId);

  /// Remove a driver from a client's favorites
  ///
  /// Returns true if the operation was successful
  Future<bool> removeFavoriteDriver(String clientId, String driverId);

  /// Check if a driver is in a client's favorites
  ///
  /// Returns true if the driver is a favorite
  Future<bool> isDriverFavorite(String clientId, String driverId);

  /// Get all favorite drivers for a client
  ///
  /// Returns a list of driver entities
  Future<List<UserEntity>> getFavoriteDrivers(String clientId);

  /// Get all clients who have marked a driver as favorite
  ///
  /// Returns a list of client entities
  Future<List<UserEntity>> getFavoriteClients(String driverId);
}
