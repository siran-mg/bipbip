import 'dart:io';
import 'dart:typed_data';

/// Repository interface for storage operations
abstract class StorageRepository {
  /// Upload a profile photo for a user
  /// 
  /// [userId] The ID of the user
  /// [photoFile] The photo file to upload
  /// Returns the URL of the uploaded photo
  Future<String> uploadProfilePhoto(String userId, File photoFile);
  
  /// Upload a profile photo from bytes for a user
  /// 
  /// [userId] The ID of the user
  /// [photoBytes] The photo bytes to upload
  /// [fileExtension] The file extension (e.g., '.jpg', '.png')
  /// Returns the URL of the uploaded photo
  Future<String> uploadProfilePhotoBytes(
      String userId, Uint8List photoBytes, String fileExtension);
  
  /// Delete a profile photo for a user
  /// 
  /// [userId] The ID of the user
  /// [fileName] The name of the file to delete (optional)
  Future<void> deleteProfilePhoto(String userId, {String? fileName});
  
  /// Get the profile photo URL for a user
  /// 
  /// [userId] The ID of the user
  /// Returns the URL of the profile photo, or null if not found
  Future<String?> getProfilePhotoUrl(String userId);
}
