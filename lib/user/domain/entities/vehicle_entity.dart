/// Represents a vehicle in the system
class VehicleEntity {
  /// Unique identifier for the vehicle
  final String id;
  
  /// Vehicle license plate number
  final String licensePlate;
  
  /// Vehicle brand (manufacturer)
  final String brand;
  
  /// Vehicle model
  final String model;
  
  /// Vehicle type (e.g., motorcycle, car)
  final String type;
  
  /// Optional vehicle photo URL
  final String? photoUrl;
  
  /// Whether this is the driver's primary vehicle
  final bool isPrimary;

  /// Creates a new VehicleEntity
  VehicleEntity({
    required this.id,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.type,
    this.photoUrl,
    this.isPrimary = true,
  });
  
  /// Creates a copy of this VehicleEntity with the given fields replaced with new values
  VehicleEntity copyWith({
    String? id,
    String? licensePlate,
    String? brand,
    String? model,
    String? type,
    String? photoUrl,
    bool? isPrimary,
  }) {
    return VehicleEntity(
      id: id ?? this.id,
      licensePlate: licensePlate ?? this.licensePlate,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      type: type ?? this.type,
      photoUrl: photoUrl ?? this.photoUrl,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
