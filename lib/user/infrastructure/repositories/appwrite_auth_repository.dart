import 'package:appwrite/appwrite.dart';
import 'package:ndao/core/infrastructure/storage/session_storage.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:ndao/user/infrastructure/repositories/commands/auth_commands.dart';
import 'package:ndao/user/infrastructure/repositories/queries/auth_queries.dart';

/// Implementation of AuthRepository using Appwrite with Command Query Separation
class AppwriteAuthRepository implements AuthRepository {
  late final AuthQueries _authQueries;
  late final AuthCommands _authCommands;

  /// Creates a new AppwriteAuthRepository with the given account client
  AppwriteAuthRepository(Account account, UserRepository userRepository,
      SessionStorage sessionStorage) {
    _authQueries = AuthQueries(account, userRepository, sessionStorage);
    _authCommands = AuthCommands(account, userRepository, sessionStorage);
  }

  @override
  Future<String> signInWithEmailAndPassword(String email, String password) {
    return _authCommands.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<String> signUpWithEmailAndPassword(
    String givenName,
    String familyName,
    String email,
    String phoneNumber,
    String password,
  ) {
    return _authCommands.signUpWithEmailAndPassword(
      givenName,
      familyName,
      email,
      phoneNumber,
      password,
    );
  }

  @override
  Future<String> signUpDriverWithEmailAndPassword(
    String givenName,
    String familyName,
    String email,
    String phoneNumber,
    String password,
  ) {
    return _authCommands.signUpDriverWithEmailAndPassword(
      givenName,
      familyName,
      email,
      phoneNumber,
      password,
    );
  }

  @override
  Future<void> signOut() {
    return _authCommands.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return _authQueries.getCurrentUser();
  }

  @override
  Future<bool> isAuthenticated() {
    return _authQueries.isAuthenticated();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _authCommands.sendPasswordResetEmail(email);
  }
}
