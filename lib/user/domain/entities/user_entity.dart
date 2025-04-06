import 'vehicle_entity.dart';

/// Represents a user in the system
class UserEntity {
  /// Unique identifier for the user
  final String id;

  /// User's first name
  final String givenName;

  /// User's last name
  final String familyName;

  /// User's email address
  final String email;

  /// User's phone number
  final String phoneNumber;

  /// Optional profile picture URL
  final String? profilePictureUrl;

  /// User's roles (client, driver, or both)
  final List<String> roles;

  /// Whether the user is a client
  final bool isClient;

  /// Whether the user is a driver
  final bool isDriver;

  /// Driver details if the user is a driver
  final DriverDetails? driverDetails;

  /// Client details if the user is a client
  final ClientDetails? clientDetails;

  /// Creates a new UserEntity
  UserEntity({
    required this.id,
    required this.givenName,
    required this.familyName,
    required this.email,
    required this.phoneNumber,
    this.profilePictureUrl,
    required this.roles,
    this.driverDetails,
    this.clientDetails,
  })  : isClient = roles.contains('client'),
        isDriver = roles.contains('driver');

  /// Get the full name (given name + family name)
  String get fullName => '$givenName $familyName';

  /// Creates a copy of this UserEntity with the given fields replaced with new values
  UserEntity copyWith({
    String? id,
    String? givenName,
    String? familyName,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    List<String>? roles,
    DriverDetails? driverDetails,
    ClientDetails? clientDetails,
  }) {
    return UserEntity(
      id: id ?? this.id,
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      roles: roles ?? this.roles,
      driverDetails: driverDetails ?? this.driverDetails,
      clientDetails: clientDetails ?? this.clientDetails,
    );
  }

  /// Add a role to the user
  UserEntity addRole(String role) {
    if (roles.contains(role)) return this;
    return copyWith(roles: [...roles, role]);
  }

  /// Remove a role from the user
  UserEntity removeRole(String role) {
    if (!roles.contains(role)) return this;
    return copyWith(roles: roles.where((r) => r != role).toList());
  }
}

/// Represents driver-specific details
class DriverDetails {
  /// Whether the driver is available for rides
  final bool isAvailable;

  /// Driver's current latitude
  final double? currentLatitude;

  /// Driver's current longitude
  final double? currentLongitude;

  /// Driver's vehicles
  final List<VehicleEntity> vehicles;

  /// Driver's rating (1-5)
  final double? rating;

  /// Creates new DriverDetails
  DriverDetails({
    this.isAvailable = false,
    this.currentLatitude,
    this.currentLongitude,
    this.vehicles = const [],
    this.rating,
  });

  /// Get the primary vehicle
  VehicleEntity? get primaryVehicle {
    if (vehicles.isEmpty) return null;
    return vehicles.firstWhere(
      (vehicle) => vehicle.isPrimary,
      orElse: () => vehicles.first,
    );
  }

  /// Creates a copy of this DriverDetails with the given fields replaced with new values
  DriverDetails copyWith({
    bool? isAvailable,
    double? currentLatitude,
    double? currentLongitude,
    List<VehicleEntity>? vehicles,
    double? rating,
  }) {
    return DriverDetails(
      isAvailable: isAvailable ?? this.isAvailable,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      vehicles: vehicles ?? this.vehicles,
      rating: rating ?? this.rating,
    );
  }

  /// Add a vehicle to the driver
  DriverDetails addVehicle(VehicleEntity vehicle) {
    return copyWith(vehicles: [...vehicles, vehicle]);
  }

  /// Remove a vehicle from the driver
  DriverDetails removeVehicle(String vehicleId) {
    return copyWith(
      vehicles: vehicles.where((v) => v.id != vehicleId).toList(),
    );
  }

  /// Set a vehicle as primary
  DriverDetails setPrimaryVehicle(String vehicleId) {
    return copyWith(
      vehicles: vehicles
          .map((v) => v.copyWith(
                isPrimary: v.id == vehicleId,
              ))
          .toList(),
    );
  }
}

/// Represents client-specific details
class ClientDetails {
  /// Client's rating (1-5)
  final double? rating;

  /// Creates new ClientDetails
  ClientDetails({
    this.rating,
  });

  /// Creates a copy of this ClientDetails with the given fields replaced with new values
  ClientDetails copyWith({
    double? rating,
  }) {
    return ClientDetails(
      rating: rating ?? this.rating,
    );
  }
}
