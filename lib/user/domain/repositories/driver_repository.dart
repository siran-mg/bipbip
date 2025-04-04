import 'package:ndao/user/domain/entities/driver_entity.dart';

/// Repository interface for driver-related operations
abstract class DriverRepository {
  /// Save a driver to the data source
  /// 
  /// Returns the saved driver with any server-generated fields (like ID)
  /// Throws an exception if the save operation fails
  Future<DriverEntity> saveDriver(DriverEntity driver);
  
  /// Get a driver by ID
  /// 
  /// Returns the driver if found, null otherwise
  Future<DriverEntity?> getDriverById(String id);
  
  /// Update an existing driver
  /// 
  /// Returns the updated driver
  /// Throws an exception if the update operation fails or the driver doesn't exist
  Future<DriverEntity> updateDriver(DriverEntity driver);
  
  /// Delete a driver by ID
  /// 
  /// Returns true if the driver was successfully deleted, false otherwise
  Future<bool> deleteDriver(String id);
  
  /// Update a driver's current position
  /// 
  /// Returns the updated driver
  Future<DriverEntity> updateDriverPosition(String driverId, double latitude, double longitude);
  
  /// Update a driver's availability status
  /// 
  /// Returns the updated driver
  Future<DriverEntity> updateDriverAvailability(String driverId, bool isAvailable);
  
  /// Get all available drivers
  /// 
  /// Returns a list of all drivers that are currently available
  Future<List<DriverEntity>> getAvailableDrivers();
}
