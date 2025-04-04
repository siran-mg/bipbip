import 'dart:io';
import 'dart:typed_data';
import 'package:ndao/core/infrastructure/supabase/storage_service.dart';
import 'package:ndao/user/domain/repositories/storage_repository.dart';

/// Implementation of StorageRepository using Supabase
class SupabaseStorageRepository implements StorageRepository {
  final StorageService _storageService;

  /// Creates a new SupabaseStorageRepository with the given storage service
  SupabaseStorageRepository(this._storageService);

  @override
  Future<String> uploadProfilePhoto(String userId, File photoFile) {
    return _storageService.uploadProfilePhoto(userId, photoFile);
  }

  @override
  Future<String> uploadProfilePhotoBytes(
      String userId, Uint8List photoBytes, String fileExtension) {
    return _storageService.uploadProfilePhotoBytes(userId, photoBytes, fileExtension);
  }

  @override
  Future<void> deleteProfilePhoto(String userId, {String? fileName}) {
    return _storageService.deleteProfilePhoto(userId, fileName: fileName);
  }

  @override
  Future<String?> getProfilePhotoUrl(String userId) {
    return _storageService.getProfilePhotoUrl(userId);
  }
}
