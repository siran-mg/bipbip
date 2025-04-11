import 'package:ndao/ride/domain/entities/ride_request_entity.dart';
import 'package:ndao/ride/domain/repositories/ride_request_repository.dart';

/// Interactor for getting nearby ride requests
class GetNearbyRideRequestsInteractor {
  final RideRequestRepository _rideRequestRepository;

  /// Creates a new GetNearbyRideRequestsInteractor
  GetNearbyRideRequestsInteractor(this._rideRequestRepository);

  /// Execute the interactor
  ///
  /// [latitude] Latitude of the location
  /// [longitude] Longitude of the location
  /// [radiusInKm] Radius in kilometers to search within
  Future<List<RideRequestEntity>> execute({
    required double latitude,
    required double longitude,
    double radiusInKm = 5.0,
  }) {
    return _rideRequestRepository.getNearbyPendingRideRequests(
      latitude: latitude,
      longitude: longitude,
      radiusInKm: radiusInKm,
    );
  }
}
