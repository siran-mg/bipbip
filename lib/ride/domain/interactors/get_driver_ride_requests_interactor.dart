import 'package:ndao/ride/domain/entities/ride_request_entity.dart';
import 'package:ndao/ride/domain/repositories/ride_request_repository.dart';

/// Interactor for getting a driver's ride requests
class GetDriverRideRequestsInteractor {
  final RideRequestRepository _rideRequestRepository;

  /// Creates a new GetDriverRideRequestsInteractor
  GetDriverRideRequestsInteractor(this._rideRequestRepository);

  /// Execute the interactor
  ///
  /// [driverId] ID of the driver
  Future<List<RideRequestEntity>> execute(String driverId) {
    return _rideRequestRepository.getRideRequestsByDriverId(driverId);
  }
}
