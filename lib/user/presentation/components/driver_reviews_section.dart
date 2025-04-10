import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/providers/review_provider.dart';
import 'package:ndao/user/presentation/components/review_dialog.dart';
import 'package:ndao/user/presentation/components/review_list.dart';
import 'package:provider/provider.dart';

class DriverReviewsSection extends StatefulWidget {
  final UserEntity driver;
  final UserEntity? currentUser;

  const DriverReviewsSection({
    super.key,
    required this.driver,
    this.currentUser,
  });

  @override
  State<DriverReviewsSection> createState() => _DriverReviewsSectionState();
}

class _DriverReviewsSectionState extends State<DriverReviewsSection> {
  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    await reviewProvider.loadDriverReviews(widget.driver.id);

    if (widget.currentUser != null) {
      await reviewProvider.loadUserReview(
        userId: widget.currentUser!.id,
        driverId: widget.driver.id,
      );
    }
  }

  void _showReviewDialog() {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    final userReview = reviewProvider.userReview;

    showDialog(
      context: context,
      builder: (context) => ReviewDialog(
        driverName: widget.driver.fullName,
        existingReview: userReview,
        onSubmit: (rating, comment) async {
          Navigator.of(context).pop();

          if (userReview == null) {
            // Add new review
            await reviewProvider.addReview(
              driverId: widget.driver.id,
              userId: widget.currentUser!.id,
              userName: widget.currentUser!.fullName,
              rating: rating,
              comment: comment,
              userProfilePictureUrl: widget.currentUser!.profilePictureUrl,
            );
          } else {
            // Update existing review
            await reviewProvider.updateReview(
              reviewId: userReview.id,
              driverId: widget.driver.id,
              rating: rating,
              comment: comment,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        final reviews = reviewProvider.driverReviews;
        final averageRating = reviewProvider.averageRating;
        final isLoading = reviewProvider.isLoading;
        final error = reviewProvider.error;
        final userReview = reviewProvider.userReview;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reviews header with average rating
            Row(
              children: [
                if (averageRating != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${reviews.length})',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < averageRating
                              ? Icons.star
                              : index + 0.5 <= averageRating
                                  ? Icons.star_half
                                  : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ],
                  ),
                ] else ...[
                  Text(
                    'Aucun avis pour le moment',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),

            // Add review button
            if (widget.currentUser != null &&
                widget.currentUser!.id != widget.driver.id)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _showReviewDialog,
                  icon: Icon(
                    userReview != null ? Icons.edit : Icons.rate_review,
                  ),
                  label: Text(
                    userReview != null
                        ? 'Modifier votre avis'
                        : 'Ajouter un avis',
                  ),
                ),
              ),

            // Reviews list
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ReviewList(
                reviews: reviews,
                isLoading: isLoading,
                error: error,
                onRefresh: _loadReviews,
              ),
            ),
          ],
        );
      },
    );
  }
}
