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
import 'package:ndao/user/domain/interactors/login_interactor.dart';
import 'package:ndao/user/domain/interactors/register_user_interactor.dart';
import 'package:ndao/user/domain/interactors/upload_profile_photo_interactor.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:ndao/user/infrastructure/repositories/supabase_auth_repository.dart';
import 'package:ndao/user/infrastructure/repositories/supabase_user_repository.dart';
import 'package:ndao/user/presentation/pages/driver_registration_page.dart';
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

        // User repository
        Provider<UserRepository>(
          create: (_) => SupabaseUserRepository(
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

        // User registration interactor
        ProxyProvider2<AuthRepository, UserRepository, RegisterUserInteractor>(
          update: (_, authRepository, userRepository, __) =>
              RegisterUserInteractor(authRepository, userRepository),
        ),

        // Profile photo interactor
        ProxyProvider2<StorageRepository, UserRepository,
            UploadProfilePhotoInteractor>(
          update: (_, storageRepository, userRepository, __) =>
              UploadProfilePhotoInteractor(
            storageRepository: storageRepository,
            userRepository: userRepository,
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
          '/driver-register': (context) => const DriverRegistrationPage(),
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
