import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ndao/core/infrastructure/appwrite/appwrite_client.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/user/domain/interactors/update_driver_availability_interactor.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:ndao/user/domain/interactors/update_driver_rating_interactor.dart';
import 'package:ndao/user/domain/interactors/update_user_interactor.dart';
import 'package:ndao/user/domain/interactors/upload_profile_photo_interactor.dart';
import 'package:ndao/user/domain/providers/driver_provider.dart';
import 'package:ndao/user/domain/providers/user_profile_provider.dart';
import 'package:ndao/user/domain/repositories/storage_repository.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:ndao/user/domain/repositories/vehicle_repository.dart';
import 'package:ndao/user/infrastructure/repositories/appwrite_storage_repository.dart';
import 'package:ndao/user/infrastructure/repositories/appwrite_user_repository.dart';

/// Provides user-related dependencies
class UserProviders {
  /// Get all user providers
  static List<SingleChildWidget> getProviders() {
    return [
      // User repository
      ProxyProvider<VehicleRepository, UserRepository>(
        update: (_, vehicleRepository, __) => AppwriteUserRepository(
          AppwriteClientInitializer.instance.databases,
          vehicleRepository,
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

      // Profile photo interactor
      ProxyProvider2<StorageRepository, UserRepository,
          UploadProfilePhotoInteractor>(
        update: (_, storageRepository, userRepository, __) =>
            UploadProfilePhotoInteractor(
          storageRepository: storageRepository,
          userRepository: userRepository,
        ),
      ),

      // Driver availability interactor
      ProxyProvider<UserRepository, UpdateDriverAvailabilityInteractor>(
        update: (_, userRepository, __) =>
            UpdateDriverAvailabilityInteractor(userRepository),
      ),

      // User update interactor
      ProxyProvider<UserRepository, UpdateUserInteractor>(
        update: (_, userRepository, __) => UpdateUserInteractor(userRepository),
      ),

      // Driver rating update interactor
      ProxyProvider<UserRepository, UpdateDriverRatingInteractor>(
        update: (_, userRepository, __) =>
            UpdateDriverRatingInteractor(userRepository),
      ),

      // Driver provider
      ChangeNotifierProxyProvider2<UserRepository, LocatorProvider,
          DriverProvider>(
        create: (context) => DriverProvider(
          userRepository: context.read<UserRepository>(),
          locatorProvider: context.read<LocatorProvider>(),
        ),
        update: (context, userRepository, locatorProvider, previous) {
          return previous ??
              DriverProvider(
                userRepository: userRepository,
                locatorProvider: locatorProvider,
              );
        },
      ),

      // User profile provider
      ChangeNotifierProxyProvider2<GetCurrentUserInteractor,
          UpdateUserInteractor, UserProfileProvider>(
        create: (context) => UserProfileProvider(
          getCurrentUserInteractor: context.read<GetCurrentUserInteractor>(),
          updateUserInteractor: context.read<UpdateUserInteractor>(),
        ),
        update: (context, getCurrentUserInteractor, updateUserInteractor,
            previous) {
          return previous ??
              UserProfileProvider(
                getCurrentUserInteractor: getCurrentUserInteractor,
                updateUserInteractor: updateUserInteractor,
              );
        },
      ),
    ];
  }
}
