import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ndao/user/domain/entities/user_entity.dart';
import 'package:ndao/user/domain/providers/favorite_drivers_provider.dart';

/// A button that allows users to mark a driver as favorite
class FavoriteButton extends StatelessWidget {
  /// The driver to mark as favorite
  final UserEntity driver;
  
  /// The size of the button
  final double size;
  
  /// Creates a new FavoriteButton
  const FavoriteButton({
    Key? key,
    required this.driver,
    this.size = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteDriversProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isDriverFavorite(driver.id);
        
        return InkWell(
          onTap: () => _toggleFavorite(context, favoritesProvider),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
              size: size,
            ),
          ),
        );
      },
    );
  }
  
  /// Toggle the favorite status of the driver
  Future<void> _toggleFavorite(
    BuildContext context, 
    FavoriteDriversProvider favoritesProvider
  ) async {
    try {
      await favoritesProvider.toggleFavorite(driver);
      
      // Show a snackbar to confirm the action
      if (!context.mounted) return;
      
      final isFavorite = favoritesProvider.isDriverFavorite(driver.id);
      final message = isFavorite 
          ? 'Added ${driver.givenName} to favorites'
          : 'Removed ${driver.givenName} from favorites';
      
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
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
