import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ndao/core/di/app_providers.dart';
import 'package:ndao/core/infrastructure/appwrite/appwrite_client.dart';
import 'package:ndao/core/presentation/routes/app_routes.dart';
import 'package:ndao/core/presentation/theme/app_theme.dart';
import 'package:ndao/location/infrastructure/services/location_tracking_service_manager.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize location tracking service after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocationTracking();
    });
  }

  Future<void> _initializeLocationTracking() async {
    try {
      // Get the location tracking service manager
      final serviceManager = Provider.of<LocationTrackingServiceManager>(
        context,
        listen: false,
      );

      // Initialize the service
      await serviceManager.initialize();
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Error initializing location tracking: $e');
    }
  }

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
      ),
    );
  }
}
