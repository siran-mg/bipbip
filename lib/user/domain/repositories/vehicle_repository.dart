import 'dart:io';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';

/// Repository for vehicle operations
abstract class VehicleRepository {
  /// Create a new vehicle
  Future<VehicleEntity> createVehicle({
    required String driverId,
    required String licensePlate,
    required String brand,
    required String model,
    required String type,
    bool isPrimary = true,
  });
  
  /// Get a vehicle by ID
  Future<VehicleEntity?> getVehicleById(String id);
  
  /// Get all vehicles for a driver
  Future<List<VehicleEntity>> getVehiclesForDriver(String driverId);
  
  /// Update a vehicle
  Future<VehicleEntity> updateVehicle(VehicleEntity vehicle);
  
  /// Delete a vehicle
  Future<void> deleteVehicle(String id);
  
  /// Set a vehicle as primary for a driver
  Future<void> setPrimaryVehicle(String driverId, String vehicleId);
  
  /// Upload a vehicle photo
  Future<String> uploadVehiclePhoto(String vehicleId, File photo);
}
