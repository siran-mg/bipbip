import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ndao/user/domain/repositories/storage_repository.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageRepository implements StorageRepository {
  final FirebaseStorage _storage;
  
  FirebaseStorageRepository(this._storage);
  
  @override
  Future<String> uploadProfilePhoto(String userId, File photoFile) async {
    try {
      final fileName = path.basename(photoFile.path);
      final storageRef = _storage.ref().child('profile_photos/$userId/$fileName');
      
      // Upload the file
      await storageRef.putFile(photoFile);
      
      // Get the download URL
      final downloadUrl = await storageRef.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }
  
  @override
  Future<String> uploadProfilePhotoBytes(
      String userId, Uint8List photoBytes, String fileExtension) async {
    try {
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final storageRef = _storage.ref().child('profile_photos/$userId/$fileName');
      
      // Upload the bytes
      await storageRef.putData(photoBytes);
      
      // Get the download URL
      final downloadUrl = await storageRef.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteProfilePhoto(String userId, {String? fileName}) async {
    try {
      if (fileName != null) {
        // Delete a specific file
        final storageRef = _storage.ref().child('profile_photos/$userId/$fileName');
        await storageRef.delete();
      } else {
        // Delete all files in the user's folder
        final storageRef = _storage.ref().child('profile_photos/$userId');
        final listResult = await storageRef.listAll();
        
        for (final item in listResult.items) {
          await item.delete();
        }
      }
    } catch (e) {
      throw Exception('Failed to delete profile photo: ${e.toString()}');
    }
  }
  
  @override
  Future<String?> getProfilePhotoUrl(String userId) async {
    try {
      final storageRef = _storage.ref().child('profile_photos/$userId');
      final listResult = await storageRef.listAll();
      
      if (listResult.items.isEmpty) {
        return null;
      }
      
      // Get the most recent photo (assuming the most recent is the last one)
      final photoRef = listResult.items.last;
      
      return await photoRef.getDownloadURL();
    } catch (e) {
      // If there's an error (e.g., no photos), return null
      return null;
    }
  }
}
