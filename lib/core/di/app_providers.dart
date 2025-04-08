import 'package:provider/single_child_widget.dart';
import 'package:ndao/core/di/client_providers.dart';
import 'package:ndao/core/di/auth_providers.dart';
import 'package:ndao/core/di/user_providers.dart';
import 'package:ndao/core/di/vehicle_providers.dart';
import 'package:ndao/core/di/location_providers.dart';

/// Provides all the providers for the app
class AppProviders {
  /// Get all providers for the app
  static List<SingleChildWidget> getProviders() {
    return [
      ...ClientProviders.getProviders(),
      ...VehicleProviders.getProviders(),
      ...UserProviders.getProviders(),
      ...LocationProviders.getProviders(),
      ...AuthProviders.getProviders(),
    ];
  }
}
