import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';
import 'package:ndao/user/domain/repositories/vehicle_repository.dart';
import 'package:path/path.dart' as path;

/// Appwrite implementation of the VehicleRepository
class AppwriteVehicleRepository implements VehicleRepository {
  final Databases _databases;
  final Storage _storage;
  final String _databaseId;
  final String _vehiclesCollectionId;
  final String _driverVehiclesCollectionId;
  final String _vehiclePhotosBucketId;

  /// Creates a new AppwriteVehicleRepository
  AppwriteVehicleRepository(
    this._databases,
    this._storage, {
    String databaseId = 'ndao',
    String vehiclesCollectionId = 'vehicles',
    String driverVehiclesCollectionId = 'driver_vehicles',
    String vehiclePhotosBucketId = 'vehicle_photos',
  })  : _databaseId = databaseId,
        _vehiclesCollectionId = vehiclesCollectionId,
        _driverVehiclesCollectionId = driverVehiclesCollectionId,
        _vehiclePhotosBucketId = vehiclePhotosBucketId;

  @override
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

  @override
  Future<VehicleEntity?> getVehicleById(String id) async {
    try {
      final vehicleDoc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _vehiclesCollectionId,
        documentId: id,
      );

      // Get the driver-vehicle relationship to determine if it's primary
      final driverVehicleDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _driverVehiclesCollectionId,
        queries: [
          Query.equal('vehicle_id', id),
        ],
      );

      bool isPrimary = false;
      if (driverVehicleDocs.documents.isNotEmpty) {
        isPrimary =
            driverVehicleDocs.documents.first.data['is_primary'] ?? false;
      }

      return VehicleEntity(
        id: vehicleDoc.$id,
        licensePlate: vehicleDoc.data['license_plate'],
        brand: vehicleDoc.data['brand'],
        model: vehicleDoc.data['model'],
        type: vehicleDoc.data['type'],
        photoUrl: vehicleDoc.data['photo_url'],
        isPrimary: isPrimary,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<VehicleEntity>> getVehiclesForDriver(String driverId) async {
    try {
      // Get all driver-vehicle relationships for this driver
      final driverVehicleDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _driverVehiclesCollectionId,
        queries: [
          Query.equal('driver_id', driverId),
        ],
      );

      if (driverVehicleDocs.documents.isEmpty) {
        return [];
      }

      // Get all vehicle IDs with their primary status
      final vehicleIdsWithPrimary = driverVehicleDocs.documents
          .map((doc) => {
                'vehicle': doc.data['vehicle_id'],
                'isPrimary': doc.data['is_primary'] ?? false,
              })
          .toList();

      // Fetch each vehicle document
      final vehicles = <VehicleEntity>[];
      for (final vehicleData in vehicleIdsWithPrimary) {
        final vehicle = vehicleData['vehicle'];
        final isPrimary = vehicleData['isPrimary'];

        try {
          final vehicleDoc = await _databases.getDocument(
            databaseId: _databaseId,
            collectionId: _vehiclesCollectionId,
            documentId: vehicle['\$id'],
          );

          vehicles.add(VehicleEntity(
            id: vehicleDoc.$id,
            licensePlate: vehicleDoc.data['license_plate'],
            brand: vehicleDoc.data['brand'],
            model: vehicleDoc.data['model'],
            type: vehicleDoc.data['type'],
            photoUrl: vehicleDoc.data['photo_url'],
            isPrimary: isPrimary,
          ));
        } catch (e) {
          // Skip this vehicle if it doesn't exist
        }
      }

      return vehicles;
    } catch (e) {
      throw Exception('Failed to get vehicles for driver: $e');
    }
  }

  @override
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

  @override
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

  @override
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

  @override
  Future<String> uploadVehiclePhoto(String vehicleId, File photo) async {
    try {
      // Get the vehicle to make sure it exists
      final vehicle = await getVehicleById(vehicleId);
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
