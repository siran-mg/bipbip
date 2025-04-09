import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Class responsible for read-only operations related to storage
class StorageQueries {
  final Storage _storage;

  /// Bucket ID for profile photos
  final String _profilePhotosBucketId;

  /// Creates a new StorageQueries with the given storage client
  StorageQueries(
    this._storage, {
    String profilePhotosBucketId = 'profile_photos',
  }) : _profilePhotosBucketId = profilePhotosBucketId;

  /// Get the profile photo URL for a user
  ///
  /// [userId] The ID of the user
  /// Returns the URL of the profile photo, or null if not found
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

      return await getFileUrl(mostRecentFile.$id);
    } on AppwriteException {
      // If there's an error (e.g., no files), return null
      return null;
    } catch (_) {
      // If there's any other error, return null
      return null;
    }
  }

  /// Get the URL of a file
  Future<String> getFileUrl(String fileId) async {
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
