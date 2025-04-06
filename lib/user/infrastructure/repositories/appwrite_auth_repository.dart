import 'package:appwrite/appwrite.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

/// Implementation of AuthRepository using Appwrite
class AppwriteAuthRepository implements AuthRepository {
  final Account _account;
  final UserRepository _userRepository;

  /// Creates a new AppwriteAuthRepository with the given account client
  AppwriteAuthRepository(this._account, this._userRepository);

  @override
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // Sign in with email and password
      final session = await _account.createEmailSession(
        email: email,
        password: password,
      );

      return session.userId;
    } on AppwriteException catch (e) {
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<String> signUpWithEmailAndPassword(
    String givenName,
    String familyName,
    String email,
    String phoneNumber,
    String password,
  ) async {
    try {
      // Create a new account
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: '$givenName $familyName',
      );

      // Create a user entity
      final userEntity = UserEntity(
        id: user.$id,
        givenName: givenName,
        familyName: familyName,
        email: email,
        phoneNumber: phoneNumber,
        roles: ['client'],
      );

      // Save the user entity
      await _userRepository.saveUser(userEntity);

      return user.$id;
    } on AppwriteException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<String> signUpDriverWithEmailAndPassword(
    String givenName,
    String familyName,
    String email,
    String phoneNumber,
    String password,
  ) async {
    try {
      // Create a new account
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: '$givenName $familyName',
      );

      // Create a user entity with driver role
      final userEntity = UserEntity(
        id: user.$id,
        givenName: givenName,
        familyName: familyName,
        email: email,
        phoneNumber: phoneNumber,
        roles: ['driver'],
        driverDetails: DriverDetails(),
      );

      // Save the user entity
      await _userRepository.saveUser(userEntity);

      return user.$id;
    } on AppwriteException catch (e) {
      throw Exception('Driver registration failed: ${e.message}');
    } catch (e) {
      throw Exception('Driver registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Get the current session
      final session = await _account.getSession(sessionId: 'current');

      // Delete the session
      await _account.deleteSession(sessionId: session.$id);
    } on AppwriteException catch (e) {
      throw Exception('Sign out failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      // Get the current user
      final user = await _account.get();

      // Get the user entity from the repository
      return await _userRepository.getUserById(user.$id);
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        // User is not authenticated
        return null;
      }
      throw Exception('Failed to get current user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      // Try to get the current session
      await _account.getSession(sessionId: 'current');
      return true;
    } catch (e) {
      return false;
    }
  }
}
