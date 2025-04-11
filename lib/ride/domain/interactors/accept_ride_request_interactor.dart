import 'package:ndao/ride/domain/entities/ride_request_entity.dart';
import 'package:ndao/ride/domain/repositories/ride_request_repository.dart';

/// Interactor for accepting a ride request
class AcceptRideRequestInteractor {
  final RideRequestRepository _rideRequestRepository;

  /// Creates a new AcceptRideRequestInteractor
  AcceptRideRequestInteractor(this._rideRequestRepository);

  /// Execute the interactor
  ///
  /// [requestId] ID of the ride request to accept
  /// [driverId] ID of the driver accepting the request
  Future<RideRequestEntity> execute({
    required String requestId,
    required String driverId,
  }) {
    return _rideRequestRepository.acceptRideRequest(
      requestId: requestId,
      driverId: driverId,
    );
  }
}
