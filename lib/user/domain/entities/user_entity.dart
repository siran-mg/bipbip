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
  
  /// Vehicle license plate number
  final String licensePlate;
  
  /// Vehicle model
  final String model;
  
  /// Vehicle color
  final String color;
  
  /// Vehicle type (e.g., motorcycle, car)
  final String vehicleType;
  
  /// Driver's rating (1-5)
  final double? rating;

  /// Creates new DriverDetails
  DriverDetails({
    this.isAvailable = false,
    this.currentLatitude,
    this.currentLongitude,
    required this.licensePlate,
    required this.model,
    required this.color,
    required this.vehicleType,
    this.rating,
  });
  
  /// Creates a copy of this DriverDetails with the given fields replaced with new values
  DriverDetails copyWith({
    bool? isAvailable,
    double? currentLatitude,
    double? currentLongitude,
    String? licensePlate,
    String? model,
    String? color,
    String? vehicleType,
    double? rating,
  }) {
    return DriverDetails(
      isAvailable: isAvailable ?? this.isAvailable,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      licensePlate: licensePlate ?? this.licensePlate,
      model: model ?? this.model,
      color: color ?? this.color,
      vehicleType: vehicleType ?? this.vehicleType,
      rating: rating ?? this.rating,
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
