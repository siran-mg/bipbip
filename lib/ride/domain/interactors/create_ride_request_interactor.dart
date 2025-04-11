import 'package:ndao/ride/domain/entities/ride_request_entity.dart';
import 'package:ndao/ride/domain/repositories/ride_request_repository.dart';

/// Interactor for creating a ride request
class CreateRideRequestInteractor {
  final RideRequestRepository _rideRequestRepository;

  /// Creates a new CreateRideRequestInteractor
  CreateRideRequestInteractor(this._rideRequestRepository);

  /// Execute the interactor
  ///
  /// [clientId] ID of the client creating the request
  /// [pickupLatitude] Latitude of the pickup location
  /// [pickupLongitude] Longitude of the pickup location
  /// [destinationLatitude] Latitude of the destination
  /// [destinationLongitude] Longitude of the destination
  /// [destinationName] Human-readable name of the destination
  /// [budget] Client's budget for the ride
  Future<RideRequestEntity> execute({
    required String clientId,
    required double pickupLatitude,
    required double pickupLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationName,
    required double budget,
  }) {
    return _rideRequestRepository.createRideRequest(
      clientId: clientId,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      destinationName: destinationName,
      budget: budget,
    );
  }
}
