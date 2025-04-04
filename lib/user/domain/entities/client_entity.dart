/// Represents a client user in the system
class ClientEntity {
  /// Unique identifier for the client
  final String id;

  /// Client's first name
  final String givenName;

  /// Client's last name
  final String familyName;

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
    required this.givenName,
    required this.familyName,
    required this.email,
    required this.phoneNumber,
    this.profilePictureUrl,
    this.rating,
  });

  /// Get the full name (given name + family name)
  String get fullName => '$givenName $familyName';

  /// Creates a copy of this ClientEntity with the given fields replaced with new values
  ClientEntity copyWith({
    String? id,
    String? givenName,
    String? familyName,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    double? rating,
  }) {
    return ClientEntity(
      id: id ?? this.id,
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      rating: rating ?? this.rating,
    );
  }
}
