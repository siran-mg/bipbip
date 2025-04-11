import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:ndao/core/infrastructure/appwrite/appwrite_client.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/ride/domain/entities/ride_request_entity.dart';
import 'package:ndao/ride/domain/interactors/accept_ride_request_interactor.dart';
import 'package:ndao/ride/domain/interactors/create_ride_request_interactor.dart';
import 'package:ndao/ride/domain/interactors/get_client_ride_requests_interactor.dart';
import 'package:ndao/ride/domain/interactors/get_driver_ride_requests_interactor.dart';
import 'package:ndao/ride/domain/interactors/get_nearby_ride_requests_interactor.dart';
import 'package:ndao/ride/domain/interactors/reject_ride_request_interactor.dart';

/// Provider for managing ride requests
class RideRequestProvider extends ChangeNotifier {
  final CreateRideRequestInteractor _createRideRequestInteractor;
  final GetClientRideRequestsInteractor _getClientRideRequestsInteractor;
  final GetDriverRideRequestsInteractor _getDriverRideRequestsInteractor;
  final GetNearbyRideRequestsInteractor _getNearbyRideRequestsInteractor;
  final AcceptRideRequestInteractor _acceptRideRequestInteractor;
  final RejectRideRequestInteractor _rejectRideRequestInteractor;
  final LocatorProvider _locatorProvider;
  final String _databaseId;
  final String _rideRequestsCollectionId;

  // State
  bool _isLoading = false;
  String? _error;
  List<RideRequestEntity> _clientRideRequests = [];
  List<RideRequestEntity> _driverRideRequests = [];
  List<RideRequestEntity> _nearbyRideRequests = [];
  RealtimeSubscription? _rideRequestsSubscription;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<RideRequestEntity> get clientRideRequests => _clientRideRequests;
  List<RideRequestEntity> get driverRideRequests => _driverRideRequests;
  List<RideRequestEntity> get nearbyRideRequests => _nearbyRideRequests;

  /// Creates a new RideRequestProvider
  RideRequestProvider({
    required CreateRideRequestInteractor createRideRequestInteractor,
    required GetClientRideRequestsInteractor getClientRideRequestsInteractor,
    required GetDriverRideRequestsInteractor getDriverRideRequestsInteractor,
    required GetNearbyRideRequestsInteractor getNearbyRideRequestsInteractor,
    required AcceptRideRequestInteractor acceptRideRequestInteractor,
    required RejectRideRequestInteractor rejectRideRequestInteractor,
    required LocatorProvider locatorProvider,
    required String databaseId,
    required String rideRequestsCollectionId,
  })  : _createRideRequestInteractor = createRideRequestInteractor,
        _getClientRideRequestsInteractor = getClientRideRequestsInteractor,
        _getDriverRideRequestsInteractor = getDriverRideRequestsInteractor,
        _getNearbyRideRequestsInteractor = getNearbyRideRequestsInteractor,
        _acceptRideRequestInteractor = acceptRideRequestInteractor,
        _rejectRideRequestInteractor = rejectRideRequestInteractor,
        _locatorProvider = locatorProvider,
        _databaseId = databaseId,
        _rideRequestsCollectionId = rideRequestsCollectionId;

