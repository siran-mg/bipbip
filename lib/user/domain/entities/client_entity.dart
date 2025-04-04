/// Represents a client user in the system
class ClientEntity {
  /// Unique identifier for the client
  final String id;
  
  /// Client's full name
  final String name;
  
  /// Client's email address
  final String email;
  
  /// Client's phone number
  final String phoneNumber;
  
  /// Optional profile picture URL
  final String? profilePictureUrl;
  
  /// Client's rating (1-5)
  final double? rating;

  /// Creates a new ClientEntity
  ClientEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePictureUrl,
    this.rating,
  });
  
  /// Creates a copy of this ClientEntity with the given fields replaced with new values
  ClientEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    double? rating,
  }) {
    return ClientEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      rating: rating ?? this.rating,
    );
  }
}
