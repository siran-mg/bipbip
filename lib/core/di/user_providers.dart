import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ndao/location/domain/providers/locator_provider.dart';
import 'package:ndao/user/domain/interactors/update_driver_availability_interactor.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:ndao/user/domain/interactors/update_driver_rating_interactor.dart';
import 'package:ndao/user/domain/interactors/update_user_interactor.dart';
import 'package:ndao/user/domain/interactors/upload_profile_photo_interactor.dart';
import 'package:ndao/user/domain/providers/driver_provider.dart';
import 'package:ndao/user/domain/providers/favorite_drivers_provider.dart';
import 'package:ndao/user/domain/providers/user_profile_provider.dart';
import 'package:ndao/user/domain/repositories/favorite_driver_repository.dart';
import 'package:ndao/user/domain/repositories/storage_repository.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

/// Provides user-related dependencies
class UserProviders {
  /// Get all user providers
  static List<SingleChildWidget> getProviders() {
    return [
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

      // Favorite drivers provider
      ChangeNotifierProxyProvider2<FavoriteDriverRepository,
          GetCurrentUserInteractor, FavoriteDriversProvider>(
        create: (context) => FavoriteDriversProvider(
          favoriteDriverRepository: context.read<FavoriteDriverRepository>(),
          getCurrentUserInteractor: context.read<GetCurrentUserInteractor>(),
        ),
        update: (context, favoriteDriverRepository, getCurrentUserInteractor,
            previous) {
          return previous ??
              FavoriteDriversProvider(
                favoriteDriverRepository: favoriteDriverRepository,
                getCurrentUserInteractor: getCurrentUserInteractor,
              );
        },
      ),
    ];
  }
}
