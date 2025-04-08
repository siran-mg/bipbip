import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/location/infrastructure/providers/geo_locator_provider.dart';
import 'package:ndao/location/infrastructure/services/location_tracking_service_manager.dart';
import 'package:ndao/user/domain/interactors/driver_location_tracking_interactor.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

/// Provides location-related dependencies
class LocationProviders {
  /// Get all location providers
  static List<SingleChildWidget> getProviders() {
    return [
      // Location provider
      Provider<LocatorProvider>(create: (_) => GeoLocatorProvider()),

      // Driver location tracking interactor
      ProxyProvider2<LocatorProvider, UserRepository,
          DriverLocationTrackingInteractor>(
        update: (_, locatorProvider, userRepository, __) =>
            DriverLocationTrackingInteractor(locatorProvider, userRepository),
      ),

      // Location tracking service manager
      ProxyProvider3<LocatorProvider, GetCurrentUserInteractor,
          DriverLocationTrackingInteractor, LocationTrackingServiceManager>(
        update: (_, locatorProvider, getCurrentUserInteractor,
                driverLocationTrackingInteractor, __) =>
            LocationTrackingServiceManager(
          locatorProvider,
          getCurrentUserInteractor,
          driverLocationTrackingInteractor,
        ),
      ),
    ];
  }
}
