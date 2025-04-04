import 'package:ndao/location/domain/entities/position_entity.dart';

/// Represents a driver user in the system
class DriverEntity {
  /// Unique identifier for the driver
  final String id;

  /// Driver's first name
  final String givenName;

  /// Driver's last name
  final String familyName;

  /// Driver's email address
  final String email;

  /// Driver's phone number
  final String phoneNumber;

  /// Optional profile picture URL
  final String? profilePictureUrl;

  /// Driver's rating (1-5)
  final double? rating;

  /// Driver's current position
  final PositionEntity? currentPosition;

  /// Driver's vehicle information
  final VehicleInfo vehicleInfo;

  /// Driver's availability status
  final bool isAvailable;

  /// Creates a new DriverEntity
  DriverEntity({
    required this.id,
    required this.givenName,
    required this.familyName,
    required this.email,
    required this.phoneNumber,
    required this.vehicleInfo,
    this.profilePictureUrl,
    this.rating,
    this.currentPosition,
    this.isAvailable = false,
  });

  /// Get the full name (given name + family name)
  String get fullName => '$givenName $familyName';

  /// Creates a copy of this DriverEntity with the given fields replaced with new values
  DriverEntity copyWith({
    String? id,
    String? givenName,
    String? familyName,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    double? rating,
    PositionEntity? currentPosition,
    VehicleInfo? vehicleInfo,
    bool? isAvailable,
  }) {
    return DriverEntity(
      id: id ?? this.id,
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      rating: rating ?? this.rating,
      currentPosition: currentPosition ?? this.currentPosition,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

/// Represents information about a driver's vehicle
class VehicleInfo {
  /// Vehicle license plate number
  final String licensePlate;

  /// Vehicle model
  final String model;

  /// Vehicle color
  final String color;

  /// Vehicle type (e.g., motorcycle, car)
  final VehicleType type;

  /// Creates a new VehicleInfo
  VehicleInfo({
    required this.licensePlate,
    required this.model,
    required this.color,
    required this.type,
  });
}

/// Enum representing different types of vehicles
enum VehicleType {
  motorcycle,
  car,
  bicycle,
  other,
}
