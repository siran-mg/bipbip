import 'package:flutter/widgets.dart';
import 'package:ndao/location/infrastructure/services/location_tracking_service_manager.dart';
import 'package:provider/provider.dart';

/// Provider that initializes the location tracking service
class LocationServiceInitializerProvider extends ChangeNotifier {
  bool _initialized = false;
  bool _initializing = false;

  /// Whether the service has been initialized
  bool get initialized => _initialized;

  /// Whether the service is currently being initialized
  bool get initializing => _initializing;

  /// Initialize the location tracking service
  Future<void> initialize(BuildContext context) async {
    if (_initialized || _initializing) return;

    _initializing = true;
    notifyListeners();

    try {
      // Get the location tracking service manager
      LocationTrackingServiceManager? serviceManager;
      try {
        serviceManager = Provider.of<LocationTrackingServiceManager>(
          context,
          listen: false,
        );
      } catch (providerError) {
        debugPrint('Location tracking service not available: $providerError');
        _initializing = false;
        notifyListeners();
        return;
      }

      // Initialize the service
      await serviceManager.initialize();

      _initialized = true;
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error initializing location tracking service: $e');
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }
}
