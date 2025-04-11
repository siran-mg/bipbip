import 'package:ndao/ride/domain/entities/ride_request_entity.dart';

/// Repository for managing ride requests
abstract class RideRequestRepository {
  /// Create a new ride request
  ///
  /// [clientId] ID of the client creating the request
  /// [pickupLatitude] Latitude of the pickup location
  /// [pickupLongitude] Longitude of the pickup location
  /// [destinationLatitude] Latitude of the destination
  /// [destinationLongitude] Longitude of the destination
  /// [destinationName] Human-readable name of the destination
  /// [budget] Client's budget for the ride
  Future<RideRequestEntity> createRideRequest({
    required String clientId,
    required double pickupLatitude,
    required double pickupLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationName,
    required double budget,
  });

  /// Get a ride request by ID
  ///
  /// [id] ID of the ride request to get
  Future<RideRequestEntity?> getRideRequestById(String id);

  /// Get all ride requests for a client
  ///
  /// [clientId] ID of the client
  Future<List<RideRequestEntity>> getRideRequestsByClientId(String clientId);

  /// Get all ride requests for a driver
  ///
  /// [driverId] ID of the driver
  Future<List<RideRequestEntity>> getRideRequestsByDriverId(String driverId);

  /// Get all pending ride requests near a location
  ///
  /// [latitude] Latitude of the location
  /// [longitude] Longitude of the location
  /// [radiusInKm] Radius in kilometers to search within
  Future<List<RideRequestEntity>> getNearbyPendingRideRequests({
    required double latitude,
    required double longitude,
    double radiusInKm = 5.0,
  });

  /// Accept a ride request
  ///
  /// [requestId] ID of the ride request to accept
  /// [driverId] ID of the driver accepting the request
  Future<RideRequestEntity> acceptRideRequest({
    required String requestId,
    required String driverId,
  });

  /// Reject a ride request
  ///
  /// [requestId] ID of the ride request to reject
  /// [driverId] ID of the driver rejecting the request
  Future<void> rejectRideRequest({
    required String requestId,
    required String driverId,
  });

  /// Complete a ride request
  ///
  /// [requestId] ID of the ride request to complete
  Future<RideRequestEntity> completeRideRequest(String requestId);

  /// Cancel a ride request
  ///
  /// [requestId] ID of the ride request to cancel
  Future<RideRequestEntity> cancelRideRequest(String requestId);
}
