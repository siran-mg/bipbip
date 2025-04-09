import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:ndao/user/domain/repositories/vehicle_repository.dart';
import 'package:ndao/user/infrastructure/repositories/commands/vehicle_commands.dart';
import 'package:ndao/user/infrastructure/repositories/queries/vehicle_queries.dart';

/// Appwrite implementation of the VehicleRepository using Command Query Separation
class AppwriteVehicleRepository implements VehicleRepository {
  late final VehicleQueries _vehicleQueries;
  late final VehicleCommands _vehicleCommands;

  /// Creates a new AppwriteVehicleRepository
  AppwriteVehicleRepository(
    Databases databases,
    Storage storage, {
    String databaseId = 'ndao',
    String vehiclesCollectionId = 'vehicles',
    String driverVehiclesCollectionId = 'driver_vehicles',
    String vehiclePhotosBucketId = 'vehicle_photos',
  }) {
    // Initialize queries first
    _vehicleQueries = VehicleQueries(
      databases,
      databaseId: databaseId,
      vehiclesCollectionId: vehiclesCollectionId,
      driverVehiclesCollectionId: driverVehiclesCollectionId,
    );

    // Initialize commands
    _vehicleCommands = VehicleCommands(
      databases,
      storage,
      _vehicleQueries,
      databaseId: databaseId,
      vehiclesCollectionId: vehiclesCollectionId,
      driverVehiclesCollectionId: driverVehiclesCollectionId,
      vehiclePhotosBucketId: vehiclePhotosBucketId,
    );
  }

  @override
  Future<VehicleEntity> createVehicle({
    required String driverId,
    required String licensePlate,
    required String brand,
    required String model,
    required String type,
    bool isPrimary = true,
  }) {
    return _vehicleCommands.createVehicle(
      driverId: driverId,
      licensePlate: licensePlate,
      brand: brand,
      model: model,
      type: type,
      isPrimary: isPrimary,
    );
  }

  @override
  Future<VehicleEntity?> getVehicleById(String id) {
    return _vehicleQueries.getVehicleById(id);
  }

  @override
  Future<List<VehicleEntity>> getVehiclesForDriver(String driverId) {
    return _vehicleQueries.getVehiclesForDriver(driverId);
  }

  @override
  Future<VehicleEntity> updateVehicle(VehicleEntity vehicle) {
    return _vehicleCommands.updateVehicle(vehicle);
  }

  @override
  Future<void> deleteVehicle(String id) {
    return _vehicleCommands.deleteVehicle(id);
  }

  @override
  Future<void> setPrimaryVehicle(String driverId, String vehicleId) {
    return _vehicleCommands.setPrimaryVehicle(driverId, vehicleId);
  }

  @override
  Future<String> uploadVehiclePhoto(String vehicleId, File photo) {
    return _vehicleCommands.uploadVehiclePhoto(vehicleId, photo);
  }
}
