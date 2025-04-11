import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/foundation.dart';
import 'package:ndao/location/domain/utils/location_utils.dart';
import 'package:ndao/ride/domain/entities/ride_request_entity.dart';
import 'package:ndao/ride/domain/repositories/ride_request_repository.dart';

/// Implementation of RideRequestRepository using Appwrite
class AppwriteRideRequestRepository implements RideRequestRepository {
  final Databases _databases;
  final String _databaseId;
  final String _rideRequestsCollectionId;

  /// Creates a new AppwriteRideRequestRepository
  AppwriteRideRequestRepository(
    this._databases, {
    required String databaseId,
    required String rideRequestsCollectionId,
  })  : _databaseId = databaseId,
        _rideRequestsCollectionId = rideRequestsCollectionId;

  @override
  Future<RideRequestEntity> createRideRequest({
    required String clientId,
    required double pickupLatitude,
    required double pickupLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationName,
    required double budget,
  }) async {
    debugPrint('Creating ride request for client $clientId');
    debugPrint('Pickup: $pickupLatitude, $pickupLongitude');
    debugPrint('Destination: $destinationLatitude, $destinationLongitude');
    debugPrint('Destination name: $destinationName');
    debugPrint('Budget: $budget');

    try {
      final now = DateTime.now();
      final document = await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _rideRequestsCollectionId,
        documentId: ID.unique(),
        data: {
          'client_id': clientId,
          'pickup_latitude': pickupLatitude,
          'pickup_longitude': pickupLongitude,
          'destination_latitude': destinationLatitude,
          'destination_longitude': destinationLongitude,
          'destination_name': destinationName,
          'budget': budget,
          'status': 'pending',
          'driver_id': null,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      );

      return _documentToRideRequestEntity(document);
    } catch (e) {
      debugPrint('Error creating ride request: $e');
      rethrow;
    }
  }

  @override
  Future<RideRequestEntity?> getRideRequestById(String id) async {
    try {
      final document = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _rideRequestsCollectionId,
        documentId: id,
      );

      return _documentToRideRequestEntity(document);
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        return null;
      }
      debugPrint('Error getting ride request: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error getting ride request: $e');
      rethrow;
    }
  }

  @override
  Future<List<RideRequestEntity>> getRideRequestsByClientId(
      String clientId) async {
    try {
      final documents = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _rideRequestsCollectionId,
        queries: [
          Query.equal('client_id', clientId),
          Query.orderDesc('created_at'),
        ],
      );

      return documents.documents
          .map((doc) => _documentToRideRequestEntity(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting client ride requests: $e');
      rethrow;
    }
  }

  @override
  Future<List<RideRequestEntity>> getRideRequestsByDriverId(
      String driverId) async {
    try {
      final documents = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _rideRequestsCollectionId,
        queries: [
          Query.equal('driver_id', driverId),
          Query.orderDesc('created_at'),
        ],
      );

      return documents.documents
          .map((doc) => _documentToRideRequestEntity(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting driver ride requests: $e');
      rethrow;
    }
  }

  @override
  Future<List<RideRequestEntity>> getNearbyPendingRideRequests({
    required double latitude,
    required double longitude,
    double radiusInKm = 5.0,
  }) async {
    try {
      // Get all pending ride requests
      final documents = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _rideRequestsCollectionId,
        queries: [
          Query.equal('status', 'pending'),
          Query.orderDesc('created_at'),
        ],
      );

      // Filter by distance (since Appwrite doesn't support geospatial queries directly)
      final nearbyRequests = documents.documents.where((doc) {
        final pickupLat = doc.data['pickup_latitude'] as double;
        final pickupLng = doc.data['pickup_longitude'] as double;

        final distance = LocationUtils.calculateDistance(
          latitude,
          longitude,
          pickupLat,
          pickupLng,
        );

        return distance <= radiusInKm;
      }).toList();

      return nearbyRequests
          .map((doc) => _documentToRideRequestEntity(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting nearby ride requests: $e');
      rethrow;
    }
  }

  @override
  Future<RideRequestEntity> acceptRideRequest({
    required String requestId,
    required String driverId,
  }) async {
    try {
      final now = DateTime.now();
      final document = await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _rideRequestsCollectionId,
        documentId: requestId,
        data: {
          'status': 'accepted',
          'driver_id': driverId,
          'updated_at': now.toIso8601String(),
        },
      );

      return _documentToRideRequestEntity(document);
    } catch (e) {
      debugPrint('Error accepting ride request: $e');
      rethrow;
    }
  }

  @override
  Future<void> rejectRideRequest({
    required String requestId,
    required String driverId,
  }) async {
    try {
      // We don't change the status to 'rejected' because we want other drivers
      // to be able to see and accept the request. Instead, we could track
      // rejections in a separate collection if needed.
      debugPrint('Driver $driverId rejected ride request $requestId');
    } catch (e) {
      debugPrint('Error rejecting ride request: $e');
      rethrow;
    }
  }

  @override
  Future<RideRequestEntity> completeRideRequest(String requestId) async {
    try {
      final now = DateTime.now();
      final document = await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _rideRequestsCollectionId,
        documentId: requestId,
        data: {
          'status': 'completed',
          'updated_at': now.toIso8601String(),
        },
      );

      return _documentToRideRequestEntity(document);
    } catch (e) {
      debugPrint('Error completing ride request: $e');
      rethrow;
    }
  }

  @override
  Future<RideRequestEntity> cancelRideRequest(String requestId) async {
    try {
      final now = DateTime.now();
      final document = await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _rideRequestsCollectionId,
        documentId: requestId,
        data: {
          'status': 'cancelled',
          'updated_at': now.toIso8601String(),
        },
      );

      return _documentToRideRequestEntity(document);
    } catch (e) {
      debugPrint('Error cancelling ride request: $e');
      rethrow;
    }
  }

  /// Convert an Appwrite document to a RideRequestEntity
  RideRequestEntity _documentToRideRequestEntity(Document document) {
    // Handle driver_id which might be null for pending requests
    String? driverId;
    if (document.data['driver_id'] != null) {
      driverId = document.data['driver_id']['\$id'];
    }
    
    return RideRequestEntity(
      id: document.$id,
      clientId: document.data['client_id']['\$id'],
      pickupLatitude: document.data['pickup_latitude'],
      pickupLongitude: document.data['pickup_longitude'],
      destinationLatitude: document.data['destination_latitude'],
      destinationLongitude: document.data['destination_longitude'],
      destinationName: document.data['destination_name'],
      budget: document.data['budget'],
      status: document.data['status'],
      driverId: driverId,
      createdAt: DateTime.parse(document.data['created_at']),
      updatedAt: DateTime.parse(document.data['updated_at']),
    );
  }
}
