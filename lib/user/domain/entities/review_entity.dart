/// Entity representing a driver review
class ReviewEntity {
  /// Unique identifier for the review
  final String id;

  /// ID of the driver being reviewed
  final String driverId;

  /// ID of the user who wrote the review
  final String userId;

  /// Name of the user who wrote the review
  final String userName;

  /// Rating given (1-5)
  final double rating;

  /// Review text content
  final String? comment;

  /// URL to the user's profile picture
  final String? userProfilePictureUrl;

  /// When the review was created
  final DateTime createdAt;

  /// When the review was last updated
  final DateTime? updatedAt;

  const ReviewEntity({
    required this.id,
    required this.driverId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    this.userProfilePictureUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a copy of this review with the given fields replaced with the new values
  ReviewEntity copyWith({
    String? id,
    String? driverId,
    String? userId,
    String? userName,
    double? rating,
    String? comment,
    String? userProfilePictureUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      userProfilePictureUrl:
          userProfilePictureUrl ?? this.userProfilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReviewEntity &&
        other.id == id &&
        other.driverId == driverId &&
        other.userId == userId &&
        other.userName == userName &&
        other.rating == rating &&
        other.comment == comment &&
        other.userProfilePictureUrl == userProfilePictureUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        driverId.hashCode ^
        userId.hashCode ^
        userName.hashCode ^
        rating.hashCode ^
        comment.hashCode ^
        userProfilePictureUrl.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'ReviewEntity(id: $id, driverId: $driverId, userId: $userId, userName: $userName, rating: $rating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
