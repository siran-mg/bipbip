import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling file storage operations with Supabase
class StorageService {
  final SupabaseClient _client;
  final String _profilePhotosBucket = 'profile_photos';

  /// Creates a new StorageService with the given client
  StorageService(this._client);

  /// Upload a profile photo for a user
  ///
  /// [userId] The ID of the user
  /// [photoFile] The photo file to upload
  /// Returns the URL of the uploaded photo
  Future<String> uploadProfilePhoto(String userId, File photoFile) async {
    try {
      final fileExtension = path.extension(photoFile.path);
      final fileName = 'profile$fileExtension';
      final filePath = '$userId/$fileName';

      // Upload the file
      await _client.storage.from(_profilePhotosBucket).upload(
          filePath, photoFile,
          fileOptions: const FileOptions(upsert: true));

      // Get the public URL
      final url =
          _client.storage.from(_profilePhotosBucket).getPublicUrl(filePath);

      return url;
    } catch (e) {
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }

  /// Upload a profile photo from bytes for a user
  ///
  /// [userId] The ID of the user
  /// [photoBytes] The photo bytes to upload
  /// [fileExtension] The file extension (e.g., '.jpg', '.png')
  /// Returns the URL of the uploaded photo
  Future<String> uploadProfilePhotoBytes(
      String userId, Uint8List photoBytes, String fileExtension) async {
    try {
      final fileName = 'profile$fileExtension';
      final filePath = '$userId/$fileName';

      // Upload the file
      await _client.storage.from(_profilePhotosBucket).uploadBinary(
          filePath, photoBytes,
          fileOptions: const FileOptions(upsert: true));

      // Get the public URL
      final url =
          _client.storage.from(_profilePhotosBucket).getPublicUrl(filePath);

      return url;
    } catch (e) {
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }

  /// Delete a profile photo for a user
  ///
  /// [userId] The ID of the user
  /// [fileName] The name of the file to delete (optional, defaults to 'profile.*')
  Future<void> deleteProfilePhoto(String userId, {String? fileName}) async {
    try {
      if (fileName != null) {
        final filePath = '$userId/$fileName';
        await _client.storage.from(_profilePhotosBucket).remove([filePath]);
      } else {
        // List all files in the user's folder
        final List<FileObject> files =
            await _client.storage.from(_profilePhotosBucket).list(path: userId);

        // Filter for profile photos
        final profilePhotos =
            files.where((file) => file.name.startsWith('profile')).toList();

        // Delete all profile photos
        if (profilePhotos.isNotEmpty) {
          final filePaths =
              profilePhotos.map((file) => '$userId/${file.name}').toList();
          await _client.storage.from(_profilePhotosBucket).remove(filePaths);
        }
      }
    } catch (e) {
      throw Exception('Failed to delete profile photo: ${e.toString()}');
    }
  }

  /// Get the profile photo URL for a user
  ///
  /// [userId] The ID of the user
  /// Returns the URL of the profile photo, or null if not found
  Future<String?> getProfilePhotoUrl(String userId) async {
    try {
      // List all files in the user's folder
      final List<FileObject> files =
          await _client.storage.from(_profilePhotosBucket).list(path: userId);

      // Filter for profile photos
      final profilePhotos =
          files.where((file) => file.name.startsWith('profile')).toList();

      if (profilePhotos.isNotEmpty) {
        // Just use the first profile photo found
        final filePath = '$userId/${profilePhotos.first.name}';
        return _client.storage
            .from(_profilePhotosBucket)
            .getPublicUrl(filePath);
      }

      return null;
    } catch (e) {
      // Return null if there's an error (e.g., folder doesn't exist)
      return null;
    }
  }
}
