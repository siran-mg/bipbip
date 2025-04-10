import 'package:provider/single_child_widget.dart';
import 'package:ndao/core/di/client_providers.dart';
import 'package:ndao/core/di/auth_providers.dart';
import 'package:ndao/core/di/user_providers.dart';
import 'package:ndao/core/di/user_repository_providers.dart';
import 'package:ndao/core/di/vehicle_providers.dart';
import 'package:ndao/core/di/location_providers.dart';
import 'package:ndao/core/di/review_providers.dart';

/// Provides all the providers for the app
class AppProviders {
  /// Get all providers for the app
  static List<SingleChildWidget> getProviders() {
    return [
      // Basic infrastructure providers
      ...ClientProviders.getProviders(),

      // Repository providers
      ...VehicleProviders.getProviders(),

      // User repository providers
      ...UserRepositoryProviders.getProviders(),

      // Auth providers depend on user repository
      ...AuthProviders.getProviders(),

      // Location providers need to be registered before user providers
      // because DriverProvider depends on LocatorProvider
      ...LocationProviders.getProviders(),

      // User interactor providers depend on auth providers
      ...UserProviders.getProviders(),

      // Review providers depend on user providers
      ...ReviewProviders.getProviders(),
    ];
  }
}
