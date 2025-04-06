import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ndao/core/infrastructure/appwrite/appwrite_client.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:ndao/user/domain/interactors/upload_profile_photo_interactor.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';
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

      // Get current user interactor
      ProxyProvider<AuthRepository, GetCurrentUserInteractor>(
        update: (_, authRepository, __) =>
            GetCurrentUserInteractor(authRepository),
      ),
    ];
  }
}
