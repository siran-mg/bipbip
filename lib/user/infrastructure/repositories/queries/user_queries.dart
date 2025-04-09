import 'package:appwrite/appwrite.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/vehicle_repository.dart';

/// Class responsible for read-only operations related to users
class UserQueries {
  final Databases _databases;
  final VehicleRepository _vehicleRepository;

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

  /// Creates a new UserQueries with the given database client
  UserQueries(
    this._databases,
    this._vehicleRepository, {
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

  /// Get a user by ID
  /// 
  /// Returns the user if found, null otherwise
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
        queries: [Query.equal('user_id', id), Query.equal('is_active', true)],
      );

      // Extract roles
      final roles = rolesResponse.documents
          .map((doc) => doc.data['role'] as String)
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

          // Get vehicles for this driver
          final vehicles = await _vehicleRepository.getVehiclesForDriver(id);

          driverDetails = DriverDetails(
            isAvailable: driverDoc.data['is_available'] ?? false,
            rating: driverDoc.data['rating'],
            currentLatitude: driverDoc.data['current_latitude'],
            currentLongitude: driverDoc.data['current_longitude'],
            vehicles: vehicles,
          );
        } catch (e) {
          // Driver details not found, create empty driver details
          driverDetails = DriverDetails();
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
          // Client details not found, create empty client details
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
      throw Exception('Failed to get user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  /// Get all available drivers
  /// 
  /// Returns a list of all users that are drivers and currently available
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
