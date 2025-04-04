import 'dart:io';
import 'package:ndao/core/infrastructure/supabase/storage_service.dart';
import 'package:ndao/user/domain/repositories/client_repository.dart';
import 'package:ndao/user/domain/repositories/driver_repository.dart';

/// Interactor for uploading a profile photo
class UploadProfilePhotoInteractor {
  final StorageService _storageService;
  final ClientRepository? _clientRepository;
  final DriverRepository? _driverRepository;

  /// Creates a new UploadProfilePhotoInteractor with the given repositories
  ///
  /// Either clientRepository or driverRepository must be provided
  UploadProfilePhotoInteractor({
    required StorageService storageService,
    ClientRepository? clientRepository,
    DriverRepository? driverRepository,
  })  : _storageService = storageService,
        _clientRepository = clientRepository,
        _driverRepository = driverRepository,
        assert(clientRepository != null || driverRepository != null,
            'Either clientRepository or driverRepository must be provided');

  /// Execute the upload profile photo operation for a client
  ///
  /// [clientId] The ID of the client
  /// [photoFile] The photo file to upload
  /// Returns the URL of the uploaded photo
  Future<String> executeForClient(String clientId, File photoFile) async {
    if (_clientRepository == null) {
      throw Exception('Client repository not provided');
    }

    try {
      // Upload the photo
      final photoUrl =
          await _storageService.uploadProfilePhoto(clientId, photoFile);

      // Get the current client
      final client = await _clientRepository.getClientById(clientId);
      if (client == null) {
        throw Exception('Client not found');
      }

      // Update the client with the new photo URL
      final updatedClient = client.copyWith(profilePictureUrl: photoUrl);
      await _clientRepository.updateClient(updatedClient);

      return photoUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }

  /// Execute the upload profile photo operation for a driver
  ///
  /// [driverId] The ID of the driver
  /// [photoFile] The photo file to upload
  /// Returns the URL of the uploaded photo
  Future<String> executeForDriver(String driverId, File photoFile) async {
    if (_driverRepository == null) {
      throw Exception('Driver repository not provided');
    }

    try {
      // Upload the photo
      final photoUrl =
          await _storageService.uploadProfilePhoto(driverId, photoFile);

      // Get the current driver
      final driver = await _driverRepository.getDriverById(driverId);
      if (driver == null) {
        throw Exception('Driver not found');
      }

      // Update the driver with the new photo URL
      final updatedDriver = driver.copyWith(profilePictureUrl: photoUrl);
      await _driverRepository.updateDriver(updatedDriver);

      return photoUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }
}
