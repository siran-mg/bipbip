import 'package:flutter/foundation.dart';
import 'package:ndao/user/domain/entities/review_entity.dart';
import 'package:ndao/user/domain/interactors/update_driver_rating_interactor.dart';
import 'package:ndao/user/domain/repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _reviewRepository;
  final UpdateDriverRatingInteractor? _updateDriverRatingInteractor;

  ReviewProvider({
    required ReviewRepository reviewRepository,
    UpdateDriverRatingInteractor? updateDriverRatingInteractor,
  })  : _reviewRepository = reviewRepository,
        _updateDriverRatingInteractor = updateDriverRatingInteractor;

  // State
  bool _isLoading = false;
  String? _error;
  List<ReviewEntity> _driverReviews = [];
  ReviewEntity? _userReview;
  double? _averageRating;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ReviewEntity> get driverReviews => _driverReviews;
  ReviewEntity? get userReview => _userReview;
  double? get averageRating => _averageRating;

  // Load reviews for a driver
  Future<void> loadDriverReviews(String driverId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _driverReviews = await _reviewRepository.getDriverReviews(driverId);
      _averageRating = await _reviewRepository.getDriverAverageRating(driverId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load reviews: $e';
      notifyListeners();
    }
  }

  // Check if the current user has reviewed this driver
  Future<bool> hasUserReviewedDriver({
    required String userId,
    required String driverId,
  }) async {
    try {
      return await _reviewRepository.hasUserReviewedDriver(
        userId: userId,
        driverId: driverId,
      );
    } catch (e) {
      _error = 'Failed to check user review: $e';
      notifyListeners();
      return false;
    }
  }

  // Load the current user's review for this driver
  Future<void> loadUserReview({
    required String userId,
    required String driverId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userReview = await _reviewRepository.getUserReviewForDriver(
        userId: userId,
        driverId: driverId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load user review: $e';
      notifyListeners();
    }
  }

  // Add a new review
  Future<void> addReview({
    required String driverId,
    required String userId,
    required String userName,
    required double rating,
    String? comment,
    String? userProfilePictureUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final review = await _reviewRepository.addReview(
        driverId: driverId,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        userProfilePictureUrl: userProfilePictureUrl,
      );

      _userReview = review;

      // Refresh the reviews list and average rating
      await loadDriverReviews(driverId);

      // Update the driver's rating in the driver details
      if (_updateDriverRatingInteractor != null && _averageRating != null) {
        try {
          await _updateDriverRatingInteractor.execute(
              driverId, _averageRating!);
        } catch (e) {
          debugPrint('Failed to update driver rating: $e');
          // Don't fail the whole operation if this fails
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add review: $e';
      notifyListeners();
    }
  }

  // Update an existing review
  Future<void> updateReview({
    required String reviewId,
    required String driverId,
    double? rating,
    String? comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedReview = await _reviewRepository.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );

      _userReview = updatedReview;

      // Refresh the reviews list and average rating
      await loadDriverReviews(driverId);

      // Update the driver's rating in the driver details
      if (_updateDriverRatingInteractor != null && _averageRating != null) {
        try {
          await _updateDriverRatingInteractor.execute(
              driverId, _averageRating!);
        } catch (e) {
          debugPrint('Failed to update driver rating: $e');
          // Don't fail the whole operation if this fails
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update review: $e';
      notifyListeners();
    }
  }

  // Delete a review
  Future<void> deleteReview({
    required String reviewId,
    required String driverId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _reviewRepository.deleteReview(reviewId);

      _userReview = null;

      // Refresh the reviews list and average rating
      await loadDriverReviews(driverId);

      // Update the driver's rating in the driver details
      if (_updateDriverRatingInteractor != null) {
        try {
          // If there are no reviews left, set rating to null or 0
          final newRating = _averageRating ?? 0.0;
          await _updateDriverRatingInteractor.execute(driverId, newRating);
        } catch (e) {
          debugPrint('Failed to update driver rating: $e');
          // Don't fail the whole operation if this fails
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to delete review: $e';
      notifyListeners();
    }
  }

  // Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
