import 'package:ndao/core/infrastructure/appwrite/appwrite_client.dart';
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
          databaseId: 'ndao',
          reviewsCollectionId: 'reviews',
        ),
      ),

      // Review provider
      ChangeNotifierProvider<ReviewProvider>(
        create: (context) => ReviewProvider(
          reviewRepository: context.read<ReviewRepository>(),
        ),
      ),
    ];
  }
}
