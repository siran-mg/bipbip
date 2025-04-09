import 'dart:io';
import 'dart:typed_data';
import 'package:appwrite/appwrite.dart';
import 'package:ndao/user/domain/repositories/storage_repository.dart';
import 'package:ndao/user/infrastructure/repositories/commands/storage_commands.dart';
import 'package:ndao/user/infrastructure/repositories/queries/storage_queries.dart';

/// Implementation of StorageRepository using Appwrite with Command Query Separation
class AppwriteStorageRepository implements StorageRepository {
  late final StorageQueries _storageQueries;
  late final StorageCommands _storageCommands;

  /// Creates a new AppwriteStorageRepository with the given storage client
  AppwriteStorageRepository(
    Storage storage, {
    String profilePhotosBucketId = 'profile_photos',
  }) {
    _storageQueries = StorageQueries(
      storage,
      profilePhotosBucketId: profilePhotosBucketId,
    );

    _storageCommands = StorageCommands(
      storage,
      _storageQueries,
      profilePhotosBucketId: profilePhotosBucketId,
    );
  }

  @override
  Future<String> uploadProfilePhoto(String userId, File photoFile) {
    return _storageCommands.uploadProfilePhoto(userId, photoFile);
  }

  @override
  Future<String> uploadProfilePhotoBytes(
      String userId, Uint8List photoBytes, String fileExtension) {
    return _storageCommands.uploadProfilePhotoBytes(
        userId, photoBytes, fileExtension);
  }

  @override
  Future<void> deleteProfilePhoto(String userId, {String? fileName}) {
    return _storageCommands.deleteProfilePhoto(userId, fileName: fileName);
  }

  @override
  Future<String?> getProfilePhotoUrl(String userId) {
    return _storageQueries.getProfilePhotoUrl(userId);
  }
}
