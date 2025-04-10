import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/foundation.dart';
import 'package:ndao/user/domain/entities/review_entity.dart';
import 'package:ndao/user/domain/repositories/review_repository.dart';

class AppwriteReviewRepository implements ReviewRepository {
  final Databases _databases;
  final String _databaseId;
  final String _reviewsCollectionId;

  AppwriteReviewRepository({
    required Databases databases,
    required String databaseId,
    required String reviewsCollectionId,
  })  : _databases = databases,
        _databaseId = databaseId,
        _reviewsCollectionId = reviewsCollectionId;

  @override
  Future<List<ReviewEntity>> getDriverReviews(String driverId) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _reviewsCollectionId,
        queries: [
          Query.equal('driver_id', driverId),
          Query.orderDesc('created_at'),
        ],
      );

      return result.documents
          .map((doc) => _documentToReviewEntity(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting driver reviews: $e');
      rethrow;
    }
  }

  @override
  Future<ReviewEntity> addReview({
    required String driverId,
    required String userId,
    required String userName,
    required double rating,
    String? comment,
    String? userProfilePictureUrl,
  }) async {
    try {
      final now = DateTime.now();

      final document = await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _reviewsCollectionId,
        documentId: ID.unique(),
        data: {
          'driver_id': driverId,
          'user_id': userId,
          'user_name': userName,
          'rating': rating,
          'comment': comment,
          'user_profile_picture_url': userProfilePictureUrl,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      );

      return _documentToReviewEntity(document);
    } catch (e) {
      debugPrint('Error adding review: $e');
      rethrow;
    }
  }

  @override
  Future<ReviewEntity> updateReview({
    required String reviewId,
    double? rating,
    String? comment,
  }) async {
    try {
      final now = DateTime.now();

      final data = <String, dynamic>{
        'updated_at': now.toIso8601String(),
      };

      if (rating != null) {
        data['rating'] = rating;
      }

      if (comment != null) {
        data['comment'] = comment;
      }

      final document = await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _reviewsCollectionId,
        documentId: reviewId,
        data: data,
      );

      return _documentToReviewEntity(document);
    } catch (e) {
      debugPrint('Error updating review: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: _reviewsCollectionId,
        documentId: reviewId,
      );
    } catch (e) {
      debugPrint('Error deleting review: $e');
      rethrow;
    }
  }

  @override
  Future<double?> getDriverAverageRating(String driverId) async {
    try {
      final reviews = await getDriverReviews(driverId);

      if (reviews.isEmpty) {
        return null;
      }

      final totalRating = reviews.fold<double>(
        0,
        (sum, review) => sum + review.rating,
      );

      return totalRating / reviews.length;
    } catch (e) {
      debugPrint('Error getting driver average rating: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasUserReviewedDriver({
    required String userId,
    required String driverId,
  }) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _reviewsCollectionId,
        queries: [
          Query.equal('driver_id', driverId),
          Query.equal('user_id', userId),
        ],
      );

      return result.documents.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if user has reviewed driver: $e');
      rethrow;
    }
  }

  @override
  Future<ReviewEntity?> getUserReviewForDriver({
    required String userId,
    required String driverId,
  }) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _reviewsCollectionId,
        queries: [
          Query.equal('driver_id', driverId),
          Query.equal('user_id', userId),
        ],
      );

      if (result.documents.isEmpty) {
        return null;
      }

      return _documentToReviewEntity(result.documents.first);
    } catch (e) {
      debugPrint('Error getting user review for driver: $e');
      rethrow;
    }
  }

  ReviewEntity _documentToReviewEntity(Document document) {
    return ReviewEntity(
      id: document.$id,
      driverId: document.data['driver_id'],
      userId: document.data['user_id'],
      userName: document.data['user_name'],
      rating: document.data['rating'].toDouble(),
      comment: document.data['comment'],
      userProfilePictureUrl: document.data['user_profile_picture_url'],
      createdAt: DateTime.parse(document.data['created_at']),
      updatedAt: document.data['updated_at'] != null
          ? DateTime.parse(document.data['updated_at'])
          : null,
    );
  }
}
