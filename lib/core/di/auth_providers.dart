import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ndao/core/infrastructure/appwrite/appwrite_client.dart';
import 'package:ndao/user/domain/interactors/forgot_password_interactor.dart';
import 'package:ndao/user/domain/interactors/get_current_user_interactor.dart';
import 'package:ndao/user/domain/interactors/login_interactor.dart';
import 'package:ndao/user/domain/interactors/logout_interactor.dart';
import 'package:ndao/user/domain/interactors/register_user_interactor.dart';
import 'package:ndao/user/domain/interactors/vehicle_interactor.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:ndao/user/infrastructure/repositories/appwrite_auth_repository.dart';

/// Provides authentication-related dependencies
class AuthProviders {
  /// Get all auth providers
  static List<SingleChildWidget> getProviders() {
    return [
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

      ProxyProvider<AuthRepository, LogoutInteractor>(
        update: (_, repository, __) => LogoutInteractor(repository),
      ),

      ProxyProvider<AuthRepository, ForgotPasswordInteractor>(
        update: (_, repository, __) => ForgotPasswordInteractor(repository),
      ),

      // Get current user interactor
      ProxyProvider<AuthRepository, GetCurrentUserInteractor>(
        update: (_, repository, __) => GetCurrentUserInteractor(repository),
      ),

      // User registration interactor
      ProxyProvider3<AuthRepository, UserRepository, VehicleInteractor,
          RegisterUserInteractor>(
        update: (_, authRepository, userRepository, vehicleInteractor, __) =>
            RegisterUserInteractor(
                authRepository, userRepository, vehicleInteractor),
      ),
    ];
  }
}
