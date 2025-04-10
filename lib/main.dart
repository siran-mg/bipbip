import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ndao/core/di/app_providers.dart';
import 'package:ndao/core/infrastructure/appwrite/appwrite_client.dart';
import 'package:ndao/core/presentation/routes/app_routes.dart';
import 'package:ndao/core/presentation/theme/app_theme.dart';
import 'package:ndao/location/domain/providers/location_service_initializer_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter is initialized before using platform plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // Warning: Failed to load .env file
  }

  // Initialize Appwrite
  await AppwriteClientInitializer.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.getProviders(),
      child: MaterialApp(
        title: 'Ndao',
        theme: AppTheme.getTheme(),
        initialRoute: AppRoutes.initialRoute,
        routes: AppRoutes.getRoutes(),
        builder: (context, child) {
          // Wrap the app with the service initializer
          return ServiceInitializer(child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}

/// Widget that initializes services when first built
class ServiceInitializer extends StatefulWidget {
  /// The child widget
  final Widget child;

  /// Creates a new ServiceInitializer
  const ServiceInitializer({super.key, required this.child});

  @override
  State<ServiceInitializer> createState() => _ServiceInitializerState();
}

class _ServiceInitializerState extends State<ServiceInitializer> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    // Use a Builder to get a new BuildContext that has access to all providers
    return Builder(
      builder: (context) {
        // Initialize services only once
        if (!_initialized) {
          _initialized = true;
          // Use a post-frame callback to ensure the widget is fully built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeServices(context);
          });
        }
        return widget.child;
      },
    );
  }

  Future<void> _initializeServices(BuildContext context) async {
    try {
      // Get the location service initializer provider
      final initializer = Provider.of<LocationServiceInitializerProvider>(
        context,
        listen: false,
      );

      // Initialize the location service
      await initializer.initialize(context);
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error initializing services: $e');
    }
  }
}
