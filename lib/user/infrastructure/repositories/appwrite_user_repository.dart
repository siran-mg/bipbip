import 'package:appwrite/appwrite.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';

/// Implementation of UserRepository using Appwrite
class AppwriteUserRepository implements UserRepository {
  final Databases _databases;

  /// Database ID for users collection
  final String _databaseId;

  /// Collection ID for users collection
  final String _usersCollectionId;

  /// Collection ID for driver details collection
  final String _driverDetailsCollectionId;

  /// Collection ID for client details collection
  final String _clientDetailsCollectionId;

  /// Collection ID for user roles collection
  final String _userRolesCollectionId;

  /// Creates a new AppwriteUserRepository with the given database client
  AppwriteUserRepository(
    this._databases, {
    String databaseId = 'ndao',
    String usersCollectionId = 'users',
    String driverDetailsCollectionId = 'driver_details',
    String clientDetailsCollectionId = 'client_details',
    String userRolesCollectionId = 'user_roles',
  })  : _databaseId = databaseId,
        _usersCollectionId = usersCollectionId,
        _driverDetailsCollectionId = driverDetailsCollectionId,
        _clientDetailsCollectionId = clientDetailsCollectionId,
        _userRolesCollectionId = userRolesCollectionId;

  @override
  Future<UserEntity> saveUser(UserEntity user) async {
    try {
      // Save the user
      await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _usersCollectionId,
        documentId: user.id,
        data: {
          'given_name': user.givenName,
          'family_name': user.familyName,
          'email': user.email,
          'phone_number': user.phoneNumber,
          'profile_picture_url': user.profilePictureUrl,
        },
      );

      // Save user roles
      for (final role in user.roles) {
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _userRolesCollectionId,
          documentId: ID.unique(),
          data: {
            'user_id': user.id,
            'role': role,
            'is_active': true,
          },
        );
      }

