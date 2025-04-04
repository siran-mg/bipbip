import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ndao/core/infrastructure/supabase/supabase_client.dart'
    as supabase_init;
import 'package:ndao/core/infrastructure/supabase/storage_service.dart';
import 'package:ndao/user/domain/repositories/storage_repository.dart';
import 'package:ndao/user/infrastructure/repositories/supabase_storage_repository.dart';
import 'package:ndao/home/presentation/home_page.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/location/infrastructure/providers/geo_locator_provider.dart';
import 'package:ndao/user/domain/interactors/get_available_drivers_interactor.dart';
import 'package:ndao/user/domain/interactors/get_client_interactor.dart';
import 'package:ndao/user/domain/interactors/login_interactor.dart';
import 'package:ndao/user/domain/interactors/register_interactor.dart';
import 'package:ndao/user/domain/interactors/save_client_interactor.dart';
import 'package:ndao/user/domain/interactors/save_driver_interactor.dart';
import 'package:ndao/user/domain/interactors/upload_profile_photo_interactor.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';
import 'package:ndao/user/domain/repositories/client_repository.dart';
import 'package:ndao/user/domain/repositories/driver_repository.dart';
import 'package:ndao/user/infrastructure/repositories/supabase_auth_repository.dart';
import 'package:ndao/user/infrastructure/repositories/supabase_client_repository.dart';
import 'package:ndao/user/infrastructure/repositories/supabase_driver_repository.dart';
import 'package:ndao/user/presentation/pages/login_page.dart';
import 'package:ndao/user/presentation/pages/registration_page.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter is initialized before using platform plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await supabase_init.SupabaseClientInitializer.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Location provider
        Provider<LocatorProvider>(create: (_) => GeoLocatorProvider()),

        // Auth repository
        Provider<AuthRepository>(
          create: (_) => SupabaseAuthRepository(
              supabase_init.SupabaseClientInitializer.instance),
        ),

        // Client repository
        Provider<ClientRepository>(
          create: (_) => SupabaseClientRepository(
              supabase_init.SupabaseClientInitializer.instance),
        ),

        // Driver repository
        Provider<DriverRepository>(
          create: (_) => SupabaseDriverRepository(
              supabase_init.SupabaseClientInitializer.instance),
        ),

        // Storage service
        Provider<StorageService>(
          create: (_) =>
              StorageService(supabase_init.SupabaseClientInitializer.instance),
        ),

        // Storage repository
        ProxyProvider<StorageService, StorageRepository>(
          update: (_, storageService, __) =>
              SupabaseStorageRepository(storageService),
        ),

        // Auth interactors
        ProxyProvider<AuthRepository, LoginInteractor>(
          update: (_, repository, __) => LoginInteractor(repository),
        ),
        ProxyProvider<AuthRepository, RegisterInteractor>(
          update: (_, repository, __) => RegisterInteractor(repository),
        ),

        // Client interactors
        ProxyProvider<ClientRepository, GetClientInteractor>(
          update: (_, repository, __) => GetClientInteractor(repository),
        ),
        ProxyProvider<ClientRepository, SaveClientInteractor>(
          update: (_, repository, __) => SaveClientInteractor(repository),
        ),

        // Driver interactors
        ProxyProvider<DriverRepository, GetAvailableDriversInteractor>(
          update: (_, repository, __) =>
              GetAvailableDriversInteractor(repository),
        ),
        ProxyProvider<DriverRepository, SaveDriverInteractor>(
          update: (_, repository, __) => SaveDriverInteractor(repository),
        ),

        // Profile photo interactor
        Provider<UploadProfilePhotoInteractor>(
          create: (context) => UploadProfilePhotoInteractor(
            storageRepository:
                Provider.of<StorageRepository>(context, listen: false),
            clientRepository:
                Provider.of<ClientRepository>(context, listen: false),
            driverRepository:
                Provider.of<DriverRepository>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Ndao',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegistrationPage(),
          '/home': (context) => Scaffold(
                body: const HomePage(),
                bottomNavigationBar: BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Accueil',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
        },
      ),
    );
  }
}
