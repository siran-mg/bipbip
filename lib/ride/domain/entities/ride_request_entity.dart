/// Represents a ride request in the system
class RideRequestEntity {
  /// Unique identifier for the ride request
  final String id;

  /// ID of the client who created the request
  final String clientId;

  /// Latitude of the pickup location
  final double pickupLatitude;

  /// Longitude of the pickup location
  final double pickupLongitude;

  /// Latitude of the destination
  final double destinationLatitude;

  /// Longitude of the destination
  final double destinationLongitude;

  /// Human-readable name of the destination
  final String destinationName;

  /// Client's budget for the ride
  final double budget;

  /// Status of the request: 'pending', 'accepted', 'rejected', 'completed', 'cancelled'
  final String status;

  /// ID of the driver who accepted the request (null if not accepted)
  final String? driverId;

  /// When the request was created
  final DateTime createdAt;

  /// When the request was last updated
  final DateTime updatedAt;

  /// Creates a new RideRequestEntity
  RideRequestEntity({
    required this.id,
    required this.clientId,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.destinationName,
    required this.budget,
    required this.status,
    this.driverId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this RideRequestEntity with the given fields replaced with new values
  RideRequestEntity copyWith({
    String? id,
    String? clientId,
    double? pickupLatitude,
    double? pickupLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    String? destinationName,
    double? budget,
    String? status,
    String? driverId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RideRequestEntity(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      destinationName: destinationName ?? this.destinationName,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Whether the request is pending
  bool get isPending => status == 'pending';

  /// Whether the request is accepted
  bool get isAccepted => status == 'accepted';

  /// Whether the request is rejected
  bool get isRejected => status == 'rejected';

  /// Whether the request is completed
  bool get isCompleted => status == 'completed';

  /// Whether the request is cancelled
  bool get isCancelled => status == 'cancelled';
}
