import 'dart:io';
import 'dart:typed_data';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:ndao/user/infrastructure/repositories/queries/storage_queries.dart';
import 'package:path/path.dart' as path;

/// Class responsible for write operations related to storage
class StorageCommands {
  final Storage _storage;
  final StorageQueries _storageQueries;

  /// Bucket ID for profile photos
  final String _profilePhotosBucketId;

  /// Creates a new StorageCommands with the given storage client
  StorageCommands(
    this._storage,
    this._storageQueries, {
    String profilePhotosBucketId = 'profile_photos',
  }) : _profilePhotosBucketId = profilePhotosBucketId;

  /// Upload a profile photo for a user
  ///
  /// [userId] The ID of the user
  /// [photoFile] The photo file to upload
  /// Returns the URL of the uploaded photo
  Future<String> uploadProfilePhoto(String userId, File photoFile) async {
    try {
      // Get the file name and extension
      final fileName = path.basename(photoFile.path);
      final fileId =
          '${userId}_profile_${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Upload the file
      final result = await _storage.createFile(
        bucketId: _profilePhotosBucketId,
        fileId: fileId,
        file: InputFile.fromPath(path: photoFile.path),
      );

      // Get the file URL using the query service
      final fileUrl = await _storageQueries.getFileUrl(result.$id);

      return fileUrl;
    } on AppwriteException catch (e) {
      throw Exception('Failed to upload profile photo: ${e.message}');
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
      // Generate a unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileId = '$timestamp';
      final fileName = '$timestamp$fileExtension';

      // Upload the file
      models.File result;
      try {
        final inputFile =
            InputFile.fromBytes(bytes: photoBytes, filename: fileName);

        result = await _storage.createFile(
          bucketId: _profilePhotosBucketId,
          fileId: fileId,
          file: inputFile,
          permissions: [
            Permission.read(Role.any()),
            Permission.write(Role.user(userId)),
          ],
        );
      } catch (uploadError) {
        rethrow;
      }

      // Get the file URL using the query service
      final fileUrl = await _storageQueries.getFileUrl(result.$id);

      return fileUrl;
    } on AppwriteException catch (e) {
      throw Exception(
          'Failed to upload profile photo: ${e.message} (code: ${e.code})');
    } catch (e) {
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }

  /// Delete a profile photo for a user
  ///
  /// [userId] The ID of the user
  /// [fileName] The name of the file to delete (optional)
  Future<void> deleteProfilePhoto(String userId, {String? fileName}) async {
    try {
      if (fileName != null) {
        // Delete a specific file
        await _storage.deleteFile(
          bucketId: _profilePhotosBucketId,
          fileId: fileName,
        );
      } else {
        // List all files for the user
        final response = await _storage.listFiles(
          bucketId: _profilePhotosBucketId,
          queries: [Query.search('name', '${userId}_')],
        );

        // Delete each file
        for (final file in response.files) {
          await _storage.deleteFile(
            bucketId: _profilePhotosBucketId,
            fileId: file.$id,
          );
        }
      }
    } on AppwriteException catch (e) {
      throw Exception('Failed to delete profile photo: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete profile photo: ${e.toString()}');
    }
  }
}
