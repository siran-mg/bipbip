import 'package:appwrite/appwrite.dart';
import 'package:ndao/user/domain/entities/vehicle_entity.dart';

/// Class responsible for read-only operations related to vehicles
class VehicleQueries {
  final Databases _databases;
  final String _databaseId;
  final String _vehiclesCollectionId;
  final String _driverVehiclesCollectionId;

  /// Creates a new VehicleQueries
  VehicleQueries(
    this._databases, {
    String databaseId = 'ndao',
    String vehiclesCollectionId = 'vehicles',
    String driverVehiclesCollectionId = 'driver_vehicles',
  })  : _databaseId = databaseId,
        _vehiclesCollectionId = vehiclesCollectionId,
        _driverVehiclesCollectionId = driverVehiclesCollectionId;

  /// Get a vehicle by ID
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

  /// Get all vehicles for a driver
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
}