  /// Create a new ride request
  Future<RideRequestEntity> createRideRequest({
    required String clientId,
    required double pickupLatitude,
    required double pickupLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationName,
    required double budget,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = await _createRideRequestInteractor.execute(
        clientId: clientId,
        pickupLatitude: pickupLatitude,
        pickupLongitude: pickupLongitude,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
        destinationName: destinationName,
        budget: budget,
      );

      // Add to client ride requests
      _clientRideRequests = [request, ..._clientRideRequests];

      _isLoading = false;
      notifyListeners();
      return request;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to create ride request: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Load client ride requests
  Future<void> loadClientRideRequests(String clientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _clientRideRequests =
          await _getClientRideRequestsInteractor.execute(clientId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load client ride requests: $e';
      notifyListeners();
    }
  }

  /// Load driver ride requests
  Future<void> loadDriverRideRequests(String driverId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _driverRideRequests =
          await _getDriverRideRequestsInteractor.execute(driverId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load driver ride requests: $e';
      notifyListeners();
    }
  }

  /// Load nearby ride requests
  Future<void> loadNearbyRideRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current position
      final position = await _locatorProvider.getCurrentPosition();

      // Get nearby ride requests
      _nearbyRideRequests = await _getNearbyRideRequestsInteractor.execute(
        latitude: position.latitude,
        longitude: position.longitude,
        radiusInKm: 10.0, // Larger radius for drivers
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load nearby ride requests: $e';
      notifyListeners();
    }
  }

  /// Accept a ride request
  Future<void> acceptRideRequest({
    required String requestId,
    required String driverId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedRequest = await _acceptRideRequestInteractor.execute(
        requestId: requestId,
        driverId: driverId,
      );

      // Update nearby ride requests
      _nearbyRideRequests = _nearbyRideRequests
          .where((request) => request.id != requestId)
          .toList();

      // Add to driver ride requests
      _driverRideRequests = [updatedRequest, ..._driverRideRequests];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to accept ride request: $e';
      notifyListeners();
    }
  }

  /// Reject a ride request
  Future<void> rejectRideRequest({
    required String requestId,
    required String driverId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _rejectRideRequestInteractor.execute(
        requestId: requestId,
        driverId: driverId,
      );

      // Remove from nearby ride requests for this driver only
      // We don't change the status to 'rejected' because we want other drivers
      // to be able to see and accept the request
      _nearbyRideRequests = _nearbyRideRequests
          .where((request) => request.id != requestId)
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to reject ride request: $e';
      notifyListeners();
    }
  }

  /// Subscribe to ride request updates
  void subscribeToRideRequests() {
    // Cancel any existing subscription
    _rideRequestsSubscription?.close();

    // Subscribe to ride request updates
    _rideRequestsSubscription = AppwriteClientInitializer.instance.realtime
        .subscribe([
      'databases.$_databaseId.collections.$_rideRequestsCollectionId.documents'
    ]);

    _rideRequestsSubscription?.stream.listen((event) {
      if (event.events.contains(
          'databases.$_databaseId.collections.$_rideRequestsCollectionId.documents.*.create')) {
        // A new ride request was created
        _handleNewRideRequest(event);
      } else if (event.events.contains(
          'databases.$_databaseId.collections.$_rideRequestsCollectionId.documents.*.update')) {
        // A ride request was updated
        _handleRideRequestUpdate(event);
      }
    });
  }

  /// Handle a new ride request event
  void _handleNewRideRequest(RealtimeMessage event) {
    try {
      final data = event.payload;

      // Handle client_id which is a reference
      String clientId;
      if (data['client_id'] is Map) {
        clientId = data['client_id']['\$id'];
      } else {
        clientId = data['client_id'];
      }

      // Handle driver_id which might be null or a reference
      String? driverId;
      if (data['driver_id'] != null) {
        if (data['driver_id'] is Map) {
          driverId = data['driver_id']['\$id'];
        } else {
          driverId = data['driver_id'];
        }
      }

      final request = RideRequestEntity(
        id: data['\$id'],
        clientId: clientId,
        pickupLatitude: data['pickup_latitude'],
        pickupLongitude: data['pickup_longitude'],
        destinationLatitude: data['destination_latitude'],
        destinationLongitude: data['destination_longitude'],
        destinationName: data['destination_name'],
        budget: data['budget'],
        status: data['status'],
        driverId: driverId,
        createdAt: DateTime.parse(data['created_at']),
        updatedAt: DateTime.parse(data['updated_at']),
      );

      // If the request is pending, add it to nearby requests
      if (request.isPending) {
        _nearbyRideRequests = [request, ..._nearbyRideRequests];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error handling new ride request: $e');
    }
  }

  /// Handle a ride request update event
  void _handleRideRequestUpdate(RealtimeMessage event) {
    try {
      final data = event.payload;
      final requestId = data['\$id'];
      final status = data['status'];

      // Handle driver_id which might be null or a reference
      String? driverId;
      if (data['driver_id'] != null) {
        if (data['driver_id'] is Map) {
          driverId = data['driver_id']['\$id'];
        } else {
          driverId = data['driver_id'];
        }
      }

      // Update nearby ride requests
      if (status == 'accepted' || status == 'cancelled') {
        _nearbyRideRequests = _nearbyRideRequests
            .where((request) => request.id != requestId)
            .toList();
      }

      // Update client ride requests
      for (int i = 0; i < _clientRideRequests.length; i++) {
        if (_clientRideRequests[i].id == requestId) {
          _clientRideRequests[i] = _clientRideRequests[i].copyWith(
            status: status,
            driverId: driverId,
            updatedAt: DateTime.parse(data['updated_at']),
          );
          break;
        }
      }

      // Update driver ride requests
      for (int i = 0; i < _driverRideRequests.length; i++) {
        if (_driverRideRequests[i].id == requestId) {
          _driverRideRequests[i] = _driverRideRequests[i].copyWith(
            status: status,
            updatedAt: DateTime.parse(data['updated_at']),
          );
          break;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error handling ride request update: $e');
    }
  }

  @override
  void dispose() {
    _rideRequestsSubscription?.close();
    super.dispose();
  }
}
