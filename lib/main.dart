import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ndao/firebase_options.dart';
import 'package:ndao/user/domain/repositories/storage_repository.dart';
import 'package:ndao/user/infrastructure/repositories/firebase_storage_repository.dart';
import 'package:ndao/home/presentation/home_page.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/location/infrastructure/providers/geo_locator_provider.dart';
import 'package:ndao/user/domain/interactors/login_interactor.dart';
import 'package:ndao/user/domain/interactors/register_user_interactor.dart';
import 'package:ndao/user/domain/interactors/upload_profile_photo_interactor.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:ndao/user/infrastructure/repositories/firebase_auth_repository.dart';
import 'package:ndao/user/infrastructure/repositories/firebase_user_repository.dart';
import 'package:ndao/user/presentation/pages/driver_registration_page.dart';
import 'package:ndao/user/presentation/pages/login_page.dart';
import 'package:ndao/user/presentation/pages/registration_page.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter is initialized before using platform plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

        // Firebase instances
        Provider<FirebaseAuth>(
          create: (_) => FirebaseAuth.instance,
        ),
        Provider<FirebaseFirestore>(
          create: (_) => FirebaseFirestore.instance,
        ),
        Provider<FirebaseStorage>(
          create: (_) => FirebaseStorage.instance,
        ),

        // Auth repository
        ProxyProvider<FirebaseAuth, AuthRepository>(
          update: (_, firebaseAuth, __) => FirebaseAuthRepository(firebaseAuth),
        ),

        // User repository
        ProxyProvider<FirebaseFirestore, UserRepository>(
          update: (_, firestore, __) => FirebaseUserRepository(firestore),
        ),

        // Storage repository
        ProxyProvider<FirebaseStorage, StorageRepository>(
          update: (_, storage, __) => FirebaseStorageRepository(storage),
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
