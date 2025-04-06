import 'dart:io';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:ndao/user/domain/repositories/vehicle_repository.dart';

/// Interactor for vehicle operations
class VehicleInteractor {
  final VehicleRepository _vehicleRepository;

  /// Creates a new VehicleInteractor
  VehicleInteractor(this._vehicleRepository);

  /// Create a new vehicle
  Future<VehicleEntity> createVehicle({
    required String driverId,
    required String licensePlate,
    required String brand,
    required String model,
    required String type,
    bool isPrimary = true,
    File? photo,
  }) async {
    try {
      // Create the vehicle
      final vehicle = await _vehicleRepository.createVehicle(
        driverId: driverId,
        licensePlate: licensePlate,
        brand: brand,
        model: model,
        type: type,
        isPrimary: isPrimary,
      );
      
      // Upload the photo if provided
      if (photo != null) {
        final photoUrl = await _vehicleRepository.uploadVehiclePhoto(
          vehicle.id,
          photo,
        );
        
        // Update the vehicle with the photo URL
        return await _vehicleRepository.updateVehicle(
          vehicle.copyWith(photoUrl: photoUrl),
        );
      }
      
      return vehicle;
    } catch (e) {
      throw Exception('Failed to create vehicle: $e');
    }
  }

  /// Get all vehicles for a driver
  Future<List<VehicleEntity>> getVehiclesForDriver(String driverId) async {
    try {
      return await _vehicleRepository.getVehiclesForDriver(driverId);
    } catch (e) {
      throw Exception('Failed to get vehicles: $e');
    }
  }

  /// Set a vehicle as primary
  Future<void> setPrimaryVehicle(String driverId, String vehicleId) async {
    try {
      await _vehicleRepository.setPrimaryVehicle(driverId, vehicleId);
    } catch (e) {
      throw Exception('Failed to set primary vehicle: $e');
    }
  }

  /// Delete a vehicle
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _vehicleRepository.deleteVehicle(vehicleId);
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  /// Update a vehicle
  Future<VehicleEntity> updateVehicle(VehicleEntity vehicle) async {
    try {
      return await _vehicleRepository.updateVehicle(vehicle);
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  /// Upload a vehicle photo
  Future<String> uploadVehiclePhoto(String vehicleId, File photo) async {
    try {
      return await _vehicleRepository.uploadVehiclePhoto(vehicleId, photo);
    } catch (e) {
      throw Exception('Failed to upload vehicle photo: $e');
    }
  }
}
