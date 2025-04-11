import 'package:ndao/ride/domain/entities/ride_request_entity.dart';
import 'package:ndao/ride/domain/repositories/ride_request_repository.dart';

/// Interactor for cancelling a ride request
class CancelRideRequestInteractor {
  final RideRequestRepository _rideRequestRepository;

  /// Creates a new CancelRideRequestInteractor
  CancelRideRequestInteractor(this._rideRequestRepository);

  /// Execute the interactor
  ///
  /// [requestId] ID of the ride request to cancel
  Future<RideRequestEntity> execute(String requestId) {
    return _rideRequestRepository.cancelRideRequest(requestId);
  }
}
