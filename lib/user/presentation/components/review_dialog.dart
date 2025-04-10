import 'package:flutter/material.dart';
import 'package:ndao/user/domain/entities/review_entity.dart';

class ReviewDialog extends StatefulWidget {
  final String driverName;
  final ReviewEntity? existingReview;
  final Function(double rating, String? comment) onSubmit;

  const ReviewDialog({
    super.key,
    required this.driverName,
    this.existingReview,
    required this.onSubmit,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  late double _rating;
  late TextEditingController _commentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 5.0;
    _commentController = TextEditingController(
      text: widget.existingReview?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    widget.onSubmit(_rating, _commentController.text.isEmpty ? null : _commentController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingReview != null;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing
                  ? 'Modifier votre avis'
                  : 'Évaluer ${widget.driverName}',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Rating stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index + 1 <= _rating
                        ? Icons.star
                        : index + 0.5 == _rating
                            ? Icons.star_half
                            : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      // If tapping the same star, toggle between whole and half star
                      if (index + 1 == _rating) {
                        _rating = index + 0.5;
                      } else if (index + 0.5 == _rating) {
                        _rating = index + 0;
                      } else {
                        _rating = index + 1.0;
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 8),
            
            // Rating text
            Text(
              _getRatingText(_rating),
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Comment field
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Commentaire (optionnel)',
                hintText: 'Partagez votre expérience...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Mettre à jour' : 'Soumettre'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 5) return 'Excellent';
    if (rating >= 4) return 'Très bien';
    if (rating >= 3) return 'Bien';
    if (rating >= 2) return 'Moyen';
    if (rating >= 1) return 'Mauvais';
    return 'Très mauvais';
  }
}
