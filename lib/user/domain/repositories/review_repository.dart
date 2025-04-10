import 'package:ndao/user/domain/entities/review_entity.dart';

/// Repository interface for managing driver reviews
abstract class ReviewRepository {
  /// Get all reviews for a specific driver
  Future<List<ReviewEntity>> getDriverReviews(String driverId);
  
  /// Add a new review for a driver
  Future<ReviewEntity> addReview({
    required String driverId,
    required String userId,
    required String userName,
    required double rating,
    String? comment,
    String? userProfilePictureUrl,
  });
  
  /// Update an existing review
  Future<ReviewEntity> updateReview({
    required String reviewId,
    double? rating,
    String? comment,
  });
  
  /// Delete a review
  Future<void> deleteReview(String reviewId);
  
  /// Get the average rating for a driver
  Future<double?> getDriverAverageRating(String driverId);
  
  /// Check if a user has already reviewed a driver
  Future<bool> hasUserReviewedDriver({
    required String userId,
    required String driverId,
  });
  
  /// Get a user's review for a specific driver
  Future<ReviewEntity?> getUserReviewForDriver({
    required String userId,
    required String driverId,
  });
}
