import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ndao/core/infrastructure/appwrite/appwrite_client.dart';
import 'package:ndao/home/presentation/home_page.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/location/infrastructure/providers/geo_locator_provider.dart';
import 'package:ndao/user/domain/interactors/login_interactor.dart';
import 'package:ndao/user/domain/interactors/register_user_interactor.dart';
import 'package:ndao/user/domain/interactors/upload_profile_photo_interactor.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';
import 'package:ndao/user/domain/repositories/storage_repository.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:ndao/user/infrastructure/repositories/appwrite_auth_repository.dart';
import 'package:ndao/user/infrastructure/repositories/appwrite_storage_repository.dart';
import 'package:ndao/user/infrastructure/repositories/appwrite_user_repository.dart';
import 'package:ndao/user/presentation/pages/driver_registration_page.dart';
import 'package:ndao/user/presentation/pages/login_page.dart';
import 'package:ndao/user/presentation/pages/registration_page.dart';
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
      providers: [
        // Location provider
        Provider<LocatorProvider>(create: (_) => GeoLocatorProvider()),

        // Appwrite clients
        Provider<AppwriteClientInitializer>(
          create: (_) => AppwriteClientInitializer.instance,
        ),

        // User repository
        Provider<UserRepository>(
          create: (context) => AppwriteUserRepository(
            AppwriteClientInitializer.instance.databases,
            databaseId: dotenv.env['APPWRITE_DATABASE_ID'] ?? 'ndao',
            usersCollectionId:
                dotenv.env['APPWRITE_USERS_COLLECTION_ID'] ?? 'users',
            userRolesCollectionId:
                dotenv.env['APPWRITE_USER_ROLES_COLLECTION_ID'] ?? 'user_roles',
            driverDetailsCollectionId:
                dotenv.env['APPWRITE_DRIVER_DETAILS_COLLECTION_ID'] ??
                    'driver_details',
            clientDetailsCollectionId:
                dotenv.env['APPWRITE_CLIENT_DETAILS_COLLECTION_ID'] ??
                    'client_details',
          ),
        ),

        // Storage repository
        Provider<StorageRepository>(
          create: (context) => AppwriteStorageRepository(
            AppwriteClientInitializer.instance.storage,
            profilePhotosBucketId:
                dotenv.env['APPWRITE_PROFILE_PHOTOS_BUCKET_ID'] ??
                    'profile_photos',
          ),
        ),

        // Auth repository
        ProxyProvider<UserRepository, AuthRepository>(
          update: (_, userRepository, __) => AppwriteAuthRepository(
            AppwriteClientInitializer.instance.account,
            userRepository,
          ),
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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50), // Green color for Ndao
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4CAF50),
              side: const BorderSide(color: Color(0xFF4CAF50)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
          ),
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
