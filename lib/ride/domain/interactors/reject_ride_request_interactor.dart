import 'package:ndao/ride/domain/repositories/ride_request_repository.dart';

/// Interactor for rejecting a ride request
class RejectRideRequestInteractor {
  final RideRequestRepository _rideRequestRepository;

  /// Creates a new RejectRideRequestInteractor
  RejectRideRequestInteractor(this._rideRequestRepository);

  /// Execute the interactor
  ///
  /// [requestId] ID of the ride request to reject
  /// [driverId] ID of the driver rejecting the request
  Future<void> execute({
    required String requestId,
    required String driverId,
  }) {
    return _rideRequestRepository.rejectRideRequest(
      requestId: requestId,
      driverId: driverId,
    );
  }
}
