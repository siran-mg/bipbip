import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ndao/core/infrastructure/appwrite/appwrite_client.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/ride/domain/interactors/accept_ride_request_interactor.dart';
import 'package:ndao/ride/domain/interactors/cancel_ride_request_interactor.dart';
import 'package:ndao/ride/domain/interactors/create_ride_request_interactor.dart';
import 'package:ndao/ride/domain/interactors/get_client_ride_requests_interactor.dart';
import 'package:ndao/ride/domain/interactors/get_driver_ride_requests_interactor.dart';
import 'package:ndao/ride/domain/interactors/get_nearby_ride_requests_interactor.dart';
import 'package:ndao/ride/domain/interactors/reject_ride_request_interactor.dart';
import 'package:ndao/ride/domain/providers/ride_request_provider.dart';
import 'package:ndao/ride/domain/repositories/ride_request_repository.dart';
import 'package:ndao/ride/infrastructure/repositories/appwrite_ride_request_repository_fixed.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Provides ride-related dependencies
class RideProviders {
  /// Get all ride providers
  static List<SingleChildWidget> getProviders() {
    return [
      // Ride request repository
      Provider<RideRequestRepository>(
        create: (context) => AppwriteRideRequestRepository(
          AppwriteClientInitializer.instance.databases,
          databaseId: dotenv.env['APPWRITE_DATABASE_ID'] ?? 'ndao',
          rideRequestsCollectionId:
              dotenv.env['APPWRITE_RIDE_REQUESTS_COLLECTION_ID'] ??
                  'ride_requests',
        ),
      ),

      // Ride request interactors
      Provider<CreateRideRequestInteractor>(
        create: (context) => CreateRideRequestInteractor(
          context.read<RideRequestRepository>(),
        ),
      ),

      Provider<GetClientRideRequestsInteractor>(
        create: (context) => GetClientRideRequestsInteractor(
          context.read<RideRequestRepository>(),
        ),
      ),

      Provider<GetDriverRideRequestsInteractor>(
        create: (context) => GetDriverRideRequestsInteractor(
          context.read<RideRequestRepository>(),
        ),
      ),

      Provider<GetNearbyRideRequestsInteractor>(
        create: (context) => GetNearbyRideRequestsInteractor(
          context.read<RideRequestRepository>(),
        ),
      ),

      Provider<AcceptRideRequestInteractor>(
        create: (context) => AcceptRideRequestInteractor(
          context.read<RideRequestRepository>(),
        ),
      ),

      Provider<RejectRideRequestInteractor>(
        create: (context) => RejectRideRequestInteractor(
          context.read<RideRequestRepository>(),
        ),
      ),

      Provider<CancelRideRequestInteractor>(
        create: (context) => CancelRideRequestInteractor(
          context.read<RideRequestRepository>(),
        ),
      ),

      // Ride request provider
      ChangeNotifierProvider<RideRequestProvider>(
        create: (context) => RideRequestProvider(
          createRideRequestInteractor:
              context.read<CreateRideRequestInteractor>(),
          getClientRideRequestsInteractor:
              context.read<GetClientRideRequestsInteractor>(),
          getDriverRideRequestsInteractor:
              context.read<GetDriverRideRequestsInteractor>(),
          getNearbyRideRequestsInteractor:
              context.read<GetNearbyRideRequestsInteractor>(),
          acceptRideRequestInteractor:
              context.read<AcceptRideRequestInteractor>(),
          rejectRideRequestInteractor:
              context.read<RejectRideRequestInteractor>(),
          cancelRideRequestInteractor:
              context.read<CancelRideRequestInteractor>(),
          locatorProvider: context.read<LocatorProvider>(),
          databaseId: dotenv.env['APPWRITE_DATABASE_ID'] ?? 'ndao',
          rideRequestsCollectionId:
              dotenv.env['APPWRITE_RIDE_REQUESTS_COLLECTION_ID'] ??
                  'ride_requests',
        ),
      ),
    ];
  }
}