      // Save driver details if the user is a driver
      if (user.isDriver && user.driverDetails != null) {
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: user.id,
          data: {
            'user_id': user.id,
            'is_available': user.driverDetails!.isAvailable,
            'current_latitude': user.driverDetails!.currentLatitude,
            'current_longitude': user.driverDetails!.currentLongitude,
            'vehicle_license_plate': user.driverDetails!.licensePlate,
            'vehicle_model': user.driverDetails!.model,
            'vehicle_color': user.driverDetails!.color,
            'vehicle_type': user.driverDetails!.vehicleType,
            'rating': user.driverDetails!.rating,
          },
        );
      }

      // Save client details if the user is a client
      if (user.isClient && user.clientDetails != null) {
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _clientDetailsCollectionId,
          documentId: user.id,
          data: {
            'user_id': user.id,
            'rating': user.clientDetails!.rating,
          },
        );
      }

      return user;
    } on AppwriteException catch (e) {
      throw Exception('Failed to save user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to save user: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> getUserById(String id) async {
    try {
      // Get the user
      final userDoc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _usersCollectionId,
        documentId: id,
      );

      // Get user roles
      final rolesResponse = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _userRolesCollectionId,
        queries: [
          Query.equal('user_id', id),
          Query.equal('is_active', true),
        ],
      );

      final roles = rolesResponse.documents
          .map<String>((doc) => doc.data['role'] as String)
          .toList();

      // Get driver details if the user is a driver
      DriverDetails? driverDetails;
      if (roles.contains('driver')) {
        try {
          final driverDoc = await _databases.getDocument(
            databaseId: _databaseId,
            collectionId: _driverDetailsCollectionId,
            documentId: id,
          );

          driverDetails = DriverDetails(
            isAvailable: driverDoc.data['is_available'] ?? false,
            currentLatitude: driverDoc.data['current_latitude'],
            currentLongitude: driverDoc.data['current_longitude'],
            licensePlate: driverDoc.data['vehicle_license_plate'] ?? '',
            model: driverDoc.data['vehicle_model'] ?? '',
            color: driverDoc.data['vehicle_color'] ?? '',
            vehicleType: driverDoc.data['vehicle_type'] ?? '',
            rating: driverDoc.data['rating'],
          );
        } catch (e) {
          // Driver details not found, create with defaults
          driverDetails = DriverDetails(
            licensePlate: 'UNKNOWN',
            model: 'UNKNOWN',
            color: 'UNKNOWN',
            vehicleType: 'motorcycle',
          );
        }
      }

      // Get client details if the user is a client
      ClientDetails? clientDetails;
      if (roles.contains('client')) {
        try {
          final clientDoc = await _databases.getDocument(
            databaseId: _databaseId,
            collectionId: _clientDetailsCollectionId,
            documentId: id,
          );

          clientDetails = ClientDetails(
            rating: clientDoc.data['rating'],
          );
        } catch (e) {
          // Client details not found, create with defaults
          clientDetails = ClientDetails();
        }
      }

      // Create and return the user entity
      return UserEntity(
        id: userDoc.$id,
        givenName: userDoc.data['given_name'],
        familyName: userDoc.data['family_name'],
        email: userDoc.data['email'],
        phoneNumber: userDoc.data['phone_number'],
        profilePictureUrl: userDoc.data['profile_picture_url'],
        roles: roles,
        driverDetails: driverDetails,
        clientDetails: clientDetails,
      );
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        // User not found
        return null;
      }
      throw Exception('Failed to get user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> updateUser(UserEntity user) async {
    try {
      // Update the user
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _usersCollectionId,
        documentId: user.id,
        data: {
          'given_name': user.givenName,
          'family_name': user.familyName,
          'email': user.email,
          'phone_number': user.phoneNumber,
          'profile_picture_url': user.profilePictureUrl,
        },
      );

      // Update driver details if the user is a driver
      if (user.isDriver && user.driverDetails != null) {
        try {
          await _databases.updateDocument(
            databaseId: _databaseId,
            collectionId: _driverDetailsCollectionId,
            documentId: user.id,
            data: {
              'is_available': user.driverDetails!.isAvailable,
              'current_latitude': user.driverDetails!.currentLatitude,
              'current_longitude': user.driverDetails!.currentLongitude,
              'vehicle_license_plate': user.driverDetails!.licensePlate,
              'vehicle_model': user.driverDetails!.model,
              'vehicle_color': user.driverDetails!.color,
              'vehicle_type': user.driverDetails!.vehicleType,
              'rating': user.driverDetails!.rating,
            },
          );
        } catch (e) {
          // Driver details not found, create them
          await _databases.createDocument(
            databaseId: _databaseId,
            collectionId: _driverDetailsCollectionId,
            documentId: user.id,
            data: {
              'user_id': user.id,
              'is_available': user.driverDetails!.isAvailable,
              'current_latitude': user.driverDetails!.currentLatitude,
              'current_longitude': user.driverDetails!.currentLongitude,
              'vehicle_license_plate': user.driverDetails!.licensePlate,
              'vehicle_model': user.driverDetails!.model,
              'vehicle_color': user.driverDetails!.color,
              'vehicle_type': user.driverDetails!.vehicleType,
              'rating': user.driverDetails!.rating,
            },
          );
        }
      }

      // Update client details if the user is a client
      if (user.isClient && user.clientDetails != null) {
        try {
          await _databases.updateDocument(
            databaseId: _databaseId,
            collectionId: _clientDetailsCollectionId,
            documentId: user.id,
            data: {
              'rating': user.clientDetails!.rating,
            },
          );
        } catch (e) {
          // Client details not found, create them
          await _databases.createDocument(
            databaseId: _databaseId,
            collectionId: _clientDetailsCollectionId,
            documentId: user.id,
            data: {
              'user_id': user.id,
              'rating': user.clientDetails!.rating,
            },
          );
        }
      }

      return user;
    } on AppwriteException catch (e) {
      throw Exception('Failed to update user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteUser(String id) async {
    try {
      // Delete the user
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: _usersCollectionId,
        documentId: id,
      );

      // Delete user roles
      final rolesResponse = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _userRolesCollectionId,
        queries: [Query.equal('user_id', id)],
      );

      for (final role in rolesResponse.documents) {
        await _databases.deleteDocument(
          databaseId: _databaseId,
          collectionId: _userRolesCollectionId,
          documentId: role.$id,
        );
      }

      // Delete driver details
      try {
        await _databases.deleteDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: id,
        );
      } catch (e) {
        // Ignore if driver details don't exist
      }

      // Delete client details
      try {
        await _databases.deleteDocument(
          databaseId: _databaseId,
          collectionId: _clientDetailsCollectionId,
          documentId: id,
        );
      } catch (e) {
        // Ignore if client details don't exist
      }

      return true;
    } on AppwriteException catch (e) {
      throw Exception('Failed to delete user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> addRole(String userId, String role) async {
    try {
      // Get the current user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user already has the role
      if (user.roles.contains(role)) {
        return user;
      }

      // Add the role
      await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _userRolesCollectionId,
        documentId: ID.unique(),
        data: {
          'user_id': userId,
          'role': role,
          'is_active': true,
        },
      );

      // If adding driver role, add placeholder driver details
      if (role == 'driver' && user.driverDetails == null) {
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: userId,
          data: {
            'user_id': userId,
            'is_available': false,
            'vehicle_license_plate': 'UNKNOWN',
            'vehicle_model': 'UNKNOWN',
            'vehicle_color': 'UNKNOWN',
            'vehicle_type': 'motorcycle',
          },
        );
      }

      // If adding client role, add placeholder client details
      if (role == 'client' && user.clientDetails == null) {
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _clientDetailsCollectionId,
          documentId: userId,
          data: {
            'user_id': userId,
          },
        );
      }

      // Return the updated user
      return user.addRole(role);
    } on AppwriteException catch (e) {
      throw Exception('Failed to add role: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add role: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> removeRole(String userId, String role) async {
    try {
      // Get the current user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user has the role
      if (!user.roles.contains(role)) {
        return user;
      }

      // Find and update the role document
      final rolesResponse = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _userRolesCollectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.equal('role', role),
          Query.equal('is_active', true),
        ],
      );

      for (final roleDoc in rolesResponse.documents) {
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _userRolesCollectionId,
          documentId: roleDoc.$id,
          data: {
            'is_active': false,
          },
        );
      }

      // Return the updated user
      return user.removeRole(role);
    } on AppwriteException catch (e) {
      throw Exception('Failed to remove role: ${e.message}');
    } catch (e) {
      throw Exception('Failed to remove role: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> updateDriverDetails(
      String userId, DriverDetails driverDetails) async {
    try {
      // Get the current user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user is a driver
      if (!user.isDriver) {
        throw Exception('User is not a driver');
      }

      // Update driver details
      try {
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: userId,
          data: {
            'is_available': driverDetails.isAvailable,
            'current_latitude': driverDetails.currentLatitude,
            'current_longitude': driverDetails.currentLongitude,
            'vehicle_license_plate': driverDetails.licensePlate,
            'vehicle_model': driverDetails.model,
            'vehicle_color': driverDetails.color,
            'vehicle_type': driverDetails.vehicleType,
            'rating': driverDetails.rating,
          },
        );
      } catch (e) {
        // Driver details not found, create them
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: userId,
          data: {
            'user_id': userId,
            'is_available': driverDetails.isAvailable,
            'current_latitude': driverDetails.currentLatitude,
            'current_longitude': driverDetails.currentLongitude,
            'vehicle_license_plate': driverDetails.licensePlate,
            'vehicle_model': driverDetails.model,
            'vehicle_color': driverDetails.color,
            'vehicle_type': driverDetails.vehicleType,
            'rating': driverDetails.rating,
          },
        );
      }

      // Return the updated user
      return user.copyWith(driverDetails: driverDetails);
    } on AppwriteException catch (e) {
      throw Exception('Failed to update driver details: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update driver details: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> updateClientDetails(
      String userId, ClientDetails clientDetails) async {
    try {
      // Get the current user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user is a client
      if (!user.isClient) {
        throw Exception('User is not a client');
      }

      // Update client details
      try {
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _clientDetailsCollectionId,
          documentId: userId,
          data: {
            'rating': clientDetails.rating,
          },
        );
      } catch (e) {
        // Client details not found, create them
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _clientDetailsCollectionId,
          documentId: userId,
          data: {
            'user_id': userId,
            'rating': clientDetails.rating,
          },
        );
      }

      // Return the updated user
      return user.copyWith(clientDetails: clientDetails);
    } on AppwriteException catch (e) {
      throw Exception('Failed to update client details: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update client details: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> updateDriverPosition(
      String userId, double latitude, double longitude) async {
    try {
      // Get the current user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user is a driver
      if (!user.isDriver) {
        throw Exception('User is not a driver');
      }

      // Update driver position
      try {
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: userId,
          data: {
            'current_latitude': latitude,
            'current_longitude': longitude,
          },
        );
      } catch (e) {
        // Driver details not found, create them with default values
        final driverDetails = DriverDetails(
          isAvailable: false,
          currentLatitude: latitude,
          currentLongitude: longitude,
          licensePlate: 'UNKNOWN',
          model: 'UNKNOWN',
          color: 'UNKNOWN',
          vehicleType: 'motorcycle',
        );

        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: userId,
          data: {
            'user_id': userId,
            'is_available': driverDetails.isAvailable,
            'current_latitude': driverDetails.currentLatitude,
            'current_longitude': driverDetails.currentLongitude,
            'vehicle_license_plate': driverDetails.licensePlate,
            'vehicle_model': driverDetails.model,
            'vehicle_color': driverDetails.color,
            'vehicle_type': driverDetails.vehicleType,
          },
        );
      }

      // Return the updated user
      final updatedDriverDetails = user.driverDetails?.copyWith(
            currentLatitude: latitude,
            currentLongitude: longitude,
          ) ??
          DriverDetails(
            isAvailable: false,
            currentLatitude: latitude,
            currentLongitude: longitude,
            licensePlate: 'UNKNOWN',
            model: 'UNKNOWN',
            color: 'UNKNOWN',
            vehicleType: 'motorcycle',
          );

      return user.copyWith(driverDetails: updatedDriverDetails);
    } on AppwriteException catch (e) {
      throw Exception('Failed to update driver position: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update driver position: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> updateDriverAvailability(
      String userId, bool isAvailable) async {
    try {
      // Get the current user
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if the user is a driver
      if (!user.isDriver) {
        throw Exception('User is not a driver');
      }

      // Update driver availability
      try {
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: userId,
          data: {
            'is_available': isAvailable,
          },
        );
      } catch (e) {
        // Driver details not found, create them with default values
        final driverDetails = DriverDetails(
          isAvailable: isAvailable,
          licensePlate: 'UNKNOWN',
          model: 'UNKNOWN',
          color: 'UNKNOWN',
          vehicleType: 'motorcycle',
        );

        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _driverDetailsCollectionId,
          documentId: userId,
          data: {
            'user_id': userId,
            'is_available': driverDetails.isAvailable,
            'vehicle_license_plate': driverDetails.licensePlate,
            'vehicle_model': driverDetails.model,
            'vehicle_color': driverDetails.color,
            'vehicle_type': driverDetails.vehicleType,
          },
        );
      }

      // Return the updated user
      final updatedDriverDetails = user.driverDetails?.copyWith(
            isAvailable: isAvailable,
          ) ??
          DriverDetails(
            isAvailable: isAvailable,
            licensePlate: 'UNKNOWN',
            model: 'UNKNOWN',
            color: 'UNKNOWN',
            vehicleType: 'motorcycle',
          );

      return user.copyWith(driverDetails: updatedDriverDetails);
    } on AppwriteException catch (e) {
      throw Exception('Failed to update driver availability: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update driver availability: ${e.toString()}');
    }
  }

  @override
  Future<List<UserEntity>> getAvailableDrivers() async {
    try {
      // Get all available drivers
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _driverDetailsCollectionId,
        queries: [Query.equal('is_available', true)],
      );

      // Get the user details for each driver
      final drivers = <UserEntity>[];
      for (final driverDoc in response.documents) {
        final userId = driverDoc.data['user_id'];
        final user = await getUserById(userId);
        if (user != null) {
          drivers.add(user);
        }
      }

      return drivers;
    } on AppwriteException catch (e) {
      throw Exception('Failed to get available drivers: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get available drivers: ${e.toString()}');
    }
  }
}
