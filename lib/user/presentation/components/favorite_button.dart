import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/providers/favorite_drivers_provider.dart';

/// A button that allows users to mark a driver as favorite
class FavoriteButton extends StatefulWidget {
  /// The driver to mark as favorite
  final UserEntity driver;

  /// The size of the button
  final double size;

  /// Whether to show a text label next to the icon
  final bool showLabel;

  /// Whether to use a filled button style
  final bool filled;

  /// Whether to use a circular shape
  final bool circular;

  /// Creates a new FavoriteButton
  const FavoriteButton({
    super.key,
    required this.driver,
    this.size = 24.0,
    this.showLabel = false,
    this.filled = false,
    this.circular = true,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteDriversProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isDriverFavorite(widget.driver.id);

        // Define colors based on favorite status
        final Color iconColor = isFavorite ? Colors.red : Colors.grey.shade600;
        final Color backgroundColor = widget.filled
            ? (isFavorite
                ? Colors.red.withAlpha(30)
                : Colors.grey.withAlpha(30))
            : Colors.white.withAlpha(230);
        final Color borderColor =
            isFavorite ? Colors.red : Colors.grey.shade400;

        // Build the button based on style preferences
        Widget buttonContent;

        if (widget.showLabel) {
          // Button with text label
          buttonContent = widget.filled
              ? FilledButton.icon(
                  onPressed: () => _toggleFavorite(context, favoritesProvider),
                  icon: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isFavorite ? _scaleAnimation.value : 1.0,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: widget.filled ? null : iconColor,
                          size: widget.size,
                        ),
                      );
                    },
                  ),
                  label: Text(isFavorite ? 'Favori' : 'Ajouter aux favoris'),
                  style: FilledButton.styleFrom(
                    backgroundColor: isFavorite ? Colors.red.shade50 : null,
                    foregroundColor: isFavorite ? Colors.red : null,
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: () => _toggleFavorite(context, favoritesProvider),
                  icon: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isFavorite ? _scaleAnimation.value : 1.0,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: iconColor,
                          size: widget.size,
                        ),
                      );
                    },
                  ),
                  label: Text(isFavorite ? 'Favori' : 'Ajouter aux favoris'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: iconColor,
                    side: BorderSide(color: borderColor),
                  ),
                );
        } else {
          // Icon-only button
          final buttonWidget = Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _toggleFavorite(context, favoritesProvider),
              borderRadius: BorderRadius.circular(widget.circular ? 50 : 8),
              child: Ink(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: widget.circular ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius:
                      widget.circular ? null : BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Tooltip(
                    message: isFavorite
                        ? 'Retirer des favoris'
                        : 'Ajouter aux favoris',
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isFavorite ? _scaleAnimation.value : 1.0,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: iconColor,
                            size: widget.size,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );

          buttonContent = buttonWidget;
        }

        return buttonContent;
      },
    );
  }

  /// Toggle the favorite status of the driver
  Future<void> _toggleFavorite(
      BuildContext context, FavoriteDriversProvider favoritesProvider) async {
    try {
      // Play animation when adding to favorites
      final wasFavorite = favoritesProvider.isDriverFavorite(widget.driver.id);

      await favoritesProvider.toggleFavorite(widget.driver);

      // If we just added to favorites, play the animation
      if (!wasFavorite &&
          favoritesProvider.isDriverFavorite(widget.driver.id)) {
        _controller.forward(from: 0.0);
      }

      // Show a snackbar to confirm the action
      if (!context.mounted) return;

      final isFavorite = favoritesProvider.isDriverFavorite(widget.driver.id);
      final message = isFavorite
          ? 'Ajouté ${widget.driver.givenName} aux favoris'
          : 'Retiré ${widget.driver.givenName} des favoris';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Show error message
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
