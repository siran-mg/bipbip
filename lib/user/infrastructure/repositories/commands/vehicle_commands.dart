import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:ndao/user/infrastructure/repositories/queries/vehicle_queries.dart';
import 'package:path/path.dart' as path;

/// Class responsible for write operations related to vehicles
class VehicleCommands {
  final Databases _databases;
  final Storage _storage;
  final VehicleQueries _vehicleQueries;
  final String _databaseId;
  final String _vehiclesCollectionId;
  final String _driverVehiclesCollectionId;
  final String _vehiclePhotosBucketId;

  /// Creates a new VehicleCommands
  VehicleCommands(
    this._databases,
    this._storage,
    this._vehicleQueries, {
    String databaseId = 'ndao',
    String vehiclesCollectionId = 'vehicles',
    String driverVehiclesCollectionId = 'driver_vehicles',
    String vehiclePhotosBucketId = 'vehicle_photos',
  })  : _databaseId = databaseId,
        _vehiclesCollectionId = vehiclesCollectionId,
        _driverVehiclesCollectionId = driverVehiclesCollectionId,
        _vehiclePhotosBucketId = vehiclePhotosBucketId;

  /// Create a new vehicle
  Future<VehicleEntity> createVehicle({
    required String driverId,
    required String licensePlate,
    required String brand,
    required String model,
    required String type,
    bool isPrimary = true,
  }) async {
    try {
      // Create the vehicle
      final now = DateTime.now().toIso8601String();
      final vehicleDoc = await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _vehiclesCollectionId,
        documentId: 'unique()',
        data: {
          'license_plate': licensePlate,
          'brand': brand,
          'model': model,
          'type': type,
          'photo_url': null,
          'created_at': now,
          'updated_at': now,
        },
      );

      // Link the vehicle to the driver
      final linkTime = DateTime.now().toIso8601String();
      await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _driverVehiclesCollectionId,
        documentId: 'unique()',
        data: {
          'driver_id': driverId,
          'vehicle_id': vehicleDoc.$id,
          'is_primary': isPrimary,
          'created_at': linkTime,
          'updated_at': linkTime,
        },
      );

      // If this is the primary vehicle, make sure all other vehicles are not primary
      if (isPrimary) {
        await _updateOtherVehiclesToNonPrimary(driverId, vehicleDoc.$id);
      }

      return VehicleEntity(
        id: vehicleDoc.$id,
        licensePlate: licensePlate,
        brand: brand,
        model: model,
        type: type,
        isPrimary: isPrimary,
      );
    } catch (e) {
      throw Exception('Failed to create vehicle: $e');
    }
  }

  /// Update a vehicle
  Future<VehicleEntity> updateVehicle(VehicleEntity vehicle) async {
    try {
      final updateTime = DateTime.now().toIso8601String();
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _vehiclesCollectionId,
        documentId: vehicle.id,
        data: {
          'license_plate': vehicle.licensePlate,
          'brand': vehicle.brand,
          'model': vehicle.model,
          'type': vehicle.type,
          if (vehicle.photoUrl != null) 'photo_url': vehicle.photoUrl,
          'updated_at': updateTime,
        },
      );

      return vehicle;
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  /// Delete a vehicle
  Future<void> deleteVehicle(String id) async {
    try {
      // Delete the vehicle
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: _vehiclesCollectionId,
        documentId: id,
      );

      // Delete all driver-vehicle relationships for this vehicle
      final driverVehicleDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _driverVehiclesCollectionId,
        queries: [
          Query.equal('vehicle_id', id),
        ],
      );

      for (final doc in driverVehicleDocs.documents) {
        await _databases.deleteDocument(
          databaseId: _databaseId,
          collectionId: _driverVehiclesCollectionId,
          documentId: doc.$id,
        );
      }
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  /// Set a vehicle as primary for a driver
  Future<void> setPrimaryVehicle(String driverId, String vehicleId) async {
    try {
      // Get the driver-vehicle relationship
      final driverVehicleDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _driverVehiclesCollectionId,
        queries: [
          Query.equal('driver_id', driverId),
          Query.equal('vehicle_id', vehicleId),
        ],
      );

      if (driverVehicleDocs.documents.isEmpty) {
        throw Exception('Vehicle not found for driver');
      }

      // Update the relationship to be primary
      final updateTime = DateTime.now().toIso8601String();
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _driverVehiclesCollectionId,
        documentId: driverVehicleDocs.documents.first.$id,
        data: {
          'is_primary': true,
          'updated_at': updateTime,
        },
      );

      // Update all other vehicles to not be primary
      await _updateOtherVehiclesToNonPrimary(driverId, vehicleId);
    } catch (e) {
      throw Exception('Failed to set primary vehicle: $e');
    }
  }

  /// Upload a vehicle photo
  Future<String> uploadVehiclePhoto(String vehicleId, File photo) async {
    try {
      // Get the vehicle to make sure it exists
      final vehicle = await _vehicleQueries.getVehicleById(vehicleId);
      if (vehicle == null) {
        throw Exception('Vehicle not found');
      }

      // Generate a unique filename
      final extension = path.extension(photo.path);
      final filename =
          '$vehicleId-${DateTime.now().millisecondsSinceEpoch}$extension';

      // Upload the photo
      final result = await _storage.createFile(
        bucketId: _vehiclePhotosBucketId,
        fileId: 'unique()',
        file: InputFile.fromPath(
          path: photo.path,
          filename: filename,
        ),
      );

      // Get the photo URL
      final photoUrl = _storage
          .getFileView(
            bucketId: _vehiclePhotosBucketId,
            fileId: result.$id,
          )
          .toString();

      // Update the vehicle with the photo URL
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _vehiclesCollectionId,
        documentId: vehicleId,
        data: {
          'photo_url': photoUrl,
        },
      );

      return photoUrl;
    } catch (e) {
      throw Exception('Failed to upload vehicle photo: $e');
    }
  }

  /// Update all other vehicles for a driver to not be primary
  Future<void> _updateOtherVehiclesToNonPrimary(
    String driverId,
    String excludeVehicleId,
  ) async {
    try {
      // Get all driver-vehicle relationships for this driver
      final driverVehicleDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _driverVehiclesCollectionId,
        queries: [
          Query.equal('driver_id', driverId),
          Query.notEqual('vehicle_id', excludeVehicleId),
          Query.equal('is_primary', true),
        ],
      );

      // Update all other vehicles to not be primary
      for (final doc in driverVehicleDocs.documents) {
        final updateTime = DateTime.now().toIso8601String();
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _driverVehiclesCollectionId,
          documentId: doc.$id,
          data: {
            'is_primary': false,
            'updated_at': updateTime,
          },
        );
      }
    } catch (e) {
      throw Exception('Failed to update other vehicles: $e');
    }
  }
}
