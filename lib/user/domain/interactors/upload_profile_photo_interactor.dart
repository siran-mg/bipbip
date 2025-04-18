import 'dart:io';
import 'dart:typed_data';
import 'package:ndao/user/domain/repositories/storage_repository.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

/// Interactor for uploading a profile photo
class UploadProfilePhotoInteractor {
  final StorageRepository _storageRepository;
  final UserRepository _userRepository;

  /// Creates a new UploadProfilePhotoInteractor with the given repositories
  UploadProfilePhotoInteractor({
    required StorageRepository storageRepository,
    required UserRepository userRepository,
  })  : _storageRepository = storageRepository,
        _userRepository = userRepository;

  /// Execute the upload profile photo operation
  ///
  /// [userId] The ID of the user
  /// [photoFile] The photo file to upload
  /// Returns the URL of the uploaded photo
  Future<String> execute(String userId, File photoFile) async {
    try {
      // Get the current user
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Upload the photo
      final photoUrl =
          await _storageRepository.uploadProfilePhoto(userId, photoFile);

      // Update the user with the new photo URL
      final updatedUser = user.copyWith(profilePictureUrl: photoUrl);
      await _userRepository.updateUser(updatedUser);

      return photoUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }

  /// Execute the upload profile photo operation with bytes (for web platform)
  ///
  /// [userId] The ID of the user
  /// [photoBytes] The photo bytes to upload
  /// [fileExtension] The file extension (e.g., '.jpg', '.png')
  /// Returns the URL of the uploaded photo
  Future<String> executeWithBytes(
      String userId, Uint8List photoBytes, String fileExtension) async {
    try {
      // Get the current user
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Upload the photo
      final photoUrl = await _storageRepository.uploadProfilePhotoBytes(
          userId, photoBytes, fileExtension);

      // Update the user with the new photo URL
      final updatedUser = user.copyWith(profilePictureUrl: photoUrl);
      await _userRepository.updateUser(updatedUser);

      return photoUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }
}
