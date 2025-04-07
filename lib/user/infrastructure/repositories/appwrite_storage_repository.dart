import 'dart:io';
import 'dart:typed_data';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ndao/user/domain/repositories/storage_repository.dart';
import 'package:path/path.dart' as path;

/// Implementation of StorageRepository using Appwrite
class AppwriteStorageRepository implements StorageRepository {
  final Storage _storage;

  /// Bucket ID for profile photos
  final String _profilePhotosBucketId;

  /// Creates a new AppwriteStorageRepository with the given storage client
  AppwriteStorageRepository(
    this._storage, {
    String profilePhotosBucketId = 'profile_photos',
  }) : _profilePhotosBucketId = profilePhotosBucketId;

  @override
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

      // Get the file URL
      final fileUrl = await _getFileUrl(result.$id);

      return fileUrl;
    } on AppwriteException catch (e) {
      throw Exception('Failed to upload profile photo: ${e.message}');
    } catch (e) {
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }

  @override
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

      // Get the file URL
      final fileUrl = await _getFileUrl(result.$id);

      return fileUrl;
    } on AppwriteException catch (e) {
      throw Exception(
          'Failed to upload profile photo: ${e.message} (code: ${e.code})');
    } catch (e) {
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }

  @override
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

  @override
  Future<String?> getProfilePhotoUrl(String userId) async {
    try {
      // List all files for the user
      final response = await _storage.listFiles(
        bucketId: _profilePhotosBucketId,
        queries: [Query.search('name', '${userId}_')],
      );

      if (response.files.isEmpty) {
        return null;
      }

      // Get the URL of the most recent file
      final mostRecentFile = response.files.reduce((a, b) =>
          DateTime.parse(a.$createdAt).isAfter(DateTime.parse(b.$createdAt))
              ? a
              : b);

      return await _getFileUrl(mostRecentFile.$id);
    } on AppwriteException {
      // If there's an error (e.g., no files), return null
      return null;
    } catch (_) {
      // If there's any other error, return null
      return null;
    }
  }

  /// Get the URL of a file
  Future<String> _getFileUrl(String fileId) async {
    try {
      // Get the endpoint from environment variables or use default
      String endpoint =
          dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1';
      final projectId = dotenv.env['APPWRITE_PROJECT_ID'] ??
          _storage.client.config['project'];

      // Remove '/v1' from the end if it exists to avoid double paths
      if (endpoint.endsWith('/v1')) {
        endpoint = endpoint.substring(0, endpoint.length - 3);
      }

      // Remove trailing slash if it exists
      if (endpoint.endsWith('/')) {
        endpoint = endpoint.substring(0, endpoint.length - 1);
      }

      // Format: https://ENDPOINT/v1/storage/buckets/BUCKET_ID/files/FILE_ID/view?project=PROJECT_ID
      final url =
          '$endpoint/v1/storage/buckets/$_profilePhotosBucketId/files/$fileId/view?project=$projectId&mode=admin';

      return url;
    } catch (e) {
      throw Exception('Failed to get file URL: ${e.toString()}');
    }
  }
}
