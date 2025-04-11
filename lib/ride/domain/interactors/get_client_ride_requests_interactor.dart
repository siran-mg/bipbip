import 'package:ndao/ride/domain/entities/ride_request_entity.dart';
import 'package:ndao/ride/domain/repositories/ride_request_repository.dart';

/// Interactor for getting a client's ride requests
class GetClientRideRequestsInteractor {
  final RideRequestRepository _rideRequestRepository;

  /// Creates a new GetClientRideRequestsInteractor
  GetClientRideRequestsInteractor(this._rideRequestRepository);

  /// Execute the interactor
  ///
  /// [clientId] ID of the client
  Future<List<RideRequestEntity>> execute(String clientId) {
    return _rideRequestRepository.getRideRequestsByClientId(clientId);
  }
}
