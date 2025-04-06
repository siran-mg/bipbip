import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ndao/core/di/app_providers.dart';
import 'package:ndao/core/infrastructure/appwrite/appwrite_client.dart';
import 'package:ndao/core/presentation/routes/app_routes.dart';
import 'package:ndao/core/presentation/theme/app_theme.dart';
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
      ),
    );
  }
}
