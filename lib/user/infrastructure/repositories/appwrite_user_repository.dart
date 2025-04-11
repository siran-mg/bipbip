import 'package:appwrite/appwrite.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/repositories/user_repository.dart';
import 'package:ndao/user/domain/repositories/vehicle_repository.dart';
import 'package:ndao/user/infrastructure/repositories/commands/client_commands.dart';
import 'package:ndao/user/infrastructure/repositories/commands/driver_commands.dart';
import 'package:ndao/user/infrastructure/repositories/commands/user_commands.dart';
import 'package:ndao/user/infrastructure/repositories/commands/user_role_commands.dart';
import 'package:ndao/user/infrastructure/repositories/queries/user_queries.dart';

/// Implementation of UserRepository using Appwrite with Command Query Separation
class AppwriteUserRepository implements UserRepository {
  late final UserQueries _userQueries;
  late final UserCommands _userCommands;
  late final UserRoleCommands _userRoleCommands;
  late final DriverCommands _driverCommands;
  late final ClientCommands _clientCommands;

  /// Getter for userQueries to allow access for other repositories
  UserQueries get userQueries => _userQueries;

  /// Creates a new AppwriteUserRepository with the given database client
  AppwriteUserRepository(
    Databases databases,
    VehicleRepository vehicleRepository, {
    String databaseId = 'ndao',
    String usersCollectionId = 'users',
    String driverDetailsCollectionId = 'driver_details',
    String clientDetailsCollectionId = 'client_details',
    String userRolesCollectionId = 'user_roles',
  }) {
    // Initialize queries first
    _userQueries = UserQueries(
      databases,
      vehicleRepository,
      databaseId: databaseId,
      usersCollectionId: usersCollectionId,
      driverDetailsCollectionId: driverDetailsCollectionId,
      clientDetailsCollectionId: clientDetailsCollectionId,
      userRolesCollectionId: userRolesCollectionId,
    );

    // Initialize commands
    _userCommands = UserCommands(
      databases,
      databaseId: databaseId,
      usersCollectionId: usersCollectionId,
      driverDetailsCollectionId: driverDetailsCollectionId,
      clientDetailsCollectionId: clientDetailsCollectionId,
      userRolesCollectionId: userRolesCollectionId,
    );

    _userRoleCommands = UserRoleCommands(
      databases,
      _userQueries,
      databaseId: databaseId,
      userRolesCollectionId: userRolesCollectionId,
      driverDetailsCollectionId: driverDetailsCollectionId,
      clientDetailsCollectionId: clientDetailsCollectionId,
    );

    _driverCommands = DriverCommands(
      databases,
      _userQueries,
      databaseId: databaseId,
      driverDetailsCollectionId: driverDetailsCollectionId,
    );

    _clientCommands = ClientCommands(
      databases,
      _userQueries,
      databaseId: databaseId,
      clientDetailsCollectionId: clientDetailsCollectionId,
    );
  }

  @override
  Future<UserEntity> saveUser(UserEntity user) {
    return _userCommands.saveUser(user);
  }

  @override
  Future<UserEntity?> getUserById(String id) {
    return _userQueries.getUserById(id);
  }

  @override
  Future<UserEntity> updateUser(UserEntity user) {
    return _userCommands.updateUser(user);
  }

  @override
  Future<bool> deleteUser(String id) {
    return _userCommands.deleteUser(id);
  }

  @override
  Future<UserEntity> addRole(String userId, String role) {
    return _userRoleCommands.addRole(userId, role);
  }

  @override
  Future<UserEntity> removeRole(String userId, String role) {
    return _userRoleCommands.removeRole(userId, role);
  }

  @override
  Future<UserEntity> updateDriverDetails(
      String userId, DriverDetails driverDetails) {
    return _driverCommands.updateDriverDetails(userId, driverDetails);
  }

  @override
  Future<UserEntity> updateClientDetails(
      String userId, ClientDetails clientDetails) {
    return _clientCommands.updateClientDetails(userId, clientDetails);
  }

  @override
  Future<UserEntity> updateDriverPosition(
      String userId, double latitude, double longitude) {
    return _driverCommands.updateDriverPosition(userId, latitude, longitude);
  }

  @override
  Future<UserEntity> updateDriverAvailability(String userId, bool isAvailable) {
    return _driverCommands.updateDriverAvailability(userId, isAvailable);
  }

  @override
  Future<List<UserEntity>> getAvailableDrivers({bool forceRefresh = false}) {
    return _userQueries.getAvailableDrivers(forceRefresh: forceRefresh);
  }

  @override
  void clearAvailableDriversCache() {
    _userQueries.clearAvailableDriversCache();
  }
}
