import 'package:ndao/location/domain/entities/position_entity.dart';

/// Represents a driver user in the system
class DriverEntity {
  /// Unique identifier for the driver
  final String id;
  
  /// Driver's full name
  final String name;
  
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
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.vehicleInfo,
    this.profilePictureUrl,
    this.rating,
    this.currentPosition,
    this.isAvailable = false,
  });
  
  /// Creates a copy of this DriverEntity with the given fields replaced with new values
  DriverEntity copyWith({
    String? id,
    String? name,
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
      name: name ?? this.name,
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
