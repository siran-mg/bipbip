import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository(this._firebaseAuth);

  @override
  Future<bool> isAuthenticated() async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Login failed: User is null');
      }

      return userCredential.user!.uid;
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
      // Create the user with email and password
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Registration failed: User is null');
      }

      // Update the user's display name
      await userCredential.user!.updateDisplayName('$givenName $familyName');

      // Set custom user claims (metadata)
      await userCredential.user!.updatePhotoURL('');

      return userCredential.user!.uid;
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
    // For Firebase, we'll use the same method but add a user type field in Firestore
    return signUpWithEmailAndPassword(
      givenName,
      familyName,
      email,
      phoneNumber,
      password,
    );
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    // In a real implementation, you would fetch additional user data from Firestore
    // This is a simplified version
    final nameParts = firebaseUser.displayName?.split(' ') ?? ['', ''];
    final givenName = nameParts.first;
    final familyName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return UserEntity(
      id: firebaseUser.uid,
      givenName: givenName,
      familyName: familyName,
      email: firebaseUser.email ?? '',
      phoneNumber: firebaseUser.phoneNumber ?? '',
      profilePictureUrl: firebaseUser.photoURL,
      roles: [], // You'll need to fetch roles from Firestore
    );
  }
}
