import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ndao/core/infrastructure/appwrite/appwrite_client.dart';
import 'package:ndao/user/domain/interactors/update_driver_rating_interactor.dart';
import 'package:ndao/user/domain/providers/review_provider.dart';
import 'package:ndao/user/domain/repositories/review_repository.dart';
import 'package:ndao/user/infrastructure/repositories/appwrite_review_repository.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Provides all the review-related providers for the app
class ReviewProviders {
  /// Get all review-related providers
  static List<SingleChildWidget> getProviders() {
    return [
      // Review repository
      Provider<ReviewRepository>(
        create: (context) => AppwriteReviewRepository(
          databases: AppwriteClientInitializer.instance.databases,
          databaseId: dotenv.env['APPWRITE_DATABASE_ID'] ?? 'ndao',
          reviewsCollectionId:
              dotenv.env['APPWRITE_REVIEWS_COLLECTION_ID'] ?? 'reviews',
        ),
      ),

      // Review provider
      ChangeNotifierProxyProvider<UpdateDriverRatingInteractor, ReviewProvider>(
        create: (context) => ReviewProvider(
          reviewRepository: context.read<ReviewRepository>(),
        ),
        update: (context, updateDriverRatingInteractor, previous) {
          return ReviewProvider(
            reviewRepository: context.read<ReviewRepository>(),
            updateDriverRatingInteractor: updateDriverRatingInteractor,
          );
        },
      ),
    ];
  }
}
