import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/location/infrastructure/providers/geo_locator_provider.dart';

/// Provides location-related dependencies
class LocationProviders {
  /// Get all location providers
  static List<SingleChildWidget> getProviders() {
    return [
      // Location provider
      Provider<LocatorProvider>(create: (_) => GeoLocatorProvider()),
    ];
  }
}
